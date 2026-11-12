#!/usr/bin/env bash
# ==============================================================================
# Wave Pipeline & Ollama CI Automation Harness
# SynapseOS / AI BRAIN
#
# Provides turnkey integration between Wave Terminal sessions, local Ollama
# coding models (qwen2.5-coder:7b, hermes3-abliterated, qwen-coder-abliterated),
# and parallel background CI / test suites.
# ==============================================================================

set -euo pipefail

# Base Paths
AI_BRAIN="/home/ebaymlay/Desktop/AI BRAIN"
SYNAPSE_DIR="${AI_BRAIN}/synapseOS"
WAVE_CONFIG_DIR="${HOME}/.config/waveterm"
WAVE_SETUP_DIR="${AI_BRAIN}/wave-setup"
OLLAMA_HOST="${OLLAMA_HOST:-http://localhost:11434}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[WAVE-PIPELINE]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ------------------------------------------------------------------------------
# Check Dependencies
# ------------------------------------------------------------------------------
check_prereqs() {
    log_info "Verifying pipeline prerequisites..."
    local missing=0

    for cmd in curl jq; do
        if ! command -v "$cmd" &>/dev/null; then
            log_error "Missing required CLI tool: $cmd"
            missing=1
        fi
    done

    if [ $missing -eq 1 ]; then
        exit 1
    fi

    # Check Ollama connectivity
    if curl -s "${OLLAMA_HOST}/api/tags" &>/dev/null; then
        log_success "Ollama daemon connected at ${OLLAMA_HOST}"
    else
        log_warn "Ollama daemon is not responding at ${OLLAMA_HOST}"
    fi

    # Check Wave binary & symlinks
    if [ -x "/opt/Wave/waveterm" ] || command -v waveterm &>/dev/null; then
        log_success "Wave Terminal installation found"
    else
        log_warn "Wave Terminal executable not found in /opt/Wave"
    fi

    if command -v wsh &>/dev/null; then
        log_success "Wave Shell CLI (wsh) available in PATH: $(which wsh)"
    else
        log_warn "wsh command line tool not in PATH (installing symlink to /usr/local/bin recommended)"
    fi
}

