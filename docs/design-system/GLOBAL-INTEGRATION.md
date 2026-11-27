# Global Design System Integration for PalexusOS

This document describes how to apply the PalexusOS Design System across all UI components, packages, and interfaces.

## Overview

The design system provides a unified visual language for all PalexusOS interfaces:

- **Qt6 Themes** (palexus-greeter, palexus-hud, settings)
- **Terminal Styling** (Kitty, shell configurations)
- **Web Interfaces** (documentation, web utilities)
- **Icon Systems** (Nerd Font glyphs, SVG icons)
- **Installer UI** (Calamares theme)

## Component-by-Component Integration

### 1. palexus-greeter (Qt6 SDDM Theme)

**Location**: `packages/desktop/palexus-greeter/`

**Integration Steps**:

```bash
# Generate Qt6 stylesheet from design tokens
./scripts/generate-qt-stylesheet.py \
  --tokens docs/design-system/tokens.json \
  --output packages/desktop/palexus-greeter/greeter.qss

# Apply design system colors
# Edit greeter.qss to use:
# - --color-electric-mauve for active/focus states
# - --color-smoked-obsidian for backgrounds
# - --color-liquid-chrome for text
```

**Key Elements**:
- Login field: `surface-800` background, `electric-mauve` focus
- Button: Mauve background on hover, Obsidian text
- Password field: Same styling as login
- Clock/date: `text-secondary` color

### 2. palexus-hud (Command HUD - Qt6)

**Location**: `packages/desktop/palexus-hud/`

**Integration Steps**:

```bash
# Create HUD stylesheet using design tokens
# File: packages/desktop/palexus-hud/hud-styles.qss

QMainWindow {
  background-color: rgba(17, 17, 27, 0.95);  /* smoked-obsidian with transparency */
}

QLineEdit {
  background-color: #1e1e2e;  /* surface-800 */
  color: #cdd6f4;  /* liquid-chrome */
  border: 1px solid #2a2a3e;  /* surface-700 */
  padding: 8px;  /* space-2 */
}

QLineEdit:focus {
  border: 2px solid #cba6f7;  /* electric-mauve */
  box-shadow: 0 0 16px rgba(203, 166, 247, 0.3);  /* glow-mauve */
}
```

**UI Components**:
- Search field: Monospace font (JetBrains Mono), Mauve accent on focus
- Results: `surface-800` cards, `text-primary` for titles, `text-secondary` for descriptions
- Status indicator: `matrix-emerald` for local AI, `aerospace-sapphire` for Quad9 DoT
- Alert text: `stealth-crimson` for errors, `warm-gold` for warnings

### 3. palexus-themes (GTK & XFCE Themes)

**Location**: `packages/desktop/palexus-themes/`

**Integration Steps**:

```bash
# Generate XFCE color theme from tokens
./scripts/generate-xfce-theme.py \
  --tokens docs/design-system/tokens.json \
  --output overlay/etc/skel/.themes/Palexus-AMOLED/

# Apply design system to XFCE panels
# File: overlay/etc/skel/.themes/Palexus-AMOLED/xfwm4/themerc

[Palexus]
active-text-color = #cdd6f4      # liquid-chrome
inactive-text-color = #7f849c    # text-tertiary
button-bg = #1e1e2e             # surface-800
button-fg = #cba6f7             # electric-mauve (focus)
button-hover-bg = #313244       # surface-600
```

**Assets**:
- Wallpapers: Keep geometric patterns with Electric Mauve accents
- Icons: Use Liquid Chrome, Smoked Obsidian, Radial Tungsten, Aerospace Billet suites

### 4. Terminal Configuration (Kitty, Bash)

**Location**: `overlay/etc/skel/.config/kitty/`

**Integration Steps**:

```bash
# Update Kitty color configuration from tokens
# File: overlay/etc/skel/.config/kitty/quickfire-colors.conf

# PalexusOS Design System Colors
foreground #cdd6f4           # liquid-chrome
background #11111b           # smoked-obsidian
selection_background #cba6f7 # electric-mauve

# ANSI Colors (8 + bright)
color0 #11111b  # black -> obsidian
color1 #f38ba8  # red -> crimson
color2 #a6e3a1  # green -> emerald
color3 #fab387  # yellow -> gold
color4 #74c7ec  # blue -> sapphire
color5 #cba6f7  # magenta -> mauve
color6 #89dceb  # cyan -> (catppuccin)
color7 #cdd6f4  # white -> chrome

# Bright colors
color8 #45454f   # bright-black -> surface-500
color9 #f38ba8   # bright-red
color10 #a6e3a1  # bright-green
...
```

### 5. Installer UI (Calamares)

**Location**: `build/calamares/`

**Integration Steps**:

```yaml
# File: build/calamares/branding/palexus/branding.desc

colors:
  primary: "#cba6f7"      # electric-mauve
  secondary: "#1e1e2e"    # surface-800
  success: "#a6e3a1"      # matrix-emerald
  warning: "#fab387"      # warm-gold
  error: "#f38ba8"        # stealth-crimson

fonts:
  default:
    family: "JetBrains Mono Nerd Font"
    size: 10
  headings:
    family: "JetBrains Mono Nerd Font"
    size: 12
    weight: bold
```

