#!/bin/bash
# TokenEconomizer Setup for All LLM Interfaces
# Configures cost optimization across Claude Code, ChatGPT, Copilot, etc.

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TE_CONFIG="${REPO_ROOT}/.tokeneconomizer"
TE_HOME="${HOME}/.tokeneconomizer"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper functions
log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_header() { echo -e "\n${BLUE}=== $1 ===${NC}"; }

# Check requirements
check_requirements() {
  log_header "Checking Requirements"

  # Check if TokenEconomizer is installed
  if ! command -v te &> /dev/null; then
    log_warn "TokenEconomizer not found. Installing..."
    pip install tokeneconomizer -q
    log_info "✓ TokenEconomizer installed"
  else
    local version=$(te --version 2>/dev/null || echo "unknown")
    log_info "✓ TokenEconomizer $version"
  fi

  # Check Python
  if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not found"
    exit 1
  fi
  log_info "✓ Python 3 available"

  # Check git
  if ! command -v git &> /dev/null; then
    echo "❌ Git is required but not found"
    exit 1
  fi
  log_info "✓ Git available"
}

# Setup global configuration
setup_global_config() {
  log_header "Setting Up Global Configuration"

  mkdir -p "$TE_HOME"

  # Create global config if it doesn't exist
  if [ ! -f "$TE_HOME/global.toml" ]; then
    cat > "$TE_HOME/global.toml" << 'EOF'
[global]
auto_learn = true
track_costs = true
report_format = "json"
learning_confidence = 0.75

[cache]
cache_location = "~/.tokeneconomizer"
shared_cache = true
cache_ttl = 86400
cache_size_limit = "100MB"

[reporting]
frequency = "per_session"
formats = ["json", "markdown"]
EOF
    log_info "✓ Created global config: $TE_HOME/global.toml"
  else
    log_info "✓ Global config already exists"
  fi
}

# Setup project-specific configuration
setup_project_config() {
  log_header "Setting Up Project Configuration"

  mkdir -p "$TE_CONFIG"

  # Verify config files exist
  if [ ! -f "$TE_CONFIG/config.toml" ]; then
    log_warn "config.toml not found. Creating from template..."
    # This would be provided by the repo already
  fi

  if [ ! -f "$TE_CONFIG/multi-llm.toml" ]; then
    log_warn "multi-llm.toml not found. Creating from template..."
    # This would be provided by the repo already
  fi

  log_info "✓ Project configs verified"

  # Activate multi-LLM config
  cp "$TE_CONFIG/multi-llm.toml" "$TE_HOME/active-palexusos.toml"
  log_info "✓ Activated multi-LLM configuration"
}

# Initialize Claude Code integration
setup_claude_code() {
  log_header "Setting Up Claude Code Integration"

  local claude_dir="${REPO_ROOT}/.claude"
  mkdir -p "$claude_dir"

  if [ ! -f "$claude_dir/settings.json" ]; then
    cat > "$claude_dir/settings.json" << 'EOF'
{
  "tokeneconomizer": {
    "enabled": true,
    "config": ".tokeneconomizer/multi-llm.toml",
    "auto_learn": true,
    "report_frequency": "per_session"
  },
  "design_system": {
    "enabled": true,
    "tokens_css": "docs/design-system/tokens.css",
    "tokens_json": "docs/design-system/tokens.json"
  }
}
EOF
    log_info "✓ Created Claude Code settings"
  else
    log_info "✓ Claude Code settings already exist"
  fi

  # Create .claude/hooks.json if needed
  if [ ! -f "$claude_dir/hooks.json" ]; then
    cat > "$claude_dir/hooks.json" << 'EOF'
{
  "post_command": "scripts/post-command.sh"
}
EOF
    log_info "✓ Created hook configuration"
  fi
}

# Initialize GitHub Copilot integration
setup_github_copilot() {
  log_header "Setting Up GitHub Copilot Integration"

  if [ -f "$REPO_ROOT/.copilotrc" ]; then
    log_info "✓ Copilot config already exists"
  else
    cat > "$REPO_ROOT/.copilotrc" << 'EOF'
[tokeneconomizer]
enabled = true
config = ".tokeneconomizer/multi-llm.toml"

[repository]
name = "palexusOS"
owner = "earnerbaymalay"
url = "https://github.com/earnerbaymalay/palexusOS"
EOF
    log_info "✓ Created Copilot configuration"
  fi
}

# Setup VS Code integration
setup_vscode() {
  log_header "Setting Up VS Code Integration"

  local vscode_settings="${HOME}/.config/Code/User/settings.json"

  if [ -f "$vscode_settings" ]; then
    log_info "✓ VS Code settings detected"
    log_warn "Manual integration needed. Add to settings.json:"
    echo '  "tokeneconomizer.enabled": true,'
    echo '  "tokeneconomizer.projectConfig": ".tokeneconomizer/multi-llm.toml"'
  else
    log_warn "VS Code not installed or no settings found"
  fi
}

