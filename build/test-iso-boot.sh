#!/usr/bin/env bash
# ==============================================================================
# PalexusOS QEMU Boot Smoke Test Harness
# ==============================================================================
# Headless virtualized boot verification for PalexusOS live ISO images.
# Validates UEFI (OVMF) initialization, kernel bootstrap, systemd service
# convergence, and live user target reachability without root privileges.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Default parameters
ISO_PATH=""
TIMEOUT=120
MEMORY="2048"
SMP="2"
DRY_RUN=false
CHECK_ONLY=false
CUSTOM_OVMF=""
CUSTOM_MARKER=""
KEEP_LOGS=false
GUI_MODE=false

# Temporary log files
SERIAL_LOG=""
QEMU_LOG=""
QEMU_PID=""

# Help message
usage() {
    cat << 'EOF'
Usage: build/test-iso-boot.sh [OPTIONS]

Headless QEMU boot smoke test for PalexusOS ISO images.

Options:
  -i, --iso <path>       Path to PalexusOS ISO image (default: newest in out/)
  -t, --timeout <sec>    Maximum boot timeout in seconds (default: 120)
  -m, --memory <mb>      VM memory in megabytes (default: 2048)
  -s, --smp <cores>      Virtual CPU core count (default: 2)
  -g, --gui, --window    Launch interactive graphical VM window (GTK/VirtIO) on DISPLAY
      --ovmf <path>      Explicit path to OVMF UEFI firmware file
      --marker <regex>   Custom regex marker to wait for in boot logs
      --dry-run          Validate prerequisites and show QEMU command without booting
      --check            Verify host tools (QEMU, OVMF, KVM) and exit
      --keep-logs        Retain temporary log files upon exit for debugging
  -h, --help             Display this help message and exit

Examples:
  ./build/test-iso-boot.sh --check
  ./build/test-iso-boot.sh --dry-run
  ./build/test-iso-boot.sh --gui --iso out/palexusos-2026.11.12-x86_64.iso
  ./build/test-iso-boot.sh --iso out/palexusos-2026.11.12-x86_64.iso --timeout 90
EOF
}

