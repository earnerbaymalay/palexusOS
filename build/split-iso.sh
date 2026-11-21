#!/usr/bin/env bash
# ==============================================================================
# PalexusOS: Split oversized ISOs for GitHub Releases (< 2 GiB asset limit)
# ==============================================================================
# GitHub Releases enforce a strict 2 GiB per-asset file limit (2,147,483,648 bytes).
# PalexusOS live ISOs are ~3 GB. This script prepares release assets by checking
# the live ISO size. If it exceeds the threshold (default: 1900 MiB), it splits
# the image into 1800 MiB chunks named *.iso.001, *.iso.002, etc., generates
# checksums for both the whole image and parts, and copies companion join
# scripts into the release directory (out/release/).
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

OUT_DIR="${REPO_ROOT}/out"
RELEASE_DIR="${OUT_DIR}/release"
MAX_MB=1900
CHUNK_SIZE="1800M"

usage() {
    cat << 'EOF'
Usage: build/split-iso.sh [OPTIONS]

Prepare release assets, splitting any ISO larger than 2 GiB into numbered parts.

Options:
  -o, --out <dir>        Directory containing built ISOs (default: out/)
  -r, --release <dir>    Target release output directory (default: out/release/)
  -m, --max-mb <mb>      Maximum size in MiB before splitting (default: 1900)
  -c, --chunk <size>     Chunk size for split (default: 1800M)
  -h, --help             Display this help message and exit
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--out)
            [[ $# -ge 2 ]] || { echo "[!] Error: --out requires a directory"; exit 1; }
            OUT_DIR="$2"
            RELEASE_DIR="${OUT_DIR}/release"
            shift 2
            ;;
        -r|--release)
            [[ $# -ge 2 ]] || { echo "[!] Error: --release requires a directory"; exit 1; }
            RELEASE_DIR="$2"
            shift 2
            ;;
        -m|--max-mb)
            [[ $# -ge 2 ]] || { echo "[!] Error: --max-mb requires an integer"; exit 1; }
            MAX_MB="$2"
            shift 2
            ;;
        -c|--chunk)
            [[ $# -ge 2 ]] || { echo "[!] Error: --chunk requires a size (e.g. 1800M)"; exit 1; }
            CHUNK_SIZE="$2"
            shift 2
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

mkdir -p "${RELEASE_DIR}"

# Find ISOs in OUT_DIR
shopt -s nullglob
ISOS=("${OUT_DIR}"/palexusos-*.iso)
shopt -u nullglob

if [[ ${#ISOS[@]} -eq 0 ]]; then
    echo "[!] Error: No palexusos-*.iso found in ${OUT_DIR}."
    exit 1
fi

for iso in "${ISOS[@]}"; do
    iso_name="$(basename "${iso}")"
    # Get size in bytes
    if [[ "$OSTYPE" == "darwin"* ]]; then
        size_bytes="$(stat -f%z "${iso}")"
    else
        size_bytes="$(stat -c%s "${iso}")"
    fi
    size_mb=$(( size_bytes / 1048576 ))

    echo "[*] Processing ${iso_name} (${size_mb} MiB)..."

    if (( size_mb > MAX_MB )); then
        echo "[!] ISO exceeds ${MAX_MB} MiB limit for GitHub Releases (${size_mb} MiB)."
        echo "[+] Splitting into ${CHUNK_SIZE} parts: ${iso_name}.001, ${iso_name}.002, ..."

        # Split into numbered parts: .001, .002, ...
        split -b "${CHUNK_SIZE}" -d -a 3 --numeric-suffixes=1 "${iso}" "${RELEASE_DIR}/${iso_name}."

        echo "[✓] Split complete. Staging companion join helpers..."
        cp -f "${SCRIPT_DIR}/join-iso.sh" "${RELEASE_DIR}/"
        cp -f "${SCRIPT_DIR}/join-iso.ps1" "${RELEASE_DIR}/"

        cat << EOF > "${RELEASE_DIR}/HOW_TO_JOIN.txt"
PalexusOS Split ISO Reassembly Instructions
===========================================

Due to GitHub Release's 2 GiB per-file asset limit, this live ISO image is
provided in split parts:
  ${iso_name}.001
  ${iso_name}.002

To reassemble into the full bootable ${iso_name} image:

Windows (Command Prompt):
-------------------------
copy /b ${iso_name}.001 + ${iso_name}.002 ${iso_name}

Windows (PowerShell):
---------------------
.\join-iso.ps1

Linux / macOS:
--------------
./join-iso.sh
# or simply:
cat ${iso_name}.00* > ${iso_name}

Verification:
-------------
sha256sum -c SHA256SUMS

Writing to USB:
---------------
- Windows: Use Rufus (https://rufus.ie) or BalenaEtcher.
- Linux / macOS: sudo dd if=${iso_name} of=/dev/sdX bs=4M status=progress oflag=sync
EOF
    else
        echo "[i] ISO is within GitHub Release size limit (${size_mb} MiB <= ${MAX_MB} MiB)."
        echo "[+] Copying ${iso_name} to release directory..."
        cp -f "${iso}" "${RELEASE_DIR}/"
    fi
done

# Copy companion manifests and signatures if present
for ext in txt sig; do
    shopt -s nullglob
    extras=("${OUT_DIR}"/*."${ext}")
    shopt -u nullglob
    for extra in "${extras[@]}"; do
        extra_name="$(basename "${extra}")"
        if [[ "${extra_name}" != "SHA256SUMS" && "${extra_name}" != "SHA512SUMS" ]]; then
            cp -f "${extra}" "${RELEASE_DIR}/"
        fi
    done
done

# Generate SHA256SUMS and SHA512SUMS in RELEASE_DIR
echo "[*] Generating checksums in ${RELEASE_DIR}..."
(
    cd "${RELEASE_DIR}"
    rm -f SHA256SUMS SHA512SUMS

    shopt -s nullglob
    release_files=(*.*)
    shopt -u nullglob

    if [[ ${#release_files[@]} -gt 0 ]]; then
        if command -v sha256sum >/dev/null 2>&1; then
            sha256sum "${release_files[@]}" > SHA256SUMS
            sha512sum "${release_files[@]}" > SHA512SUMS
        elif command -v shasum >/dev/null 2>&1; then
            shasum -a 256 "${release_files[@]}" > SHA256SUMS
            shasum -a 512 "${release_files[@]}" > SHA512SUMS
        fi
    fi
)

# Append whole ISO checksum from OUT_DIR to SHA256SUMS so users can verify after join
if [[ -f "${OUT_DIR}/SHA256SUMS" ]]; then
    while IFS= read -r line; do
        if [[ "${line}" =~ \.iso$ ]]; then
            echo "${line}" >> "${RELEASE_DIR}/SHA256SUMS"
        fi
    done < "${OUT_DIR}/SHA256SUMS"
fi

if [[ -f "${OUT_DIR}/SHA512SUMS" ]]; then
    while IFS= read -r line; do
        if [[ "${line}" =~ \.iso$ ]]; then
            echo "${line}" >> "${RELEASE_DIR}/SHA512SUMS"
        fi
    done < "${OUT_DIR}/SHA512SUMS"
fi

echo "[✓] Release assets staged in ${RELEASE_DIR}:"
ls -lh "${RELEASE_DIR}"
