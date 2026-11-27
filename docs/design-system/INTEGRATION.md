# PalexusOS Design System Integration Guide

This document describes how to integrate and use the PalexusOS Design System across the codebase.

## Overview

The design system provides:
- **tokens.css** — CSS custom properties (variables) for all design elements
- **tokens.json** — Design tokens in JSON format for tools and automation
- **Component specifications** — Guidelines for building consistent UI
- **Icon system** — Four metallic icon suites with naming conventions

## File Structure

```
docs/design-system/
├── tokens.css
├── tokens.json
├── INTEGRATION.md
├── README.md
└── components/
    ├── buttons.html
    ├── forms.html
    ├── cards.html
    ├── modals.html
    └── ...
```

- `tokens.css` — CSS variables (use this in your stylesheets)
- `tokens.json` — Token definitions (for tooling)
- `INTEGRATION.md` — This file
- `README.md` — Design system overview
- `components/` — Component examples

## Quick Start

### 1. Import Design System CSS

In your HTML or main stylesheet:

```html
<!-- Import design system tokens -->
<link rel="stylesheet" href="/docs/design-system/tokens.css">
<!-- Your component styles -->
<link rel="stylesheet" href="your-styles.css">
```

### 2. Use CSS Variables in Your Styles

```css
/* Instead of hardcoding colors */
.my-button {
  /* ❌ Don't do this */
  background-color: #cba6f7;
  color: #11111b;

  /* ✅ Do this instead */
  background-color: var(--color-electric-mauve);
  color: var(--color-smoked-obsidian);
  padding: var(--space-2) var(--space-4);
  border-radius: var(--radius-md);
  transition: background-color var(--transition-quick);
}
```

### 3. Use Semantic Utility Classes

The design system provides semantic utility classes for common patterns:

```html
<!-- Semantic color utilities -->
<p class="color-primary">Primary text</p>
<p class="color-secondary">Secondary text</p>
<p class="color-accent">Accent color</p>

<!-- Background utilities -->
<div class="bg-surface p-4 rounded-lg shadow-md">
  <h2 class="text-h2">Card Title</h2>
  <p class="text-body">Card content</p>
</div>

<!-- Typography utilities -->
<h1 class="text-h1">Main Heading</h1>
<h2 class="text-h2">Sub Heading</h2>
<p class="text-body-lg">Large body text</p>

<!-- Spacing utilities -->
<div class="p-4 m-2 gap-2">Items with spacing</div>
```

## Design Token Categories

### Colors

All colors are defined with semantic naming:

```css
/* Primary palette */
--color-electric-mauve: #cba6f7;      /* Primary accent, focus */
--color-warm-gold: #fab387;           /* Warnings, secondary */
--color-stealth-crimson: #f38ba8;     /* Errors, danger */
--color-aerospace-sapphire: #74c7ec;  /* Info, links */
--color-matrix-emerald: #a6e3a1;      /* Success, online */
--color-liquid-chrome: #cdd6f4;       /* Text, metallic */
--color-smoked-obsidian: #11111b;     /* Base surface */

/* Surface hierarchy */
--color-surface-900: #11111b;         /* Darkest */
--color-surface-800: #1e1e2e;         /* Primary surface */
--color-surface-700: #2a2a3e;         /* Elevated */
--color-surface-600: #313244;         /* Hover */
--color-surface-500: #45454f;         /* Active */

/* Text hierarchy */
--color-text-primary: #cdd6f4;        /* Main text */
--color-text-secondary: #a6adc8;      /* Supporting text */
--color-text-tertiary: #7f849c;       /* Disabled, metadata */
```

### Typography

**Font Family**: JetBrains Mono Nerd Font (monospace)

```css
--font-mono: "JetBrains Mono Nerd Font", "Courier New", monospace;

/* Type scale */
--font-size-h1: 32px;        /* Headings */
--font-size-h2: 24px;
--font-size-h3: 18px;
--font-size-body-lg: 16px;   /* Body text */
--font-size-body: 14px;
--font-size-body-sm: 12px;
--font-size-terminal: 14px;  /* Terminal/code */
--font-size-code: 13px;
```

