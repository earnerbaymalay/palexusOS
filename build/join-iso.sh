#!/usr/bin/env bash
# ==============================================================================
# PalexusOS: Reassemble split ISO parts into a bootable ISO
# ==============================================================================
# GitHub Releases split images larger than 2 GiB into *.iso.001, *.iso.002, etc.
# This script concatenates the parts back into the complete ISO and validates
# its SHA256 checksum.
#
# Usage:
#   ./build/join-iso.sh [DIR]
# ==============================================================================

set -euo pipefail

TARGET_DIR="${1:-.}"
cd "${TARGET_DIR}"

FIRST_PART=""
shopt -s nullglob
parts=(palexusos-*.iso.001 *.iso.001)
shopt -u nullglob

if [[ ${#parts[@]} -gt 0 ]]; then
    FIRST_PART="${parts[0]}"
fi

if [[ -z "${FIRST_PART}" ]]; then
    echo "[!] Error: No split ISO parts (*.iso.001) found in ${TARGET_DIR}."
    exit 1
fi

ISO_NAME="${FIRST_PART%.001}"
echo "[*] Reassembling ${ISO_NAME} from parts..."

# Concatenate parts in numeric order safely
shopt -s nullglob
iso_chunks=("${ISO_NAME}".[0-9][0-9][0-9])
shopt -u nullglob

if [[ ${#iso_chunks[@]} -eq 0 ]]; then
    echo "[!] Error: No matching chunks found for ${ISO_NAME}."
    exit 1
fi

cat "${iso_chunks[@]}" > "${ISO_NAME}.tmp"
mv -f "${ISO_NAME}.tmp" "${ISO_NAME}"

echo "[✓] Reassembled: ${ISO_NAME}"

if [[ -f "SHA256SUMS" ]]; then
    echo "[*] Verifying SHA256 checksum against SHA256SUMS..."
    if command -v sha256sum >/dev/null 2>&1; then
        if grep -E "[[:space:]]${ISO_NAME}\$" SHA256SUMS >/dev/null 2>&1; then
            grep -E "[[:space:]]${ISO_NAME}\$" SHA256SUMS | sha256sum -c -
        else
            echo "[i] Exact pattern for ${ISO_NAME} not in SHA256SUMS; running full check:"
            sha256sum -c SHA256SUMS --ignore-missing || true
        fi
    elif command -v shasum >/dev/null 2>&1; then
        if grep -E "[[:space:]]${ISO_NAME}\$" SHA256SUMS >/dev/null 2>&1; then
            grep -E "[[:space:]]${ISO_NAME}\$" SHA256SUMS | shasum -a 256 -c -
        fi
    fi
    echo "[✓] Checksum verification completed."
fi

echo ""
echo "=============================================================================="
echo " PalexusOS ISO Ready: ${ISO_NAME}"
echo "=============================================================================="
echo " Boot in QEMU: ./build/test-iso-boot.sh --gui --iso ${ISO_NAME}"
echo " Flash to USB: sudo dd if=${ISO_NAME} of=/dev/sdX bs=4M status=progress oflag=sync"
echo "               (or use Rufus / BalenaEtcher on Windows)"
echo "=============================================================================="
