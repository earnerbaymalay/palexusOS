#!/usr/bin/env bash
# ==============================================================================
# PalexusOS Headless QEMU Boot Smoke Test Harness
# ==============================================================================
# Boots the specified (or newest built) PalexusOS ISO under QEMU/KVM with OVMF,
# monitors the serial console stream without requiring a display or root rights,
# and verifies transition to graphical.target and palexus.service activation.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

BOOT_TIMEOUT="${PALEXUS_BOOT_TIMEOUT:-120}"
BOOT_RAM="${PALEXUS_BOOT_RAM:-4096}"
BOOT_SMP="${PALEXUS_BOOT_SMP:-2}"
DRY_RUN=0
ISO_PATH=""

show_usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] [ISO_PATH]

Options:
  --timeout <seconds>   Maximum seconds to wait for boot targets (default: ${BOOT_TIMEOUT})
  --ram <megabytes>     RAM allocated to QEMU guest in MB (default: ${BOOT_RAM})
  --smp <cores>         Virtual CPU cores allocated to QEMU guest (default: ${BOOT_SMP})
  --dry-run             Validate prerequisites and command configuration without booting
  -h, --help            Show this help message
EOF
}

# Parse command line options
while [[ $# -gt 0 ]]; do
    case "$1" in
        --timeout)
            BOOT_TIMEOUT="$2"
            shift 2
            ;;
        --ram)
            BOOT_RAM="$2"
            shift 2
            ;;
        --smp)
            BOOT_SMP="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        -*)
            echo "[!] Error: Unknown option: $1" >&2
            show_usage >&2
            exit 1
            ;;
        *)
            if [[ -z "${ISO_PATH}" ]]; then
                ISO_PATH="$1"
            else
                echo "[!] Error: Unexpected positional argument: $1" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# If no ISO path supplied, discover the newest in out/