### Spacing (8px Base Scale)

```css
--space-1: 4px;      /* Tight spacing */
--space-2: 8px;      /* Compact */
--space-3: 12px;     /* Standard */
--space-4: 16px;     /* Card padding */
--space-5: 24px;     /* Major spacing */
--space-6: 32px;     /* Large sections */
--space-8: 48px;     /* Full-screen sections */
```

### Border Radius (Chamfered Aesthetic)

```css
--radius-sm: 2px;    /* Subtle */
--radius-md: 4px;    /* Standard buttons, inputs */
--radius-lg: 8px;    /* Cards, modals */
--radius-xl: 16px;   /* Chamfered windows */
```

### Shadows (Depth)

```css
--shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.3);        /* Subtle */
--shadow-md: 0 4px 12px rgba(0, 0, 0, 0.5);       /* Standard */
--shadow-lg: 0 12px 32px rgba(0, 0, 0, 0.6);      /* Major */
--shadow-glow-mauve: 0 0 16px rgba(203, 166, 247, 0.3); /* Focus glow */
```

## Component Implementation Examples

### Button

```html
<!-- Primary Button -->
<button class="btn btn-primary">
  Click Me
</button>

<!-- Secondary Button -->
<button class="btn btn-secondary">
  Secondary
</button>

<!-- Icon Button -->
<button class="btn btn-icon" aria-label="Close">
  <!-- icon here -->
</button>
```

```css
.btn {
  padding: var(--space-2) var(--space-4);
  border: none;
  border-radius: var(--radius-md);
  font-family: var(--font-mono);
  font-size: var(--font-size-body);
  font-weight: var(--font-weight-bold);
  cursor: pointer;
  transition: all var(--transition-quick);
  min-height: var(--size-button-height);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: var(--space-2);
}

.btn:focus {
  outline: 2px solid var(--color-electric-mauve);
  outline-offset: 2px;
  box-shadow: var(--shadow-glow-mauve);
}

.btn-primary {
  background-color: var(--color-electric-mauve);
  color: var(--color-smoked-obsidian);
}

.btn-primary:hover {
  opacity: 0.9;
  box-shadow: var(--shadow-md);
}

.btn-secondary {
  background-color: var(--color-surface-600);
  color: var(--color-text-primary);
  border: 1px solid var(--color-surface-700);
}

.btn-secondary:hover {
  background-color: var(--color-surface-500);
}
```

### Card

```html
<div class="card">
  <h3 class="text-h3">Card Title</h3>
  <p class="text-body">Card content goes here.</p>
</div>
```

```css
.card {
  background-color: var(--color-surface-800);
  border-radius: var(--radius-lg);
  padding: var(--space-4);
  box-shadow: var(--shadow-md);
  border: 1px solid var(--color-surface-700);
  transition: box-shadow var(--transition-standard);
}

.card:hover {
  box-shadow: var(--shadow-lg);
}
```

### Form Input

```html
<input 
  type="text" 
  class="input" 
  placeholder="Enter text..."
>
```

```css
.input {
  width: 100%;
  padding: var(--space-2) var(--space-3);
  border: 1px solid var(--color-surface-700);
  border-radius: var(--radius-md);
  background-color: var(--color-smoked-obsidian);
  color: var(--color-text-primary);
  font-family: var(--font-mono);
  font-size: var(--font-size-body);
  transition: all var(--transition-quick);
}

.input:focus {
  outline: none;
  border-color: var(--color-electric-mauve);
  box-shadow: var(--shadow-glow-mauve);
}

.input::placeholder {
  color: var(--color-text-tertiary);
}
```

## Accessibility Requirements

### Color Contrast

All text must meet WCAG AA standards (4.5:1 minimum):

