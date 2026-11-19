# PalexusOS Design System

The official design system for PalexusOS—an AI-native sovereign workstation built on security, anonymity, and local intelligence.

## Overview

This design system provides a complete visual language for PalexusOS, including:

- **Design Tokens** — Colors, typography, spacing, shadows, and transitions
- **Component Specifications** — Reusable UI patterns with accessibility guidelines
- **Icon System** — Four metallic icon suites (Liquid Chrome, Smoked Obsidian, Radial Tungsten, Aerospace Billet)
- **Implementation Guides** — CSS variables, utility classes, and component examples
- **Accessibility Standards** — WCAG AA compliance checklist and color contrast requirements

## Quick Links

- **[Integration Guide](./INTEGRATION.md)** — How to use the design system in your code
- **[Design Tokens](./tokens.json)** — All token definitions in JSON format
- **[CSS Variables](./tokens.css)** — Compiled CSS custom properties
- **[Components](./components/)** — Component specifications and examples

## Key Design Principles

### 1. Sovereignty First
Every design decision respects user autonomy and privacy. The visual language emphasizes local intelligence, transparent security, and direct hardware control.

### 2. Cyberdeck Aesthetic
PalexusOS embraces monospace terminal culture, metallic chrome aesthetics, and industrial design language. Dark obsidian surfaces with electric accents signal active intelligence and secure states.

### 3. Keyboard-Native
All interactions are optimized for keyboard-first workflows. Mnemonic keybindings (Mod4 + Space for AI, etc.) are supported by consistent visual feedback.

### 4. Zero-Telemetry Visuals
Color usage signals security and AI states: Emerald for local AI online, Crimson for firewall blocks, Sapphire for network privacy, Mauve for active focus.

## Color Palette

| Token | Hex | Purpose |
|-------|-----|---------|
| **Electric Mauve** | `#cba6f7` | Primary accent, focus states, active borders |
| **Warm Gold** | `#fab387` | Warnings, secondary actions, telemetry indicators |
| **Stealth Crimson** | `#f38ba8` | Errors, firewall blocks, authentication failures |
| **Aerospace Sapphire** | `#74c7ec` | Links, network status, Quad9 DoT indicators |
| **Matrix Emerald** | `#a6e3a1` | Local AI online, verified security, success states |
| **Liquid Chrome** | `#cdd6f4` | Foreground text, metallic typography |
| **Smoked Obsidian** | `#11111b` | Dark foundation, chamfered backgrounds |

## Typography

**Font**: JetBrains Mono Nerd Font (monospace)

PalexusOS uses monospace typography exclusively—the native language of terminals, code, and cyberdeck culture. All text uses JetBrains Mono Nerd Font (with Nerd Font icons) for visual coherence and accessibility.

### Type Scale

- **H1**: 32px, bold, -0.02em tracking
- **H2**: 24px, bold, -0.01em tracking
- **H3**: 18px, bold
- **Body Large**: 16px, 1.6 line height
- **Body**: 14px, standard (default)
- **Body Small**: 12px, condensed
- **Terminal**: 14px, 1.6 line height, +0.01em tracking
- **Code**: 13px, tight

## Spacing System

PalexusOS uses an 8px base scale for consistent rhythm:

| Token | Size | Usage |
|-------|------|-------|
| `space-1` | 4px | Tight spacing, icon margins |
| `space-2` | 8px | Compact padding, button spacing |
| `space-3` | 12px | Standard element padding |
| `space-4` | 16px | Card padding, standard gutters |
| `space-5` | 24px | Major spacing, container padding |
| `space-6` | 32px | Large sections, layout gaps |
| `space-8` | 48px | Full-screen sections |

## Border Radius

Chamfered corners for subtle, industrial aesthetic:

| Token | Value | Usage |
|-------|-------|-------|
| `radius-sm` | 2px | Subtle rounding, borders |
| `radius-md` | 4px | Standard buttons, cards, inputs |
| `radius-lg` | 8px | Larger components, modals |
| `radius-xl` | 16px | Chamfered windows, major panels |

## Elevation & Shadows

Shadows create depth while maintaining the dark theme:

```
shadow-sm:    0 1px 2px rgba(0, 0, 0, 0.3)
shadow-md:    0 4px 12px rgba(0, 0, 0, 0.5)
shadow-lg:    0 12px 32px rgba(0, 0, 0, 0.6)
shadow-glow:  0 0 16px rgba(203, 166, 247, 0.3)
```

