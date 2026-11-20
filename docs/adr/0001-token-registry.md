# ADR 0001: Extract TokenRegistry (Design System Module Deepening)

**Date**: 2026-11-20  
**Status**: Decided  
**Deciders**: earnerbaymalay, Claude Haiku 4.5

## Context

Currently, design tokens scatter across multiple files:
- Source: `docs/design-system/tokens.json`
- CSS: `docs/design-system/tokens.css` (generated)
- Shell: `overlay/etc/skel/.config/palexus-colors.sh` (generated)
- Kitty: `overlay/etc/skel/.config/kitty/palexus-design-system.conf` (generated)
- XFCE: `overlay/etc/skel/.themes/Palexus-AMOLED/xfwm4/palexus-design.colors` (generated)
- Documentation: `docs/design-system/COLOR-REFERENCE.md` (generated)

**Pain Points**:
1. Adding a new token type (e.g., animation timings) requires editing:
   - tokens.json (add token)
   - generate-designs.sh (add export logic)
   - Multiple output files (manual or via script)
   - No validation that all outputs match schema

2. Changing token value format or validation logic requires script updates

3. No programmatic way for consumers to load/validate tokens

4. Generation script is owned by build system, not design system

## Decision

Extract a **TokenRegistry** Python module (`palexus/design/token_registry.py`) that:

1. **Owns**: Loading, parsing, validating tokens.json
2. **Manages**: Token schema, versioning, deprecation
3. **Exports**: Public interface for consumers
   - `TokenRegistry.load(path)` → Load tokens from file
   - `registry.colors()` → Get all colors by name
   - `registry.spacing()` → Get all spacing values
   - `registry.validate()` → Validate schema
4. **Abstracts**: Export adapters
   - `CSSExporter(registry).export()` → CSS custom properties
   - `ShellExporter(registry).export()` → Shell aliases
   - `KittyExporter(registry).export()` → Kitty config
   - `XFCEExporter(registry).export()` → XFCE theme

## Benefits

### Locality
- **Before**: Adding a token touches 5+ files
- **After**: Adding a token touches only 2 files (tokens.json + schema update in TokenRegistry)

### Testability
- Unit test TokenRegistry independently (load, validate, export)
- Each exporter tested in isolation
- No need for end-to-end theme generation to verify token correctness

### Extensibility
- New exporters (Qt6 theme, animated timings, Figma plugin) inherit validation automatically
- Future: Token deprecation warnings, version migration

### Clarity
- Design system ownership explicit
- Validation centralized
- Interface contracts clear (what does TokenRegistry export?)

## Tradeoffs

### Added Complexity
- New Python module + 4 exporter classes
- Requires Python to be in build/runtime environment (already true for tests)

### Runtime Overhead
- Minimal: tokens loaded once at startup
- File I/O happens at generation time, not runtime

## Implementation Plan

1. Create `palexus/design/token_registry.py` with TokenRegistry class
2. Create `palexus/design/exporters.py` with exporter classes
3. Write tests in `tests/design_test.py`
4. Update `scripts/generate-designs.sh` to use TokenRegistry
5. Verify all generated files match current output (no behavior change)

## Consequences

- Design system is now modular and testable
- Token changes have clear ownership
- Build system decoupled from design system concerns
- Future token types (animations, gradients) can be added easily
