# TokenEconomizer Setup for All LLM Interfaces

This guide configures TokenEconomizer to optimize costs across Claude Code, ChatGPT, Copilot, and other AI agents working with PalexusOS.

## Overview

TokenEconomizer learns from your development sessions and applies three cost-reduction mechanisms:

1. **Micro-skills**: Learn repository facts (build commands, paths, patterns) once, reuse across sessions
2. **Tool pruning**: Disable tools not used in your workflow
3. **Failure-loop intervention**: Detect stuck sessions and redirect before wasting tokens

**Estimated savings**: 18–30% cost reduction across all agents on PalexusOS tasks.

## Installation

### 1. Install TokenEconomizer

```bash
pip install tokeneconomizer
```

Verify installation:
```bash
te --version
```

### 2. Configuration Files

TokenEconomizer reads from `~/.tokeneconomizer/` and `.tokeneconomizer/` (project-specific):

```
~/.tokeneconomizer/              # Global config (all projects)
└── global.toml                  # Global settings

/path/to/palexusOS/.tokeneconomizer/  # Project config
├── config.toml                  # Main PalexusOS config
├── multi-llm.toml              # Multi-agent configuration
└── facts.json                  # Learned facts (auto-generated)
```

## Configuration

### Global Setup (all projects)

Create `~/.tokeneconomizer/global.toml`:

```toml
[global]
auto_learn = true
track_costs = true
report_format = "json"

[cache]
cache_location = "~/.tokeneconomizer"
shared_cache = true
```

### PalexusOS-Specific Setup

The project includes two configuration files:

1. **config.toml** — Single-agent (Claude Code) optimization
2. **multi-llm.toml** — Multi-agent optimization (all LLMs)

Use the multi-LLM config for best results across all interfaces:

```bash
# Activate multi-LLM configuration
cp .tokeneconomizer/multi-llm.toml ~/.tokeneconomizer/active-palexusos.toml
```

## Claude Code Integration

TokenEconomizer works automatically with Claude Code. To verify:

```bash
# Check micro-skills learned
te microskills list

# Check tool pruning status
te toolprune status

# View cost report
te report view
```

### Enable in Claude Code

Add to your Claude Code project (creates `.claude/settings.json`):

```json
{
  "tokeneconomizer": {
    "enabled": true,
    "config": ".tokeneconomizer/multi-llm.toml",
    "auto_learn": true,
    "report_frequency": "per_session"
  }
}
```

## Claude Chat Integration

TokenEconomizer is compatible with Claude Chat via the design system artifact:

https://claude.ai/artifact/DmyLwKLjPa6hRhsrUDofAm

When working on PalexusOS in chat:
1. Reference the design system artifact
2. Mention repository structure
3. TokenEconomizer learns from your chat sessions (if enabled)

## GitHub Copilot Integration

### VS Code

1. Install Copilot extension
2. Create `.copilotrc` in PalexusOS root:

```toml
[tokeneconomizer]
enabled = true
config = ".tokeneconomizer/multi-llm.toml"
```

3. Copilot will use learned facts automatically

### Copilot CLI

TokenEconomizer optimizes `gh copilot` commands:

```bash
# Copilot automatically uses learned facts
gh copilot suggest "how to build palexus package"

# View savings
te report view --filter "copilot-cli"
```

## Learned Facts

TokenEconomizer learns and applies these facts automatically:

### Build & Test
- **Command**: `makepkg -si` — Build Arch packages in isolated chroot
- **Command**: `./build/verify-gates.sh` — Run 261-gate verification suite
- **Command**: `./build/build-iso.sh` — Build reproducible ISO

### Design System
- **Path**: `docs/design-system/` — Design token definitions
- **File**: `docs/design-system/tokens.json` — Design tokens (colors, typography, spacing)
- **File**: `docs/design-system/tokens.css` — CSS variables for all UI elements
- **Command**: `./scripts/generate-designs.sh` — Generate theme files from tokens

### Repository
- **Language**: Python, Bash, PKGBUILD
- **Layout**: packages/ (Arch packages), build/ (ISO), overlay/ (config), docs/ (docs)
- **Font**: JetBrains Mono Nerd Font (monospace)
- **Color**: #cba6f7 (Electric Mauve, primary accent)

### Git Workflow
- **Pattern**: Create feature branch, commit with attribution, push to main
- **Command**: `git add docs/design-system/ && git commit && git push -u origin main`

## Cost Tracking

### View Costs

```bash
# Total costs
te report view --aggregate

# Per-session costs
te report view --per-session

# By agent
te report view --by-agent

# Export to CSV
te report export costs.csv
```

### Cost Breakdown

Example output:

```
Session 1: $0.50 (baseline)
Session 2: $0.42 (16% savings via micro-skills)
Session 3: $0.35 (30% savings via tool pruning + facts)
Session 4: $0.38 (24% savings)

Average savings: 23% across 4 sessions
Cumulative saved: $0.47
```

