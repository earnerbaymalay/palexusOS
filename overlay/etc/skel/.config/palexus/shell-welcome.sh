#!/usr/bin/env bash
# ==============================================================================
# PalexusOS Luxury Terminal Welcome Banner & Shell Selector
# ASCII banner, local system readout (nothing leaves the machine) and fastfetch
# ==============================================================================

# Sourced from ~/.bashrc. Do nothing in non-interactive shells. (This must not
# "exit": the file runs inside the user's own shell.)
case $- in
    *i*) ;;
    *) return 0 ;;
esac

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
# Asked once per account. Any answer, including Enter or the timeout, is
# recorded, so later shells start without a prompt. Only shells that are
# actually installed are offered.
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
    else
        echo "bash" > "$PREF_SHELL_FILE"
    fi
    unset SHELL_CHOICE
fi
if [[ -f "$PREF_SHELL_FILE" ]] && [[ "$(< "$PREF_SHELL_FILE")" == "fish" ]] \
    && [[ -z "${PALEXUS_NO_FISH:-}" ]] && [[ -z "${BASH_EXECUTION_STRING:-}" ]] \
    && [[ -t 0 ]] && command -v fish >/dev/null 2>&1; then
    # Skipped for "bash -ic '...'" so scripted commands still run.
    # PALEXUS_NO_FISH=1 bash  → stay in Bash for this session.
    exec fish
fi
