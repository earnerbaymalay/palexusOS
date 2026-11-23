import os
import sys
import json
import time
import zipfile
import hashlib
import threading
import subprocess
import urllib.request
import urllib.error
from concurrent.futures import ThreadPoolExecutor, as_completed

REPO = "earnerbaymalay/palexusOS"
ARTIFACT_NAME = "palexusos-live-iso"
OUT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "out"))
ZIP_PATH = os.path.join(OUT_DIR, "palexusos-live-iso.zip")
PROGRESS_PATH = os.path.join(OUT_DIR, "palexusos-live-iso.progress.json")
CHUNK_SIZE = 8 * 1024 * 1024  # 8 MB
NUM_WORKERS = 8

class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None

def get_latest_artifact_id():
    cmd = ["gh", "api", f"repos/{REPO}/actions/artifacts?name={ARTIFACT_NAME}&per_page=5"]
    out = subprocess.check_output(cmd, text=True)
    data = json.loads(out)
    for art in data.get("artifacts", []):
        if not art.get("expired"):
            return art["id"], art["size_in_bytes"]
    raise RuntimeError(f"No unexpired {ARTIFACT_NAME} artifact found")

class SASManager:
    def __init__(self, artifact_id):
        self.artifact_id = artifact_id
        self.lock = threading.Lock()
        self.url = None
        self.fetch_time = 0
        self.refresh()

    def refresh(self):
        with self.lock:
            token = subprocess.check_output(["gh", "auth", "token"], text=True).strip()
            req = urllib.request.Request(
                f"https://api.github.com/repos/{REPO}/actions/artifacts/{self.artifact_id}/zip",
                headers={"Authorization": f"Bearer {token}"}
            )
            opener = urllib.request.build_opener(NoRedirect)
            try:
                opener.open(req)
            except urllib.error.HTTPError as e:
                if "Location" in e.headers:
                    self.url = e.headers["Location"]
                    self.fetch_time = time.time()
                    return self.url
                raise
            raise RuntimeError("Did not get Location header from GitHub API")

    def get_url(self):
        # Refresh proactively every 7 minutes (SAS lifetime is 10 min)
        if time.time() - self.fetch_time > 420:
            self.refresh()
        return self.url

def download_chunk(chunk_idx, start_byte, end_byte, sas_mgr, out_fp, file_lock):
    max_retries = 5
    for attempt in range(max_retries):
        try:
            url = sas_mgr.get_url()
            req = urllib.request.Request(url, headers={"Range": f"bytes={start_byte}-{end_byte}"})
            with urllib.request.urlopen(req, timeout=45) as resp:
                if resp.status not in (200, 206):
                    raise RuntimeError(f"Unexpected status: {resp.status}")
                data = resp.read()

            expected_len = end_byte - start_byte + 1
            if len(data) != expected_len:
                raise RuntimeError(f"Short read: got {len(data)}, expected {expected_len}")

            with file_lock:
                out_fp.seek(start_byte)
                out_fp.write(data)
                out_fp.flush()
            return chunk_idx
        except Exception as e:
            time.sleep(1 + attempt * 2)
            if attempt == max_retries - 1:
                raise
            # If 401 or 403 or network drop, refresh token
            if isinstance(e, urllib.error.HTTPError) and e.code in (401, 403):
                sas_mgr.refresh()