## Monitoring & Optimization

### Check Status

```bash
# Overall status
te status

# Details
te status --verbose

# Watch mode (live updates)
te status --watch
```

### Auto-Learn Progress

TokenEconomizer learns after 3 confirmed sessions:

```bash
# Check learning progress
te microskills list --progress

# See confidence scores
te microskills list --confidence
```

### Tool Usage Analysis

```bash
# Which tools are being used
te toolprune analyze

# Which tools can be pruned
te toolprune suggest

# Apply suggestions
te toolprune apply
```

## Failure Prevention

TokenEconomizer detects stuck loops and suggests redirects:

```bash
# View failure patterns
te failures list

# See redirect history
te failures redirects

# Manual redirect (if needed)
te redirect --reason "trying_different_approach"
```

## Multi-Agent Coordination

When using multiple LLMs on the same task:

### Shared Learned Facts

All agents share learned facts:

```bash
# Facts learned by Claude Code
te microskills list --source claude_code

# Facts shared with Copilot
te microskills list --source copilot_cli

# Global facts (used by all)
te microskills list --global
```

### Cross-Agent Cost Comparison

```bash
# Cost comparison
te report compare --agents claude_code copilot_cli

# Which agent is most efficient
te report efficiency --by-agent
```

### Coordinated Workflow

Optimal workflow for maximum savings:

1. **Claude Code** (long, complex tasks) — Uses all micro-skills
2. **Copilot CLI** (quick terminal tasks) — Uses minimal learned facts
3. **Claude Chat** (research, documentation) — Uses fact references
4. **Cursor/VS Code** (editing) — Uses tool pruning

Each session's learnings improve the next agent's efficiency.

## Best Practices

### 1. Session Context

Include repository context in your prompt:

```
"Working on PalexusOS (Arch-based AI OS). 
See design system: docs/design-system/
Use these known commands: makepkg, ./build/verify-gates.sh"
```

### 2. Enable Learning

Always let TokenEconomizer learn:

```bash
# Don't disable learning
te config set auto_learn true
```

### 3. Regular Reporting

Check savings regularly:

```bash
# Weekly review
te report view --since "7 days ago"

# Monthly summary
te report view --since "30 days ago"
```

### 4. Fact Verification

Verify learned facts are correct:

```bash
# Review facts
te microskills list --verbose

# Update if needed
te microskills edit <fact-name>
```

## Troubleshooting

### Facts Not Applied

```bash
# Check if learning is enabled
te config get auto_learn

# Check fact confidence
te microskills list --confidence

# Manually apply fact
te microskills apply <fact-name>
```

### Tools Not Pruned

```bash
# Analyze tool usage
te toolprune analyze

# Check pruning threshold
te config get tool_prune_threshold

# Force tool removal
te toolprune remove <tool-name>
```

### No Cost Reduction

```bash
# Check if first 3 sessions completed
te microskills list --progress

# Verify facts are correct
te microskills list --verbose

# Check failure redirects
te failures redirects

# Enable debug mode
te config set debug true
```

## Advanced Configuration

### Custom Facts

Add project-specific facts:

```bash
# Add fact
te microskills add \
  --name "custom-build" \
  --command "cd packages/palexus-core && makepkg -si" \
  --context "Build core package"

# Verify
te microskills list
```

### Custom Tool Pruning

Customize which tools to keep/prune:

```toml
[tools_to_keep]
read = true
edit = true
bash = true

[tools_to_prune]
artifact = "rarely"
browser = "never"
```

### Failure Redirects

Add custom redirects for common failures:

```bash
te failures add \
  --pattern "PKGBUILD error" \
  --redirect "Check PKGBUILD syntax: packages/*/PKGBUILD" \
  --redirect "Review Arch guidelines at archlinux.org"
```

## Integration with Design System

TokenEconomizer works with the design system to optimize styling tasks:

```bash
# Facts about design system
te microskills list | grep -i design

# Design-related tools
te toolprune analyze --filter design
```

When working on UI components:

```
"Building Qt6 HUD component for PalexusOS.
Colors: use tokens from docs/design-system/tokens.json
Font: JetBrains Mono Nerd Font
Colors: #cba6f7 (mauve), #1e1e2e (surface)"
```

## Resources

- **TokenEconomizer Docs**: https://github.com/microsoft/tokeneconomizer
- **Paper**: https://arxiv.org/abs/2610.22732
- **Project Page**: https://tokeneconomizer.github.io
- **Config Reference**: `.tokeneconomizer/config.toml`
- **Multi-LLM Config**: `.tokeneconomizer/multi-llm.toml`

## Questions?

For TokenEconomizer issues:
- GitHub: https://github.com/microsoft/tokeneconomizer/issues
- Discussions: https://github.com/microsoft/tokeneconomizer/discussions

For PalexusOS integration:
- Design System: `docs/design-system/README.md`
- Integration Guide: `docs/design-system/INTEGRATION.md`
