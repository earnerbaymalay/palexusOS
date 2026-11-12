#!/usr/bin/env bash
# ==============================================================================
# PalexusOS Luxury Terminal Welcome Banner & Shell Selector
# ASCII Cyber-Organic Art + Fastfetch/Sysinfo + Low-Profile Telemetry
# ==============================================================================

# Ensure output only runs in interactive terminal sessions
[[ $- != *i* ]] && return 2>/dev/null || exit 0 2>/dev/null

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

# ─── 2. Low-Profile Live Sysmon Pill ───────────────────────────────────────────
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

echo -e " ${BOLD}${MAUVE}SYS-TELEMETRY${RESET} ${MUTED}│${RESET} ${WHITE}CPU:${RESET} ${CPU_MODEL} ${MUTED}(load: ${LOAD_AVG})${RESET}"
echo -e " ${BOLD}${MAUVE}MEMORY/ZRAM  ${RESET} ${MUTED}│${RESET} ${WHITE}RAM:${RESET} ${RAM_USED}G / ${RAM_TOTAL}G ${MUTED}│${RESET} ${WHITE}ZRAM:${RESET} ${ZRAM_STAT}"
echo -e " ${BOLD}${MAUVE}STORAGE/AI   ${RESET} ${MUTED}│${RESET} ${WHITE}NVMe:${RESET} ${DISK_FREE} ${MUTED}│${RESET} ${WHITE}AI Core:${RESET} ${AI_STATUS}"
echo ""

# ─── 3. Fastfetch / System Profiler ───────────────────────────────────────────
if command -v fastfetch >/dev/null 2>&1; then
    fastfetch --structure Title:OS:Kernel:Uptime:Packages:Shell:DE:WM:Terminal:Memory:Disk --logo-color-1 "magenta" --logo-color-2 "blue"
fi

# ─── 4. Interactive Shell Switcher Prompt ─────────────────────────────────────
# Only ask if interactive and user hasn't locked in their preference
PREF_SHELL_FILE="$HOME/.config/palexus/preferred_shell"
if [[ ! -f "$PREF_SHELL_FILE" ]] && [[ -t 0 ]]; then
    echo -e "${VIOLET}Select your preferred primary shell experience:${RESET}"
    echo -e "  ${BOLD}[1]${RESET} ${WHITE}Fish Shell${RESET} ${MUTED}(Rich autosuggestions, syntax highlights, web themes)${RESET}"
    echo -e "  ${BOLD}[2]${RESET} ${WHITE}Oh-My-Bash / Bash${RESET} ${MUTED}(Standard POSIX, scripts, aliases)${RESET}"
    echo -e "  ${BOLD}[3]${RESET} ${WHITE}Wave Terminal / Parallel Agent Mode${RESET}"
    echo -e "  ${MUTED}[Press Enter to keep current shell ($SHELL)]${RESET}"
    read -t 10 -p "Choice (1-3): " SHELL_CHOICE
    
    case "$SHELL_CHOICE" in
        1)
            mkdir -p "$(dirname "$PREF_SHELL_FILE")"
            echo "fish" > "$PREF_SHELL_FILE"
            if command -v fish >/dev/null 2>&1; then
                exec fish
            fi
            ;;
        2)
            mkdir -p "$(dirname "$PREF_SHELL_FILE")"
            echo "bash" > "$PREF_SHELL_FILE"
            ;;
        3)
            mkdir -p "$(dirname "$PREF_SHELL_FILE")"
            echo "wave" > "$PREF_SHELL_FILE"
            if command -v wsh >/dev/null 2>&1 || command -v wave >/dev/null 2>&1; then
                exec wsh || exec wave
            fi
            ;;
        *)
            # No change
            ;;
    esac
fi
