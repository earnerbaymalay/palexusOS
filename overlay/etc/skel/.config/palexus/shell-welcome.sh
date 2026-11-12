#!/usr/bin/env bash
# ==============================================================================
# PalexusOS Luxury Terminal Welcome Banner & Shell Selector
# ASCII banner, local system readout (nothing leaves the machine) and fastfetch
# ==============================================================================

# Sourced from ~/.bashrc. Do nothing in non-interactive shells. (This must not
# "exit": the file runs inside the user's own shell.)
# "return" ends a sourced file; the "|| exit 0" only runs if someone executes
# this file directly, where it ends that script and nothing else.
# shellcheck disable=SC2317
case $- in
    *i*) ;;
    *) return 0 2>/dev/null || exit 0 ;;
esac
# "bash -ic '<command>'" is interactive too; keep scripted output clean.
if [[ -n "${BASH_EXECUTION_STRING:-}" ]]; then
    # shellcheck disable=SC2317
    return 0 2>/dev/null || exit 0
fi

# Color definitions
VIOLET='\033[38;2;168;85;247m'
PURPLE='\033[38;2;124;58;237m'
MAUVE='\033[38;2;203;166;247m'
CYAN='\033[38;2;116;199;236m'
WHITE='\033[38;2;245;240;255m'
MUTED='\033[38;2;110;105;130m'
BOLD='\033[1m'
RESET='\033[0m'

# Check if lolcat is available; fallback to gradient printer
gradient_print() {
    local text="$1"
    if command -v lolcat >/dev/null 2>&1; then
        echo -e "$text" | lolcat -f -p 1.5 -F 0.2
    else
        echo -e "${PURPLE}${text}${RESET}"
    fi
}

echo ""
# ─── 1. Palexus ASCII Brand Monolith ──────────────────────────────────────────
gradient_print '   ____   _     _     _______  __  _   _  ____'
gradient_print '  |  _ \ / \   | |   | ____\ \/ / | | | |/ ___|'
gradient_print '  | |_) / _ \  | |   |  _|  \  /  | | | |\___ \'
gradient_print '  |  __/ ___ \ | |___| |___ /  \  | |_| | ___) |'
gradient_print '  |_| /_/   \_\|_____|_____/_/\_\  \___/ |____/'
echo -e "${MUTED}   ─── Sovereign Cyber-Organic Workstation [x86-64-v3] ───${RESET}"
echo ""

# ─── 2. Local system readout ───────────────────────────────────────────
# CPU Model & Load
CPU_MODEL=$(lscpu 2>/dev/null | grep -m1 "Model name" | cut -d: -f2 | xargs | sed 's/(R)//g; s/(TM)//g; s/CPU //g')
CPU_MODEL=${CPU_MODEL:-"x86-64 Processor"}
LOAD_AVG=$(awk '{print $1, $2, $3}' /proc/loadavg 2>/dev/null)

# RAM & ZRAM Compression
RAM_TOTAL=$(free -m 2>/dev/null | awk '/^Mem:/{printf "%.1f", $2/1024}')
RAM_USED=$(free -m 2>/dev/null | awk '/^Mem:/{printf "%.1f", $3/1024}')
ZRAM_STAT=$(zramctl 2>/dev/null | awk 'NR==2{print $3, "comp: "$5}')
ZRAM_STAT=${ZRAM_STAT:-"active"}

# Disk Root Free
DISK_FREE=$(df -h / 2>/dev/null | awk 'NR==2{print $4 " free (" $5 " used)"}')

# Active AI Inference Engine
if pgrep -x ollama >/dev/null 2>&1; then
    AI_STATUS="${CYAN}● Ollama Active (11434)${RESET}"
else
    AI_STATUS="${MUTED}○ Ollama Standby${RESET}"
fi

echo -e " ${BOLD}${MAUVE}SYSTEM       ${RESET} ${MUTED}│${RESET} ${WHITE}CPU:${RESET} ${CPU_MODEL} ${MUTED}(load: ${LOAD_AVG})${RESET}"
echo -e " ${BOLD}${MAUVE}MEMORY/ZRAM  ${RESET} ${MUTED}│${RESET} ${WHITE}RAM:${RESET} ${RAM_USED}G / ${RAM_TOTAL}G ${MUTED}│${RESET} ${WHITE}ZRAM:${RESET} ${ZRAM_STAT}"
echo -e " ${BOLD}${MAUVE}STORAGE/AI   ${RESET} ${MUTED}│${RESET} ${WHITE}NVMe:${RESET} ${DISK_FREE} ${MUTED}│${RESET} ${WHITE}AI Core:${RESET} ${AI_STATUS}"
echo ""

# ─── 3. Fastfetch / System Profiler ───────────────────────────────────────────
if command -v fastfetch >/dev/null 2>&1; then
    fastfetch --structure Title:OS:Kernel:Uptime:Packages:Shell:DE:WM:Terminal:Memory:Disk --logo-color-1 "magenta" --logo-color-2 "blue"
fi

# ─── 4. One-time shell choice ─────────────────────────────────────────────────
# Asked once per account, and only when fish is installed. Any answer,
# including Enter or the timeout, is recorded so later shells start without a
# prompt. Choosing fish switches this terminal only; making it the login shell
# is left to chsh, so a Bash started on purpose always stays Bash.
PREF_SHELL_FILE="${HOME}/.config/palexus/preferred_shell"
if [[ ! -f "$PREF_SHELL_FILE" ]] && [[ -t 0 ]] && command -v fish >/dev/null 2>&1; then
    echo -e "${VIOLET}Pick your interactive shell (asked once):${RESET}"
    echo -e "  ${BOLD}[1]${RESET} ${WHITE}Fish${RESET} ${MUTED}(autosuggestions, syntax highlighting)${RESET}"
    echo -e "  ${BOLD}[2]${RESET} ${WHITE}Bash${RESET} ${MUTED}(keep the current shell)${RESET}"
    SHELL_CHOICE=""
    read -r -t 10 -p "Choice (1-2, Enter keeps Bash): " SHELL_CHOICE || echo ""
    mkdir -p "$(dirname "$PREF_SHELL_FILE")"
    if [[ "$SHELL_CHOICE" == "1" ]]; then
        echo "fish" > "$PREF_SHELL_FILE"
        echo -e "${MUTED}Starting fish. To use it in every terminal: chsh -s $(command -v fish)${RESET}"
        exec fish
    fi
    echo "bash" > "$PREF_SHELL_FILE"
fi

# This file runs inside the user's shell: leave nothing behind in it.
unset -f gradient_print
unset VIOLET PURPLE MAUVE CYAN WHITE MUTED BOLD RESET \
    CPU_MODEL LOAD_AVG RAM_TOTAL RAM_USED ZRAM_STAT DISK_FREE AI_STATUS \
    PREF_SHELL_FILE SHELL_CHOICE