# ------------------------------------------------------------------------------
# Sync Wave AI & Widgets Config
# ------------------------------------------------------------------------------
sync_wave_configs() {
    log_info "Synchronizing Wave Terminal configs with Ollama models and Synapse tools..."
    mkdir -p "${WAVE_CONFIG_DIR}" "${WAVE_SETUP_DIR}/config"

    python3 - << 'EOF'
import json
import os

configs = [
    "/home/ebaymlay/.config/waveterm/waveai.json",
    "/home/ebaymlay/Desktop/AI BRAIN/wave-setup/config/waveai.json"
]

models = {
    "ollama@qwen25-coder": {
        "display:name": "Local: Qwen 2.5 Coder 7B (Ollama)",
        "display:order": 12,
        "display:icon": "code",
        "display:description": "qwen2.5-coder:7b on localhost:11434 - Code generation & sprint logic",
        "ai:provider": "custom",
        "ai:apitype": "openai-chat",
        "ai:model": "qwen2.5-coder:7b",
        "ai:thinkinglevel": "medium",
        "ai:endpoint": "http://localhost:11434/v1/chat/completions",
        "ai:apitoken": "ollama",
        "ai:capabilities": ["tools"]
    },
    "ollama@hermes3": {
        "display:name": "Local: Hermes 3 Abliterated (Ollama)",
        "display:order": 13,
        "display:icon": "shield-halved",
        "display:description": "hermes3-abliterated on localhost:11434 - Uncensored instruction & reasoning",
        "ai:provider": "custom",
        "ai:apitype": "openai-chat",
        "ai:model": "hermes3-abliterated:latest",
        "ai:thinkinglevel": "medium",
        "ai:endpoint": "http://localhost:11434/v1/chat/completions",
        "ai:apitoken": "ollama",
        "ai:capabilities": ["tools"]
    }
}

for cfg_path in configs:
    data = {}
    if os.path.exists(cfg_path):
        try:
            with open(cfg_path, "r") as f:
                data = json.load(f)
        except Exception:
            pass
    data.update(models)
    os.makedirs(os.path.dirname(cfg_path), exist_ok=True)
    with open(cfg_path, "w") as f:
        json.dump(data, f, indent=2)

# Update widgets
widget_paths = [
    "/home/ebaymlay/.config/waveterm/widgets.json",
    "/home/ebaymlay/Desktop/AI BRAIN/wave-setup/config/widgets.json"
]

widgets = {
    "ci@synapse": {
        "display:order": 10,
        "icon": "shield-check",
        "color": "#10b981",
        "label": "synapse-ci",
        "description": "SynapseOS Background CI & Pytest Guard",
        "blockdef": {
            "meta": {
                "view": "term",
                "controller": "cmd",
                "cmd": "bash -ic 'cd \"/home/ebaymlay/Desktop/AI BRAIN/synapseOS\" && \"/home/ebaymlay/Desktop/AI BRAIN/synapseOS/tools/wave-pipeline.sh\" ci-watch'",
                "cmd:cwd": "/home/ebaymlay/Desktop/AI BRAIN/synapseOS",
                "cmd:clearonstart": True
            }
        }
    },
    "sprint@parallel": {
        "display:order": 11,
        "icon": "bolt",
        "color": "#f59e0b",
        "label": "dev-sprint",
        "description": "SynapseOS Parallel Dev Sprint Runner",
        "blockdef": {
            "meta": {
                "view": "term",
                "controller": "cmd",
                "cmd": "bash -ic 'cd \"/home/ebaymlay/Desktop/AI BRAIN/synapseOS\" && \"/home/ebaymlay/Desktop/AI BRAIN/synapseOS/tools/wave-pipeline.sh\" sprint'",
                "cmd:cwd": "/home/ebaymlay/Desktop/AI BRAIN/synapseOS",
                "cmd:clearonstart": True
            }
        }
    }
}

for w_path in widget_paths:
    wdata = {}
    if os.path.exists(w_path):
        try:
            with open(w_path, "r") as f:
                wdata = json.load(f)
        except Exception:
            pass
    wdata.update(widgets)
    os.makedirs(os.path.dirname(w_path), exist_ok=True)
    with open(w_path, "w") as f:
        json.dump(wdata, f, indent=2)

print("Wave configuration sync complete.")
EOF
    log_success "Wave configs synchronized with Ollama endpoints & widgets."
}

# ------------------------------------------------------------------------------
# Ollama Query Utility
# ------------------------------------------------------------------------------
query_ollama() {
    local model="${1:-qwen2.5-coder:7b}"
    local prompt="${2:-}"

    if [ -z "$prompt" ]; then
        if [ ! -t 0 ]; then
            prompt="$(cat)"
        else
            log_error "Prompt cannot be empty."
            return 1
        fi
    fi

    log_info "Prompting Ollama model '${model}'..."
    local payload
    payload=$(jq -n --arg m "$model" --arg p "$prompt" '{
        model: $m,
        prompt: $p,
        stream: false
    }')

    curl -s -X POST "${OLLAMA_HOST}/api/generate" \
        -H "Content-Type: application/json" \
        -d "$payload" | jq -r '.response // empty'
}

# ------------------------------------------------------------------------------
# Background CI Verification Runner
# ------------------------------------------------------------------------------
run_ci() {
    log_info "Starting SynapseOS CI Verification Suite..."
    local test_dir="${SYNAPSE_DIR}/tests"
    local log_file="${SYNAPSE_DIR}/build/ci-run.log"
    mkdir -p "${SYNAPSE_DIR}/build"

    echo "=== SynapseOS CI Run: $(date) ===" > "$log_file"

    if [ -d "$test_dir" ]; then
        log_info "Executing pytest suite across: $test_dir"
        if pytest "$test_dir" -v --tb=short 2>&1 | tee -a "$log_file"; then
            log_success "All SynapseOS CI tests PASSED!"
            return 0
        else
            log_error "SynapseOS CI tests FAILED! See details in: $log_file"
            return 1
        fi
    else
        log_warn "Test directory $test_dir not found; skipping pytest."
        return 0
    fi
}

