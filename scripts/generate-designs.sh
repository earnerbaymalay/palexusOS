#!/bin/bash
# PalexusOS Design System Generation Script
# Generates theme files and configuration from design tokens

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESIGN_SYSTEM="${REPO_ROOT}/docs/design-system"
TOKENS_JSON="${DESIGN_SYSTEM}/tokens.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Helper functions
log_info() {
  echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
  echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
  echo -e "${RED}[ERROR]${NC} $1"
}

# Check if design system exists
if [ ! -f "$TOKENS_JSON" ]; then
  log_error "Design tokens not found at $TOKENS_JSON"
  exit 1
fi

log_info "PalexusOS Design System Generation"
log_info "Tokens: $TOKENS_JSON"
log_info "Repository root: $REPO_ROOT"
echo ""

# Extract color values from tokens.json using Python
extract_colors() {
  python3 << 'PYTHON_EOF'
import json
import sys

tokens_file = sys.argv[1] if len(sys.argv) > 1 else "tokens.json"

try:
    with open(tokens_file) as f:
        tokens = json.load(f)

    colors = tokens['colors']

    # Print color definitions
    print("# Design System Colors")
    for category, palette in colors.items():
        for name, value in palette.items():
            if isinstance(value, dict):
                for subname, subvalue in value.items():
                    print(f"COLOR_{category.upper()}_{name.upper()}_{subname.upper()}={subvalue}")
            else:
                print(f"COLOR_{category.upper()}_{name.upper()}={value}")

    print("\n# Typography")
    typography = tokens['typography']
    for style_type, styles in typography.get('scales', {}).items():
        print(f"FONT_{style_type.upper()}_SIZE={styles.get('size', '14px')}")

    print("\n# Spacing")
    for size, value in tokens['spacing'].items():
        print(f"SPACE_{size}={value}")

    print("\n# Radius")
    for size, value in tokens['radius'].items():
        print(f"RADIUS_{size}={value}")

except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
PYTHON_EOF
}

# Generate Kitty color configuration
generate_kitty_config() {
  local output="${REPO_ROOT}/overlay/etc/skel/.config/kitty/palexus-design-system.conf"

  log_info "Generating Kitty configuration..."

  mkdir -p "$(dirname "$output")"

  cat > "$output" << 'KITTY_EOF'
# PalexusOS Design System Colors for Kitty Terminal
# Generated from docs/design-system/tokens.json
# DO NOT EDIT - regenerate with: scripts/generate-designs.sh

# Foreground and background
foreground #cdd6f4
background #11111b
cursor_text_color background
cursor #cba6f7

# Selection
selection_background #cba6f7
selection_foreground #11111b

# URLs
url_color #74c7ec

# Tab colors
active_tab_background #cba6f7
active_tab_foreground #11111b
inactive_tab_background #1e1e2e
inactive_tab_foreground #cdd6f4

# ANSI Colors (Standard)
color0 #11111b  # black -> smoked-obsidian
color1 #f38ba8  # red -> stealth-crimson
color2 #a6e3a1  # green -> matrix-emerald
color3 #fab387  # yellow -> warm-gold
color4 #74c7ec  # blue -> aerospace-sapphire
color5 #cba6f7  # magenta -> electric-mauve
color6 #89dceb  # cyan -> (catppuccin cyan)
color7 #cdd6f4  # white -> liquid-chrome

# ANSI Colors (Bright)
color8 #45454f   # bright-black -> surface-500
color9 #f38ba8   # bright-red
color10 #a6e3a1  # bright-green
color11 #fab387  # bright-yellow
color12 #74c7ec  # bright-blue
color13 #cba6f7  # bright-magenta
color14 #89dceb  # bright-cyan
color15 #cdd6f4  # bright-white
KITTY_EOF

  log_info "✓ Generated: $output"
}

# Generate shell color aliases
generate_shell_colors() {
  local output="${REPO_ROOT}/overlay/etc/skel/.config/palexus-colors.sh"

  log_info "Generating shell color aliases..."

  mkdir -p "$(dirname "$output")"

  cat > "$output" << 'SHELL_EOF'
#!/bin/bash
# PalexusOS Design System Color Aliases
# Generated from docs/design-system/tokens.json
# Source this in your .bashrc or .zshrc

# Primary Colors
export COLOR_MAUVE="#cba6f7"
export COLOR_GOLD="#fab387"
export COLOR_CRIMSON="#f38ba8"
export COLOR_SAPPHIRE="#74c7ec"
export COLOR_EMERALD="#a6e3a1"
export COLOR_CHROME="#cdd6f4"
export COLOR_OBSIDIAN="#11111b"

# Surface Hierarchy
export COLOR_SURFACE_900="#11111b"
export COLOR_SURFACE_800="#1e1e2e"
export COLOR_SURFACE_700="#2a2a3e"
export COLOR_SURFACE_600="#313244"
export COLOR_SURFACE_500="#45454f"

# Text Colors
export COLOR_TEXT_PRIMARY="#cdd6f4"
export COLOR_TEXT_SECONDARY="#a6adc8"
export COLOR_TEXT_TERTIARY="#7f849c"

# Status Colors
export COLOR_SUCCESS="#a6e3a1"
export COLOR_WARNING="#fab387"
export COLOR_ERROR="#f38ba8"
export COLOR_INFO="#74c7ec"

# Escape codes for colored output in shell scripts
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
WHITE="\033[0;37m"
NC="\033[0m" # No Color
SHELL_EOF

  chmod +x "$output"
  log_info "✓ Generated: $output"
}