```css
/* ✅ Good: Electric Mauve on Obsidian (12.5:1) */
.good-contrast {
  color: var(--color-electric-mauve);
  background-color: var(--color-smoked-obsidian);
}

/* ✅ Good: Primary text on surface (11.3:1) */
.primary-text {
  color: var(--color-text-primary);
  background-color: var(--color-surface-800);
}

/* ❌ Bad: Surface-500 on Surface-800 (insufficient contrast) */
.bad-contrast {
  color: var(--color-surface-500);
  background-color: var(--color-surface-800);
}
```

### Keyboard Focus

All interactive elements must have visible focus indicators:

```css
button, input, a {
  &:focus {
    outline: 2px solid var(--color-electric-mauve);
    outline-offset: 2px;
    box-shadow: var(--shadow-glow-mauve);
  }
}
```

### Motion Preferences

Respect `prefers-reduced-motion` for users sensitive to animation:

```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}
```

## Responsive Design

Use CSS custom properties for breakpoints:

```css
@media (max-width: var(--breakpoint-lg)) {
  /* Adjust for 1024px–1439px displays */
}

@media (max-width: var(--breakpoint-md)) {
  /* Adjust for 768px–1023px displays */
}

@media (max-width: var(--breakpoint-sm)) {
  /* Adjust for <768px mobile screens */
}
```

## Dark Mode Only

PalexusOS operates exclusively in dark mode. No light theme variables are provided. If light mode support is added in the future, all colors must be re-verified for WCAG compliance.

## Color Usage Rules

### Status Colors

- **Success**: Use `--color-matrix-emerald` with checkmark icon
- **Error**: Use `--color-stealth-crimson` with alert icon
- **Warning**: Use `--color-warm-gold` with warning icon
- **Info**: Use `--color-aerospace-sapphire` with info icon

### Never use color alone

Always pair color with an icon, text label, or pattern:

```html
<!-- ✅ Good: Color + icon + text -->
<span class="status status-success">
  <svg class="icon"><!-- checkmark --></svg>
  Upload complete
</span>

<!-- ❌ Bad: Color alone -->
<span class="status" style="color: #a6e3a1;">
  Upload
</span>
```

## Extending the Design System

### Adding New Components

1. Create a component file in `docs/design-system/components/`
2. Document the component structure, variants, and accessibility requirements
3. Use CSS custom properties for all colors, spacing, typography
4. Include focus states, hover states, and disabled states
5. Test for WCAG AA contrast compliance

### Modifying Tokens

1. Update both `tokens.css` and `tokens.json`
2. Document the change in the design system artifact
3. Test affected components for visual regression
4. Update component documentation as needed

## Tools & Scripts

### Token Validation

Validate token consistency across CSS and JSON:

```bash
# Example: Check if all CSS variables have JSON equivalents
grep "var(--" docs/design-system/*.css | wc -l
grep '"' docs/design-system/tokens.json | wc -l
```

### CSS Linting

Use stylelint to enforce consistent CSS property naming:

```bash
# Install stylelint and plugins
npm install \
  --save-dev stylelint stylelint-config-standard

# Run linter
stylelint docs/design-system/tokens.css
```

## Common Patterns

### Primary Button + Text

```css
.btn-primary {
  background-color: var(--color-electric-mauve);
  color: var(--color-smoked-obsidian);
}
```

### Surface + Border

```css
.card {
  background-color: var(--color-surface-800);
  border: 1px solid var(--color-surface-700);
}
```

### Focus Ring

```css
:focus {
  outline: 2px solid var(--color-electric-mauve);
  outline-offset: 2px;
  box-shadow: var(--shadow-glow-mauve);
}
```

### Hover Elevation

```css
.interactive:hover {
  box-shadow: var(--shadow-md);
  background-color: var(--color-surface-700);
}
```

## References

- **Design System Artifact**: View full documentation at `/docs/design-system/README.md`
- **Component Guidelines**: See component specifications in this directory
- **Token Definitions**: Consult `tokens.json` for exact values
- **CSS Variables**: Reference `tokens.css` for CSS custom property names

## Questions?

Refer to the design system documentation in `/docs/design-system/README.md` or the main design system artifact for detailed specifications.