if [[ -z "${ISO_PATH}" ]]; then
    shopt -s nullglob
    iso_candidates=("${REPO_ROOT}"/out/palexusos-*.iso)
    shopt -u nullglob
    if [[ ${#iso_candidates[@]} -gt 0 ]]; then
        ISO_PATH=$(find "${REPO_ROOT}/out" -maxdepth 1 -name 'palexusos-*.iso' -printf '%T@ %p\n' | sort -nr | head -n1 | cut -d' ' -f2-)
    else
        echo "[!] Error: No PalexusOS ISO found in ${REPO_ROOT}/out." >&2
        echo "    Run ./build/build-iso.sh to build an image, or pass an ISO path explicitly." >&2
        exit 1
    fi
fi

echo "==> [PalexusOS QEMU Boot Test] Target ISO: ${ISO_PATH}"

# Verify ISO file exists and has valid minimum size
if [[ ! -f "${ISO_PATH}" ]]; then
    echo "[!] Error: ISO file does not exist: ${ISO_PATH}" >&2
    exit 1
fi

iso_size=$(stat -c %s "${ISO_PATH}" 2>/dev/null || stat -f %z "${ISO_PATH}" 2>/dev/null || echo 0)
if [[ "${iso_size}" -lt 1048576 ]]; then
    echo "[!] Error: ISO image is truncated or empty (${iso_size} bytes < 1MB limit)." >&2
    exit 1
fi

# Locate QEMU binary
if ! command -v qemu-system-x86_64 >/dev/null 2>&1; then
    echo "[!] Error: qemu-system-x86_64 not found. Install qemu-system-x86." >&2
    exit 1
fi

# Acceleration check: KVM preferred, fallback to TCG
QEMU_ACCEL=()
if [[ -r /dev/kvm && -w /dev/kvm ]]; then
    echo "    Hardware Acceleration : KVM enabled (/dev/kvm accessible)"
    QEMU_ACCEL=(-enable-kvm -cpu host)
else
    echo "    Hardware Acceleration : Software TCG emulation (slower, no /dev/kvm access)"
    QEMU_ACCEL=(-cpu max)
fi

# Locate OVMF UEFI firmware
OVMF_PATH=""
for candidate in \
    /usr/share/ovmf/OVMF.fd \
    /usr/share/qemu/OVMF.fd \
    /usr/share/OVMF/OVMF.fd \
    /usr/share/OVMF/OVMF_CODE_4M.fd \
    /usr/share/OVMF/OVMF_CODE.fd \
    /usr/share/edk2-ovmf/x64/OVMF.fd \
    /usr/share/edk2/ovmf/OVMF_CODE.fd; do
    if [[ -f "${candidate}" ]]; then
        OVMF_PATH="${candidate}"
        break
    fi
done

QEMU_BIOS=()
if [[ -n "${OVMF_PATH}" ]]; then
    echo "    UEFI Firmware         : ${OVMF_PATH}"
    QEMU_BIOS=(-bios "${OVMF_PATH}")
else
    echo "    Firmware              : Legacy BIOS fallback (OVMF not found)"
fi

if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "==> [DRY-RUN] QEMU boot parameters and prerequisites validated successfully."
    exit 0
fi

SERIAL_LOG=$(mktemp /tmp/palexusos_qemu_serial.XXXXXX.log)
QEMU_PID=""

cleanup() {
    local exit_code=$?
    if [[ -n "${QEMU_PID}" ]] && kill -0 "${QEMU_PID}" 2>/dev/null; then
        echo "[+] Terminating QEMU test process (PID ${QEMU_PID})..."
        kill -TERM "${QEMU_PID}" 2>/dev/null || true
        sleep 1
        kill -KILL "${QEMU_PID}" 2>/dev/null || true
        wait "${QEMU_PID}" 2>/dev/null || true
    fi
    if [[ -f "${SERIAL_LOG}" ]]; then
        rm -f "${SERIAL_LOG}"
    fi
    exit "${exit_code}"
}
trap cleanup EXIT INT TERM

echo "==> Spawning headless QEMU instance..."
echo "    RAM: ${BOOT_RAM}M | SMP: ${BOOT_SMP} | Timeout: ${BOOT_TIMEOUT}s | Serial: ${SERIAL_LOG}"

qemu-system-x86_64 \
    "${QEMU_ACCEL[@]}" \
    "${QEMU_BIOS[@]}" \
    -m "${BOOT_RAM}" \
    -smp "${BOOT_SMP}" \
    -cdrom "${ISO_PATH}" \
    -boot d \
    -display none \
    -serial "file:${SERIAL_LOG}" \
    -no-reboot &
QEMU_PID=$!

echo "==> QEMU guest running with PID ${QEMU_PID}. Watching serial console stream..."

GRAPHICAL_REACHED=0
PALEXUS_ACTIVE=0
start_time=$(date +%s)

while true; do
    current_time=$(date +%s)
    elapsed=$(( current_time - start_time ))

    if [[ ${elapsed} -ge ${BOOT_TIMEOUT} ]]; then
        echo "[!] ERROR: Boot smoke test timed out after ${BOOT_TIMEOUT} seconds." >&2
        echo "--- Last 50 lines of serial console output ---" >&2
        tail -n 50 "${SERIAL_LOG}" >&2 || true
        exit 1
    fi

    if ! kill -0 "${QEMU_PID}" 2>/dev/null; then
        echo "[!] ERROR: QEMU guest process terminated unexpectedly." >&2
        echo "--- Last 50 lines of serial console output ---" >&2
        tail -n 50 "${SERIAL_LOG}" >&2 || true
        exit 1
    fi

    if [[ ${GRAPHICAL_REACHED} -eq 0 ]]; then
        if grep -Eq 'Reached target (Graphical Interface|graphical\.target)' "${SERIAL_LOG}" 2>/dev/null; then
            echo "  [✓] Serial event detected: Reached target Graphical Interface (${elapsed}s elapsed)"
            GRAPHICAL_REACHED=1
        fi
    fi

    if [[ ${PALEXUS_ACTIVE} -eq 0 ]]; then
        if grep -Eq '(Started.*Palexus|Started palexus\.service|palexus\.service.*active)' "${SERIAL_LOG}" 2>/dev/null; then
            echo "  [✓] Serial event detected: Started palexus.service (${elapsed}s elapsed)"
            PALEXUS_ACTIVE=1
        fi
    fi

    if [[ ${GRAPHICAL_REACHED} -eq 1 && ${PALEXUS_ACTIVE} -eq 1 ]]; then
        echo "=============================================================================="
        echo " [PASS] PalexusOS QEMU Boot Smoke Test Completed Successfully in ${elapsed}s"
        echo "=============================================================================="
        exit 0
    fi

    sleep 1
done