def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    print("=" * 70)
    print("PalexusOS High-Speed Multi-Threaded ISO Downloader")
    print("=" * 70)

    print("[*] Resolving latest unexpired artifact...")
    artifact_id, total_size = get_latest_artifact_id()
    total_gb = total_size / (1024 ** 3)
    print(f"[✓] Artifact ID: {artifact_id} ({total_gb:.2f} GB)")

    sas_mgr = SASManager(artifact_id)

    # Initialize file to total size if not already created
    if not os.path.exists(ZIP_PATH) or os.path.getsize(ZIP_PATH) != total_size:
        print(f"[*] Allocating {ZIP_PATH} ({total_gb:.2f} GB)...")
        with open(ZIP_PATH, "wb") as f:
            f.seek(total_size - 1)
            f.write(b"\0")

    # Load progress
    completed_chunks = set()
    if os.path.exists(PROGRESS_PATH):
        try:
            with open(PROGRESS_PATH, "r") as pf:
                completed_chunks = set(json.load(pf))
        except Exception:
            completed_chunks = set()

    chunks = []
    num_chunks = (total_size + CHUNK_SIZE - 1) // CHUNK_SIZE
    for idx in range(num_chunks):
        start = idx * CHUNK_SIZE
        end = min(start + CHUNK_SIZE - 1, total_size - 1)
        chunks.append((idx, start, end))

    pending_chunks = [c for c in chunks if c[0] not in completed_chunks]
    print(f"[*] Total chunks: {num_chunks} (Completed: {len(completed_chunks)}, Remaining: {len(pending_chunks)})")

    if pending_chunks:
        file_lock = threading.Lock()
        progress_lock = threading.Lock()
        start_time = time.time()
        downloaded_bytes_session = 0

        with open(ZIP_PATH, "r+b") as out_fp:
            with ThreadPoolExecutor(max_workers=NUM_WORKERS) as executor:
                futures = {
                    executor.submit(download_chunk, c[0], c[1], c[2], sas_mgr, out_fp, file_lock): c
                    for c in pending_chunks
                }

                for future in as_completed(futures):
                    chunk_idx, start_b, end_b = futures[future]
                    try:
                        future.result()
                        with progress_lock:
                            completed_chunks.add(chunk_idx)
                            downloaded_bytes_session += (end_b - start_b + 1)
                            # Save progress periodically
                            if len(completed_chunks) % 5 == 0 or len(completed_chunks) == num_chunks:
                                with open(PROGRESS_PATH, "w") as pf:
                                    json.dump(list(completed_chunks), pf)

                            elapsed = time.time() - start_time
                            mb_done = downloaded_bytes_session / (1024 * 1024)
                            speed = mb_done / elapsed if elapsed > 0 else 0
                            pct = len(completed_chunks) * 100 / num_chunks
                            sys.stdout.write(f"\r[*] Progress: {pct:5.1f}% ({len(completed_chunks)}/{num_chunks}) | {speed:5.1f} MB/s")
                            sys.stdout.flush()
                    except Exception as e:
                        print(f"\n[!] Chunk {chunk_idx} failed: {e}")
                        raise

        print(f"\n[✓] All {num_chunks} chunks downloaded successfully!")

    # Unpack zip
    print(f"[*] Extracting {ZIP_PATH} into {OUT_DIR}...")
    with zipfile.ZipFile(ZIP_PATH, "r") as zf:
        zf.extractall(OUT_DIR)
    print("[✓] Extraction complete!")

    # Clean up temp zip and progress
    try:
        os.remove(ZIP_PATH)
        if os.path.exists(PROGRESS_PATH):
            os.remove(PROGRESS_PATH)
    except Exception:
        pass

    # Verify SHA256
    sums_file = os.path.join(OUT_DIR, "SHA256SUMS")
    iso_file = None
    for f in os.listdir(OUT_DIR):
        if f.startswith("palexusos-") and f.endswith(".iso"):
            iso_file = os.path.join(OUT_DIR, f)
            break

    if not iso_file:
        print("[!] No ISO found in out/")
        return 1

    print(f"[*] Found ISO: {iso_file}")
    if os.path.exists(sums_file):
        print("[*] Computing SHA256 checksum...")
        h = hashlib.sha256()
        with open(iso_file, "rb") as f:
            while chunk := f.read(16 * 1024 * 1024):
                h.update(chunk)
        actual_hash = h.hexdigest().lower()

        expected_hash = None
        with open(sums_file, "r") as sf:
            for line in sf:
                parts = line.strip().split()
                if len(parts) >= 2 and os.path.basename(parts[1]) == os.path.basename(iso_file):
                    expected_hash = parts[0].lower()
                    break

        print(f"    Expected: {expected_hash}")
        print(f"    Actual:   {actual_hash}")
        if expected_hash == actual_hash:
            print("[✓] SHA256 CHECKSUM VERIFIED! The ISO is byte-for-byte authentic.")
        else:
            print("[!] WARNING: Checksum mismatch!")
            return 2

    print("=" * 70)
    print(f"READY: {iso_file}")
    print("=" * 70)
    return 0

if __name__ == "__main__":
    sys.exit(main())