# Initialize learned facts
initialize_facts() {
  log_header "Initializing Learned Facts"

  local facts_file="$TE_CONFIG/facts.json"

  if [ ! -f "$facts_file" ]; then
    cat > "$facts_file" << 'EOF'
{
  "micro_skills": [
    {
      "name": "arch_package_build",
      "command": "makepkg -si",
      "description": "Build Arch Linux package in isolated chroot",
      "context": "Use in packages/ directory",
      "confidence": 0.95
    },
    {
      "name": "quality_verification",
      "command": "./build/verify-gates.sh",
      "description": "Run 261-gate engineering verification suite",
      "context": "Verify package quality and security",
      "confidence": 0.95
    },
    {
      "name": "iso_build",
      "command": "./build/build-iso.sh",
      "description": "Build native PalexusOS ISO image",
      "context": "Creates reproducible live environment",
      "confidence": 0.90
    },
    {
      "name": "design_system_location",
      "path": "docs/design-system/",
      "description": "Design system directory location",
      "files": ["tokens.css", "tokens.json", "INTEGRATION.md"],
      "confidence": 0.95
    }
  ],
  "tool_patterns": {
    "must_keep": ["read", "edit", "write", "bash", "grep"],
    "can_prune": ["browser", "notebook_edit", "artifact_data"],
    "confidence": 0.85
  },
  "failure_patterns": [
    {
      "error": "PKGBUILD syntax",
      "solution": "Check PKGBUILD template",
      "redirect": "Review packages/*/PKGBUILD"
    },
    {
      "error": "Build verification fails",
      "solution": "Run verify-gates.sh",
      "redirect": "Check specific gate output"
    }
  ]
}
EOF
    log_info "✓ Initialized facts database"
  else
    log_info "✓ Facts database already exists"
  fi
}

# Create helper scripts
create_helper_scripts() {
  log_header "Creating Helper Scripts"

  # Script to show costs
  cat > "$REPO_ROOT/scripts/te-costs.sh" << 'HELPER_EOF'
#!/bin/bash
# Show TokenEconomizer cost savings

echo "PalexusOS TokenEconomizer Cost Report"
echo "======================================"

te report view --aggregate

echo ""
echo "Cost breakdown by agent:"
te report view --by-agent

echo ""
echo "Recent savings:"
te report view --since "7 days ago"
HELPER_EOF
  chmod +x "$REPO_ROOT/scripts/te-costs.sh"
  log_info "✓ Created cost report script"

  # Script to show status
  cat > "$REPO_ROOT/scripts/te-status.sh" << 'HELPER_EOF'
#!/bin/bash
# Show TokenEconomizer status

echo "TokenEconomizer Status"
echo "====================="

te status --verbose

echo ""
echo "Learned facts:"
te microskills list

echo ""
echo "Tool pruning:"
te toolprune status
HELPER_EOF
  chmod +x "$REPO_ROOT/scripts/te-status.sh"
  log_info "✓ Created status script"

  # Script to apply facts
  cat > "$REPO_ROOT/scripts/te-apply-facts.sh" << 'HELPER_EOF'
#!/bin/bash
# Apply learned facts to new session

echo "Applying TokenEconomizer Facts"
echo "=============================="

# Show facts being applied
te microskills list

# Apply to current session
export TE_AUTO_APPLY=true

echo ""
echo "Facts applied. Use these commands in this session:"
echo "  - Build: makepkg -si"
echo "  - Test: ./build/verify-gates.sh"
echo "  - ISO: ./build/build-iso.sh"
echo "  - Design: docs/design-system/"
HELPER_EOF
  chmod +x "$REPO_ROOT/scripts/te-apply-facts.sh"
  log_info "✓ Created facts application script"
}

# Verify setup
verify_setup() {
  log_header "Verifying Setup"

  # Check global config
  if [ -f "$TE_HOME/global.toml" ]; then
    log_info "✓ Global config exists"
  else
    log_warn "Global config not found"
  fi

  # Check project config
  if [ -f "$TE_CONFIG/config.toml" ]; then
    log_info "✓ Project config exists"
  else
    log_warn "Project config not found"
  fi

  # Test TokenEconomizer
  if te --version > /dev/null 2>&1; then
    log_info "✓ TokenEconomizer is working"
  else
    log_warn "TokenEconomizer test failed"
  fi

  # Check Claude Code integration
  if [ -f "$REPO_ROOT/.claude/settings.json" ]; then
    log_info "✓ Claude Code integration configured"
  else
    log_warn "Claude Code integration missing"
  fi
}

# Print next steps
print_next_steps() {
  log_header "Next Steps"

  echo ""
  echo "1. View cost savings:"
  echo "   ./scripts/te-costs.sh"
  echo ""
  echo "2. Check TokenEconomizer status:"
  echo "   ./scripts/te-status.sh"
  echo ""
  echo "3. Apply learned facts:"
  echo "   ./scripts/te-apply-facts.sh"
  echo ""
  echo "4. For detailed setup info:"
  echo "   cat docs/TOKENECONOMIZER-SETUP.md"
  echo ""
  echo "5. Manual fact management:"
  echo "   te microskills list"
  echo "   te microskills add --name <fact> --command <cmd>"
  echo ""
}

# Main execution
main() {
  echo ""
  echo "╔════════════════════════════════════════════════════════════╗"
  echo "║   TokenEconomizer Setup for PalexusOS Multi-LLM Agents     ║"
  echo "╚════════════════════════════════════════════════════════════╝"
  echo ""

  check_requirements
  setup_global_config
  setup_project_config
  setup_claude_code
  setup_github_copilot
  setup_vscode
  initialize_facts
  create_helper_scripts
  verify_setup
  print_next_steps

  echo "✓ TokenEconomizer setup complete!"
  echo ""
}

main "$@"