# ------------------------------------------------------------------------------
# Continuous CI Watch Loop
# ------------------------------------------------------------------------------
run_ci_watch() {
    log_info "Starting CI watch monitor (Press Ctrl+C to terminate)..."
    while true; do
        clear || true
        echo -e "${CYAN}====================================================${NC}"
        echo -e "${CYAN} SynapseOS Wave Terminal Background CI Sentinel     ${NC}"
        echo -e "${CYAN} $(date)                                            ${NC}"
        echo -e "${CYAN}====================================================${NC}"
        run_ci || true
        echo -e "\n${YELLOW}Sleeping 30s before next verification cycle...${NC}"
        sleep 30
    done
}

# ------------------------------------------------------------------------------
# Parallel Dev Sprint Runner
# ------------------------------------------------------------------------------
run_sprint() {
    log_info "Initializing Parallel Dev Sprint Orchestrator..."

    echo -e "${CYAN}====================================================${NC}"
    echo -e "${CYAN} SynapseOS Parallel Dev Sprint Engine               ${NC}"
    echo -e "${CYAN}====================================================${NC}"

    local sprint_dir="${SYNAPSE_DIR}/build/sprints/$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$sprint_dir"

    # Step 1: Pre-flight CI
    log_info "[Sprint Step 1/3] Running pre-flight CI baseline..."
    run_ci > "${sprint_dir}/ci_baseline.log" 2>&1 &
    local ci_pid=$!

    # Step 2: Query Ollama sprint summary
    log_info "[Sprint Step 2/3] Checking Ollama model health..."
    local prompt="Provide a 1-sentence affirmation that the SynapseOS development sprint is operational."
    query_ollama "qwen2.5-coder:7b" "$prompt" > "${sprint_dir}/ollama_response.txt" 2>&1 &
    local ollama_pid=$!

    # Await parallel background jobs
    log_info "Awaiting background sprint jobs (PID $ci_pid, PID $ollama_pid)..."
    wait $ci_pid && log_success "Pre-flight CI completed successfully." || log_warn "CI baseline had warnings/failures (check ${sprint_dir}/ci_baseline.log)."
    wait $ollama_pid && log_success "Ollama sprint agent responded." || log_warn "Ollama query had issues."

    log_success "Parallel sprint batch complete. Artifacts saved in: $sprint_dir"
}

# ------------------------------------------------------------------------------
# Launch Wave Workspace Live View
# ------------------------------------------------------------------------------
launch_wave_workspace() {
    log_info "Launching Wave Terminal live workspace view..."
    if command -v waveterm &>/dev/null; then
        waveterm --no-sandbox >/dev/null 2>&1 &
        log_success "Wave Terminal GUI dispatched."
    elif [ -x "/opt/Wave/waveterm" ]; then
        /opt/Wave/waveterm --no-sandbox >/dev/null 2>&1 &
        log_success "Wave Terminal GUI dispatched via /opt/Wave/waveterm."
    else
        log_error "Could not find Wave Terminal executable."
        return 1
    fi
}

# ------------------------------------------------------------------------------
# Main Entry Point
# ------------------------------------------------------------------------------
usage() {
    echo "Usage: $0 {check|sync|query <model> <prompt>|ci|ci-watch|sprint|wave|all}"
    echo ""
    echo "Commands:"
    echo "  check         Check environment, wsh, Wave, and Ollama status"
    echo "  sync          Synchronize Wave configuration files (waveai.json & widgets.json)"
    echo "  query         Query local Ollama models (e.g. qwen2.5-coder:7b or hermes3-abliterated)"
    echo "  ci            Run full SynapseOS pytest suite once"
    echo "  ci-watch      Run continuous CI verification loop for Wave split-pane view"
    echo "  sprint        Execute parallel dev sprint pipeline (CI + AI synthesis)"
    echo "  wave          Launch Wave Terminal live workspace"
    echo "  all           Run checks, synchronize configs, run CI, and trigger sprint"
    exit 1
}

case "${1:-}" in
    check)
        check_prereqs
        ;;
    sync)
        sync_wave_configs
        ;;
    query)
        shift
        query_ollama "${1:-qwen2.5-coder:7b}" "${2:-}"
        ;;
    ci)
        run_ci
        ;;
    ci-watch)
        run_ci_watch
        ;;
    sprint)
        run_sprint
        ;;
    wave)
        launch_wave_workspace
        ;;
    all)
        check_prereqs
        sync_wave_configs
        run_ci
        run_sprint
        ;;
    *)
        usage
        ;;
esac