### 6. Web Documentation

**Location**: `docs/`

**Integration Steps**:

```html
<!-- File: docs/index.html (or equivalent) -->
<link rel="stylesheet" href="design-system/tokens.css">

<!-- Apply design system classes -->
<main class="bg-surface p-6">
  <h1 class="text-h1 color-primary">PalexusOS</h1>
  <p class="text-body color-secondary">AI-native sovereign workstation</p>
</main>
```

## Global Design System Application Checklist

- [ ] **Colors**: All UI elements use `--color-*` CSS variables or hex equivalents from tokens
- [ ] **Typography**: All text uses `JetBrains Mono Nerd Font` or fallback monospace
- [ ] **Spacing**: All padding/margins use `--space-*` multiples (8px base scale)
- [ ] **Radius**: All corners use `--radius-*` values (chamfered aesthetic)
- [ ] **Shadows**: All elevated elements use `--shadow-*` values
- [ ] **Focus States**: All interactive elements have 2px `electric-mauve` outline
- [ ] **Contrast**: All text meets WCAG AA 4.5:1 contrast minimum
- [ ] **Icons**: All icons use Nerd Font glyphs or approved icon suites
- [ ] **Consistency**: All themes use the same color palette

## Token Generation Scripts

Create these scripts to automate design system application:

### generate-qt-stylesheet.py

```python
#!/usr/bin/env python3
"""Generate Qt6 stylesheet from design tokens."""

import json
import argparse
from pathlib import Path

def generate_qss(tokens_path: str, output_path: str):
    """Generate Qt stylesheet from tokens.json"""
    with open(tokens_path) as f:
        tokens = json.load(f)
    
    colors = tokens['colors']
    
    qss = """
    /* Generated from PalexusOS Design System */
    
    QWidget {
        background-color: %(obsidian)s;
        color: %(chrome)s;
    }
    
    QLineEdit {
        background-color: %(surface800)s;
        color: %(chrome)s;
        border: 1px solid %(surface700)s;
        padding: 8px;
        border-radius: 4px;
    }
    
    QLineEdit:focus {
        border: 2px solid %(mauve)s;
        box-shadow: 0 0 16px rgba(203, 166, 247, 0.3);
    }
    """ % {
        'obsidian': colors['primary']['obsidian'],
        'chrome': colors['primary']['chrome'],
        'mauve': colors['primary']['mauve'],
        'surface800': colors['surface']['800'],
        'surface700': colors['surface']['700'],
    }
    
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)
    Path(output_path).write_text(qss)
    print(f"Generated: {output_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--tokens", required=True)
    parser.add_argument("--output", required=True)
    args = parser.parse_args()
    generate_qss(args.tokens, args.output)
```

### generate-xfce-theme.py

Similar structure for XFCE theme generation from tokens.

## Consistency Rules

### Color Application

1. **Surfaces**: Only use `surface-800`, `surface-700`, `surface-600`, `surface-500` (never invent)
2. **Text**: Only use `text-primary`, `text-secondary`, `text-tertiary` on appropriate surfaces
3. **Accents**: Only `electric-mauve` for focus/active, `aerospace-sapphire` for links/info
4. **Status**: `matrix-emerald` (success), `warm-gold` (warning), `stealth-crimson` (error)

### Typography

1. All text uses `JetBrains Mono Nerd Font` or system monospace fallback
2. Never use serif fonts in PalexusOS
3. Font sizes: Use type scale (h1–h3, body-lg, body, body-sm)
4. Font weight: Bold (700) for headings, regular (400) for body

### Spacing

1. All padding: `4px`, `8px`, `12px`, `16px`, `24px`, `32px`, `48px`
2. Never use arbitrary spacing values
3. Border radius: `2px`, `4px`, `8px`, `16px` only

## Verification

Run these checks to ensure consistent application:

```bash
# Check for hardcoded colors (should be none)
grep -r "#[0-9a-f]\{6\}" packages/desktop/ docs/ overlay/ \
  --exclude-dir=.git --exclude="*.json"

# Check for undeclared fonts
grep -r "font-family" docs/design-system/ | \
  grep -v "JetBrains Mono"

# Validate CSS against design tokens
./scripts/validate-tokens.sh docs/design-system/tokens.css

# Generate design system report
./scripts/design-report.sh > DESIGN-REPORT.md
```

## Update Process

When design tokens change:

1. Update `tokens.json` and `tokens.css`
2. Run generation scripts for each UI component
3. Test all themes and interfaces
4. Commit changes with design system reference
5. Update documentation if any tokens are added/removed

## Resources

- **Design System Artifact**: https://claude.ai/artifact/DmyLwKLjPa6hRhsrUDofAm
- **Token Reference**: `docs/design-system/tokens.json`
- **CSS Variables**: `docs/design-system/tokens.css`
- **Component Examples**: `docs/design-system/components/`
- **Integration Guide**: `docs/design-system/INTEGRATION.md`

## Support

For questions about applying the design system:

1. Check `docs/design-system/README.md` for overview
2. See `docs/design-system/INTEGRATION.md` for implementation details
3. Review component examples in `docs/design-system/components/`
4. Consult the design system artifact for specifications
