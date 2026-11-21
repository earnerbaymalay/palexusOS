#!/usr/bin/env bash
# ==============================================================================
# PalexusOS: fetch the newest CI-built live ISO into out/
# ==============================================================================
# Every push to main builds the ISO, gates it and boots it in QEMU in CI
# (.github/workflows/build-iso.yml), then uploads it as the "palexusos-live-iso"
# artifact with its SHA256SUMS. GitHub only lets signed-in users download
# workflow artifacts and keeps them for 14 days, so this needs the GitHub CLI
# (gh auth login). After it finishes, ./build/test-iso-boot.sh --gui boots it.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO="${PALEXUS_REPO:-earnerbaymalay/palexusOS}"
BRANCH="main"
ARTIFACT="palexusos-live-iso"
OUT_DIR="${REPO_ROOT}/out"
DRY_RUN=false

usage() {
    cat << 'EOF'
Usage: build/fetch-iso.sh [OPTIONS]

Download the newest PalexusOS live ISO built by CI into out/ and verify it.

Options:
  -b, --branch <name>   Branch whose CI build to fetch (default: main)
  -o, --out <dir>       Download directory (default: out/ in the repository)
      --dry-run         Show which build would be downloaded, then exit
  -h, --help            Display this help message and exit

Needs the GitHub CLI signed in (gh auth login): GitHub only serves workflow
artifacts to signed-in users. The ISO is about 3 GB.
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -b|--branch)
            [[ $# -ge 2 ]] || { echo "[!] Error: --branch requires a name"; exit 1; }
            BRANCH="$2"
            shift 2
            ;;
        -o|--out)
            [[ $# -ge 2 ]] || { echo "[!] Error: --out requires a directory"; exit 1; }
            OUT_DIR="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "[!] Error: Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

if ! command -v gh >/dev/null 2>&1; then
    echo "[!] Error: the GitHub CLI (gh) is not installed."
    echo "    Arch / CachyOS: sudo pacman -S github-cli    Debian / Ubuntu: sudo apt install gh"
    exit 1
fi
if ! gh auth status >/dev/null 2>&1; then
    echo "[!] Error: gh is not signed in. Run 'gh auth login' first:"
    echo "    GitHub only serves CI downloads to signed-in users."
    exit 1
fi

# Newest unexpired ISO artifact built from the branch
echo "[*] Looking for the newest ${ARTIFACT} built from ${BRANCH} in ${REPO}..."
# The API lists artifacts newest first; keep the first unexpired one from the branch
FOUND="$(gh api "repos/${REPO}/actions/artifacts?name=${ARTIFACT}&per_page=50" \
    --jq '.artifacts[] | select(.expired == false) | "\(.workflow_run.head_branch) \(.workflow_run.id) \(.size_in_bytes) \(.created_at)"' \
    | awk -v b="${BRANCH}" '$1 == b { print $2, $3, $4; exit }')"
if [[ -z "${FOUND}" ]]; then
    echo "[!] Error: no unexpired ${ARTIFACT} artifact from ${BRANCH} (CI keeps them for 14 days)."
    echo "    Build one with ./build/build-iso.sh --build-pkgs, or re-run the ISO workflow on ${BRANCH}."
    exit 1
fi
read -r RUN_ID SIZE CREATED <<< "${FOUND}"
SIZE_GB="$(awk -v s="${SIZE}" 'BEGIN { printf "%.1f", s / 1073741824 }')"
echo "[✓] CI run ${RUN_ID}, built ${CREATED}, ${SIZE_GB} GB"
echo "    https://github.com/${REPO}/actions/runs/${RUN_ID}"

if [[ "${DRY_RUN}" == "true" ]]; then
    echo "[i] Dry run: nothing downloaded."
    exit 0
fi

mkdir -p "${OUT_DIR}"
STAGE="$(mktemp -d "${OUT_DIR}/.fetch.XXXXXX")"
trap 'rm -rf "${STAGE}"' EXIT
echo "[*] Downloading into ${OUT_DIR} (about ${SIZE_GB} GB)..."
gh run download "${RUN_ID}" --repo "${REPO}" --name "${ARTIFACT}" --dir "${STAGE}"

ISO="$(find "${STAGE}" -name 'palexusos-*.iso' -print -quit)"
if [[ -z "${ISO}" ]]; then
    FIRST_PART="$(find "${STAGE}" -name 'palexusos-*.iso.001' -print -quit)"
    if [[ -n "${FIRST_PART}" ]]; then
        ISO="${FIRST_PART%.001}"
        echo "[*] Split ISO detected. Reassembling $(basename "${ISO}")..."
        cat "${ISO}".[0-9][0-9][0-9] > "${ISO}"
        rm -f "${ISO}".[0-9][0-9][0-9]
    else
        echo "[!] Error: the artifact did not contain a palexusos-*.iso image or split parts."
        exit 1
    fi
fi
ISO_DIR="$(dirname "${ISO}")"
if [[ -f "${ISO_DIR}/SHA256SUMS" ]]; then
    echo "[*] Verifying SHA256SUMS..."
    (cd "${ISO_DIR}" && sha256sum -c SHA256SUMS)
else
    echo "[i] No SHA256SUMS in the artifact; skipping checksum verification."
fi

mv -f "${ISO_DIR}"/* "${OUT_DIR}/"
echo "[✓] Ready: ${OUT_DIR}/$(basename "${ISO}")"
echo "    Boot it in a QEMU window with: ./build/test-iso-boot.sh --gui"