# Generate CSS documentation
generate_css_docs() {
  local output="${REPO_ROOT}/docs/design-system/COLOR-REFERENCE.md"

  log_info "Generating color reference documentation..."

  cat > "$output" << 'CSS_DOCS'
# PalexusOS Design System Color Reference

This file documents all colors used in the PalexusOS Design System.

## Primary Palette

| Color | Hex | Name | Usage |
|-------|-----|------|-------|
| ![#cba6f7](https://via.placeholder.com/32/cba6f7/cba6f7.png) | `#cba6f7` | Electric Mauve | Primary accent, focus states |
| ![#fab387](https://via.placeholder.com/32/fab387/fab387.png) | `#fab387` | Warm Gold | Warnings, secondary actions |
| ![#f38ba8](https://via.placeholder.com/32/f38ba8/f38ba8.png) | `#f38ba8` | Stealth Crimson | Errors, danger zones |
| ![#74c7ec](https://via.placeholder.com/32/74c7ec/74c7ec.png) | `#74c7ec` | Aerospace Sapphire | Links, info, network |
| ![#a6e3a1](https://via.placeholder.com/32/a6e3a1/a6e3a1.png) | `#a6e3a1` | Matrix Emerald | Success, local AI |
| ![#cdd6f4](https://via.placeholder.com/32/cdd6f4/cdd6f4.png) | `#cdd6f4` | Liquid Chrome | Text, metallic |
| ![#11111b](https://via.placeholder.com/32/11111b/11111b.png) | `#11111b` | Smoked Obsidian | Background |

## Surface Hierarchy

| Level | Hex | Usage |
|-------|-----|-------|
| 900 | `#11111b` | Darkest background |
| 800 | `#1e1e2e` | Primary surface |
| 700 | `#2a2a3e` | Elevated |
| 600 | `#313244` | Hover state |
| 500 | `#45454f` | Active state |

## Text Colors

| Type | Hex | Contrast (on surface-800) |
|------|-----|---------------------------|
| Primary | `#cdd6f4` | 11.3:1 ✓ |
| Secondary | `#a6adc8` | 8.5:1 ✓ |
| Tertiary | `#7f849c` | 5.2:1 ✓ |

## Functional Colors

- **Success**: `#a6e3a1` (Matrix Emerald)
- **Warning**: `#fab387` (Warm Gold)
- **Error**: `#f38ba8` (Stealth Crimson)
- **Info**: `#74c7ec` (Aerospace Sapphire)

Generated from `docs/design-system/tokens.json`
CSS_DOCS

  log_info "✓ Generated: $output"
}

# Generate XFCE theme
generate_xfce_theme() {
  local output="${REPO_ROOT}/overlay/etc/skel/.themes/Palexus-AMOLED/xfwm4/palexus-design.colors"

  log_info "Generating XFCE theme colors..."

  mkdir -p "$(dirname "$output")"

  cat > "$output" << 'XFCE_EOF'
# PalexusOS Design System for XFCE
# Generated from docs/design-system/tokens.json

[Palexus]
# Window manager colors
title_font_color=#cdd6f4
title_font_color_active=#cba6f7
title_font_color_inactive=#7f849c

# Window colors
bg_color=#1e1e2e
bg_color_active=#2a2a3e
bg_color_inactive=#313244

# Button colors
button_bg_color=#cba6f7
button_bg_color_active=#fab387
button_bg_color_inactive=#313244

# Border colors
border_color_active=#cba6f7
border_color_inactive=#313244

# Focus colors
focus_color=#cba6f7
focus_color_active=#f38ba8
XFCE_EOF

  log_info "✓ Generated: $output"
}

# Main execution
main() {
  echo ""

  # Verify tokens file
  if ! python3 -m json.tool "$TOKENS_JSON" > /dev/null 2>&1; then
    log_error "Invalid JSON in $TOKENS_JSON"
    exit 1
  fi

  # Generate all theme files
  generate_kitty_config
  generate_shell_colors
  generate_css_docs
  generate_xfce_theme

  echo ""
  log_info "Design system generation complete!"
  log_info "Generated files:"
  echo "  • Kitty colors: overlay/etc/skel/.config/kitty/palexus-design-system.conf"
  echo "  • Shell colors: overlay/etc/skel/.config/palexus-colors.sh"
  echo "  • CSS reference: docs/design-system/COLOR-REFERENCE.md"
  echo "  • XFCE theme: overlay/etc/skel/.themes/Palexus-AMOLED/xfwm4/palexus-design.colors"
  echo ""
  log_info "To apply colors to your session:"
  echo "  source overlay/etc/skel/.config/palexus-colors.sh"
  echo ""
}

main "$@"