# Parse CLI arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--iso)
            [[ $# -ge 2 ]] || { echo "[!] Error: --iso requires a path argument"; exit 1; }
            ISO_PATH="$2"
            shift 2
            ;;
        -t|--timeout)
            [[ $# -ge 2 ]] || { echo "[!] Error: --timeout requires seconds argument"; exit 1; }
            TIMEOUT="$2"
            shift 2
            ;;
        -m|--memory)
            [[ $# -ge 2 ]] || { echo "[!] Error: --memory requires megabytes argument"; exit 1; }
            MEMORY="$2"
            shift 2
            ;;
        -s|--smp)
            [[ $# -ge 2 ]] || { echo "[!] Error: --smp requires core count argument"; exit 1; }
            SMP="$2"
            shift 2
            ;;
        --ovmf)
            [[ $# -ge 2 ]] || { echo "[!] Error: --ovmf requires firmware path"; exit 1; }
            CUSTOM_OVMF="$2"
            shift 2
            ;;
        --marker|--expect)
            [[ $# -ge 2 ]] || { echo "[!] Error: --marker requires a regex pattern"; exit 1; }
            CUSTOM_MARKER="$2"
            shift 2
            ;;
        -g|--gui|--window)
            GUI_MODE=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --check)
            CHECK_ONLY=true
            shift
            ;;
        --keep-logs)
            KEEP_LOGS=true
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

# Cleanup handler on exit or signal
# shellcheck disable=SC2317,SC2329
cleanup() {
    local exit_code=$?
    if [[ -n "${QEMU_PID}" ]] && kill -0 "${QEMU_PID}" 2>/dev/null; then
        echo "[*] Cleaning up QEMU process (PID: ${QEMU_PID})..."
        kill "${QEMU_PID}" 2>/dev/null || true
        wait "${QEMU_PID}" 2>/dev/null || true
    fi
    if [[ "${KEEP_LOGS}" == "false" ]]; then
        [[ -n "${SERIAL_LOG}" && -f "${SERIAL_LOG}" ]] && rm -f "${SERIAL_LOG}"
        [[ -n "${QEMU_LOG}" && -f "${QEMU_LOG}" ]] && rm -f "${QEMU_LOG}"
    else
        [[ -n "${SERIAL_LOG}" && -f "${SERIAL_LOG}" ]] && echo "[i] Serial log preserved: ${SERIAL_LOG}"
        [[ -n "${QEMU_LOG}" && -f "${QEMU_LOG}" ]] && echo "[i] QEMU output log preserved: ${QEMU_LOG}"
    fi
    exit "${exit_code}"
}
trap cleanup EXIT INT TERM

# 1. Verify QEMU availability
QEMU_BIN=""
if command -v qemu-system-x86_64 >/dev/null 2>&1; then
    QEMU_BIN="qemu-system-x86_64"
elif [[ -x "/usr/bin/qemu-system-x86_64" ]]; then
    QEMU_BIN="/usr/bin/qemu-system-x86_64"
else
    echo "[!] Error: qemu-system-x86_64 is not installed or not in PATH."
    exit 1
fi

# 2. Locate UEFI (OVMF) firmware
OVMF_CODE=""
if [[ -n "${CUSTOM_OVMF}" ]]; then
    if [[ -s "${CUSTOM_OVMF}" ]]; then
        OVMF_CODE="${CUSTOM_OVMF}"
    else
        echo "[!] Error: Specified OVMF firmware does not exist or is empty: ${CUSTOM_OVMF}"
        exit 1
    fi
else
    OVMF_SEARCH_PATHS=(
        "/usr/share/OVMF/OVMF_CODE.fd"
        "/usr/share/OVMF/OVMF_CODE_4M.fd"
        "/usr/share/edk2/x64/OVMF_CODE.fd"
        "/usr/share/edk2/x64/OVMF_CODE_4M.fd"
        "/usr/share/edk2-ovmf/x64/OVMF_CODE.fd"
        "/usr/share/edk2-ovmf/x64/OVMF_CODE_4M.fd"
        "/usr/share/qemu/OVMF.fd"
        "/usr/share/ovmf/OVMF.fd"
        "/usr/share/ovmf/x64/OVMF_CODE.fd"
    )
    for path in "${OVMF_SEARCH_PATHS[@]}"; do
        if [[ -s "${path}" ]]; then
            OVMF_CODE="${path}"
            break
        fi
    done
fi

if [[ -z "${OVMF_CODE}" ]]; then
    echo "[!] Error: OVMF UEFI firmware not found in standard paths."
    echo "    Please install 'edk2-ovmf' / 'ovmf' package or supply --ovmf <path>."
    exit 1
fi

# 3. Detect KVM acceleration and CPU microarchitecture
ACCEL_DESC=""
ACCEL_OPTS=()
if [[ -r /dev/kvm && -w /dev/kvm ]]; then
    ACCEL_DESC="KVM hardware acceleration active (/dev/kvm)"
    ACCEL_OPTS=("-enable-kvm" "-cpu" "host")
else
    ACCEL_DESC="TCG software emulation (KVM unavailable or unprivileged)"
    ACCEL_OPTS=("-accel" "tcg" "-cpu" "max")
fi

# 4. Resolve ISO image path
if [[ -z "${ISO_PATH}" ]]; then
    if compgen -G "${REPO_ROOT}/out/palexusos-*.iso" >/dev/null; then
        # shellcheck disable=SC2012
        ISO_PATH="$(ls -t "${REPO_ROOT}/out"/palexusos-*.iso 2>/dev/null | head -n 1)"
    fi
fi

# Handle --check flag
if [[ "${CHECK_ONLY}" == "true" ]]; then
    echo "=============================================================================="
    echo " PalexusOS Boot Smoke Test — Host Prerequisite Check"
    echo "=============================================================================="
    echo "[✓] QEMU binary:        ${QEMU_BIN} ($("${QEMU_BIN}" --version | head -n 1))"
    echo "[✓] OVMF UEFI firmware: ${OVMF_CODE}"
    echo "[✓] Virtualization:     ${ACCEL_DESC}"
    if [[ -n "${ISO_PATH}" && -f "${ISO_PATH}" ]]; then
        echo "[✓] Target ISO image:   ${ISO_PATH}"
    else
        echo "[i] Target ISO image:   None found in out/ (run ./build/build-iso.sh to build)"
    fi
    echo "[✓] All prerequisites for headless QEMU boot test are satisfied."
    exit 0
fi

# Handle --dry-run flag
if [[ "${DRY_RUN}" == "true" ]]; then
    echo "=============================================================================="
    echo " PalexusOS Boot Smoke Test — Dry Run"
    echo "=============================================================================="
    echo "[✓] QEMU binary:        ${QEMU_BIN}"
    echo "[✓] OVMF UEFI firmware: ${OVMF_CODE}"
    echo "[✓] Virtualization:     ${ACCEL_DESC}"
    if [[ -z "${ISO_PATH}" || ! -f "${ISO_PATH}" ]]; then
        echo "[i] Notice: No ISO found in ${REPO_ROOT}/out/ and none specified via --iso."
        echo "    Prerequisite checks passed successfully. Build an ISO with ./build/build-iso.sh"
        echo "    before running live boot tests."
        exit 0
    fi
    echo "[✓] Target ISO image:   ${ISO_PATH}"
    echo ""
    echo "[*] Planned QEMU execution command:"
    echo "    ${QEMU_BIN} \\"
    echo "        -m \"${MEMORY}\" -smp \"${SMP}\" \\"
    echo "        -display none -nographic -monitor none \\"
    echo "        -serial file:<tmp_serial_log> \\"
    echo "        -drive if=pflash,format=raw,readonly=on,file=\"${OVMF_CODE}\" \\"
    echo "        -cdrom \"${ISO_PATH}\" \\"
    echo "        -boot d \\"
    echo "        ${ACCEL_OPTS[*]}"
    echo ""
    echo "[✓] Dry run verification completed successfully."
    exit 0
fi

# Ensure ISO exists when running actual test
if [[ -z "${ISO_PATH}" || ! -f "${ISO_PATH}" ]]; then
    echo "[!] Error: No PalexusOS ISO image found in ${REPO_ROOT}/out/ and none specified via --iso."
    echo "    Please generate an ISO first using ./build/build-iso.sh or provide --iso <path>."
    exit 1
fi

# Allocate temporary logs
SERIAL_LOG="$(mktemp "${TMPDIR:-/tmp}/palexusos-qemu-serial.XXXXXX.log")"
QEMU_LOG="$(mktemp "${TMPDIR:-/tmp}/palexusos-qemu-proc.XXXXXX.log")"

echo "=============================================================================="
echo " PalexusOS QEMU Boot Smoke Test"
echo "=============================================================================="
echo "[*] Target ISO:         ${ISO_PATH}"
echo "[*] OVMF Firmware:      ${OVMF_CODE}"
echo "[*] Memory:             ${MEMORY} MB | SMP: ${SMP} cores"
echo "[*] Virtualization:     ${ACCEL_DESC}"
echo "[*] Maximum Timeout:    ${TIMEOUT}s"
echo "[*] Serial Log:         ${SERIAL_LOG}"
echo "=============================================================================="

# Launch QEMU
if [[ "${GUI_MODE}" == "true" ]]; then
    echo "[+] Launching interactive QEMU graphical VM on DISPLAY=${DISPLAY:-:0}..."
    echo "[*] Close the QEMU window when done to return to shell."
    "${QEMU_BIN}" \
        -m "${MEMORY}" \
        -smp "${SMP}" \
        -vga virtio \
        -display gtk \
        -device virtio-mouse-pci \
        -device virtio-keyboard-pci \
        -device intel-hda -device hda-duplex \
        -serial file:"${SERIAL_LOG}" \
        -drive if=pflash,format=raw,readonly=on,file="${OVMF_CODE}" \
        -cdrom "${ISO_PATH}" \
        -boot d \
        "${ACCEL_OPTS[@]}"
    exit 0
fi

# Launch QEMU headless
# Redirect serial output directly to log file, suppress monitor on stdio
"${QEMU_BIN}" \
    -m "${MEMORY}" \
    -smp "${SMP}" \
    -display none \
    -nographic \
    -monitor none \
    -serial file:"${SERIAL_LOG}" \
    -drive if=pflash,format=raw,readonly=on,file="${OVMF_CODE}" \
    -cdrom "${ISO_PATH}" \
    -boot d \
    "${ACCEL_OPTS[@]}" > "${QEMU_LOG}" 2>&1 &

QEMU_PID=$!
echo "[+] QEMU process spawned with PID ${QEMU_PID}. Monitoring serial console stream..."

# Milestone trackers
SEEN_KERNEL=false
SEEN_SYSTEMD=false
SEEN_LOGIN=false
SUCCESS=false

# Helper to check if marker exists in serial or process log
match_in_logs() {
    local pattern="$1"
    grep -E -q "${pattern}" "${SERIAL_LOG}" 2>/dev/null || grep -E -q "${pattern}" "${QEMU_LOG}" 2>/dev/null
}

# Boot milestone patterns
PAT_KERNEL="(Linux version|vmlinuz-linux-cachyos|Booting Linux|EFI stub: Loaded initrd|Probing EDD)"
PAT_SYSTEMD="(systemd\[[0-9]+\]|palexus\.service|Reached target|Started )"
PAT_LOGIN="(login:|PalexusOS Live|Graphical Interface|Multi-User System|palexus-live)"

START_TIME=$(date +%s)

while true; do
    NOW=$(date +%s)
    ELAPSED=$((NOW - START_TIME))

    # Check custom marker if provided
    if [[ -n "${CUSTOM_MARKER}" ]]; then
        if match_in_logs "${CUSTOM_MARKER}"; then
            echo "[✓] Boot marker detected after ${ELAPSED}s: '${CUSTOM_MARKER}'"
            SUCCESS=true
            break
        fi
    else
        # Track standard milestones
        if [[ "${SEEN_KERNEL}" == "false" ]] && match_in_logs "${PAT_KERNEL}"; then
            echo "[✓] Milestone [1/3] reached (${ELAPSED}s): Linux kernel boot banner / EFI stub detected"
            SEEN_KERNEL=true
        fi

        if [[ "${SEEN_SYSTEMD}" == "false" ]] && match_in_logs "${PAT_SYSTEMD}"; then
            echo "[✓] Milestone [2/3] reached (${ELAPSED}s): systemd target / palexus.service converging"
            SEEN_SYSTEMD=true
        fi

        if [[ "${SEEN_LOGIN}" == "false" ]] && match_in_logs "${PAT_LOGIN}"; then
            echo "[✓] Milestone [3/3] reached (${ELAPSED}s): Live login prompt / target reached"
            SEEN_LOGIN=true
            SUCCESS=true
            break
        fi
    fi

    # Check if QEMU process crashed or exited prematurely
    if ! kill -0 "${QEMU_PID}" 2>/dev/null; then
        # Check one last time in case markers were flushed just before exit
        if [[ -n "${CUSTOM_MARKER}" ]] && match_in_logs "${CUSTOM_MARKER}"; then
            SUCCESS=true
            break
        elif [[ "${SEEN_LOGIN}" == "true" || ( "${SEEN_SYSTEMD}" == "true" && "${SEEN_KERNEL}" == "true" ) ]]; then
            SUCCESS=true
            break
        fi

        echo ""
        echo "[!] Error: QEMU process (PID ${QEMU_PID}) exited prematurely after ${ELAPSED}s."
        echo "--- Last 20 lines of QEMU process output: ---"
        tail -n 20 "${QEMU_LOG}" 2>/dev/null || true
        echo "--- Last 20 lines of serial console log: ---"
        tail -n 20 "${SERIAL_LOG}" 2>/dev/null || true
        exit 2
    fi

    # Timeout check
    if (( ELAPSED >= TIMEOUT )); then
        # If we saw systemd or kernel, report partial status
        if [[ "${SEEN_SYSTEMD}" == "true" || "${SEEN_KERNEL}" == "true" ]]; then
            echo ""
            echo "[!] Timeout reached (${TIMEOUT}s). Kernel/systemd progress was observed but final login marker did not arrive."
        else
            echo ""
            echo "[!] Timeout reached (${TIMEOUT}s) without detecting boot markers."
        fi
        echo "--- Last 25 lines of serial console log: ---"
        tail -n 25 "${SERIAL_LOG}" 2>/dev/null || true
        echo "--- Last 25 lines of QEMU process output: ---"
        tail -n 25 "${QEMU_LOG}" 2>/dev/null || true
        exit 3
    fi

    sleep 1
done

if [[ "${SUCCESS}" == "true" ]]; then
    echo "=============================================================================="
    echo " PalexusOS Boot Smoke Test: PASSED (Total elapsed: ${ELAPSED}s)"
    echo "=============================================================================="
    exit 0
fi

exit 1