## Component Library

### Buttons

- **Primary**: Electric Mauve background, Obsidian text
- **Secondary**: Surface-600 background, Primary text
- **Danger**: Crimson background, Obsidian text
- **Icon**: 44×44px minimum, 24×24px icon content
- **Focus**: 2px Electric Mauve outline + glow

### Forms

- **Input**: 1px Surface-700 border, 4px radius, monospace font
- **Focus**: Electric Mauve border + glow shadow
- **Error**: Crimson border
- **Label**: Bold, Primary color, required indicator in Warm Gold

### Cards

- **Background**: surface-800, 8px radius
- **Padding**: 16px (space-4)
- **Shadow**: shadow-md, upgrades to shadow-lg on hover
- **Border**: Optional 1px surface-700

### Modals

- **Backdrop**: rgba(0, 0, 0, 0.6), fade in 300ms
- **Dialog**: Max 600px wide, shadow-lg, 8px radius
- **Animation**: Fade + slight scale (0.95 → 1)

### Status Indicators

- **Success**: Matrix Emerald + checkmark
- **Error**: Stealth Crimson + alert icon
- **Warning**: Warm Gold + warning icon
- **Info**: Aerospace Sapphire + info icon

## Icon System

PalexusOS ships with four metallic icon suites, each with 24×24px baseline:

### Liquid Chrome
Bright, polished silver with highlights and shadows. Used for primary interface elements and frequently-used actions.

### Smoked Obsidian
Dark, minimalist line work. Used for secondary actions, nested UI, and compact layouts.

### Radial Tungsten
Industrial hardware aesthetic with bold strokes. Used for status indicators and system state.

### Aerospace Billet
Technical precision, engineering-focused. Used for developer tools and advanced features.

**Naming Convention**: `icon-[category]-[name]-[variant]`

Examples: `icon-nav-home`, `icon-action-delete`, `icon-status-success`

## Accessibility Commitments

### WCAG AA Compliance
- All text meets 4.5:1 contrast minimum
- Large text (18px+) meets 3:1 ratio
- Color is never the sole indicator of state

### Keyboard Navigation
- All interactive elements are keyboard accessible
- Tab order follows logical DOM order
- Focus indicators always visible (2px+ Electric Mauve)

### Screen Reader Support
- Semantic HTML throughout
- ARIA labels for icon buttons
- Descriptive link text

### Motion Sensitivity
- Animations respect `prefers-reduced-motion`
- Transitions are 150–500ms (not instant, not excessive)
- No flashing or blinking elements

## Usage in Code

### 1. Import CSS Variables

```html
<link rel="stylesheet" href="docs/design-system/tokens.css">
```

### 2. Use Variables in Styles

```css
.my-button {
  background-color: var(--color-electric-mauve);
  color: var(--color-smoked-obsidian);
  padding: var(--space-2) var(--space-4);
  border-radius: var(--radius-md);
  box-shadow: var(--shadow-md);
}
```

### 3. Apply Utility Classes

```html
<div class="p-4 rounded-lg shadow-md bg-surface">
  <h2 class="text-h2 color-primary">Card Title</h2>
  <p class="text-body color-secondary">Content goes here.</p>
</div>
```

## Integration Guide

See **[INTEGRATION.md](./INTEGRATION.md)** for detailed implementation examples and best practices.

## Component Examples

Browse the `components/` directory for:
- `buttons.html` — Button variants and states
- `forms.html` — Input types, labels, validation
- `cards.html` — Card patterns and layouts
- `modals.html` — Dialog patterns and animations
- `navigation.html` — Nav bars, sidebars, menus
- `status.html` — Indicators, badges, loaders

## Tools & References

- **Token Definitions**: `tokens.json` (JSON format for tooling)
- **CSS Variables**: `tokens.css` (CSS custom properties)
- **Full Design System**: View the design system artifact for comprehensive specifications

## Contributing

When adding new components or tokens:

1. Update both `tokens.json` and `tokens.css`
2. Document in this README
3. Create component examples in `components/`
4. Verify WCAG AA contrast compliance
5. Test keyboard navigation and focus states
6. Update the design system artifact

## Questions?

Refer to the **[Integration Guide](./INTEGRATION.md)** or the design system artifact for detailed specifications and examples.

---

**PalexusOS Design System** | Built for Sovereignty, Speed, and Local Intelligence
