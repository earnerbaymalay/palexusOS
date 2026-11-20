# ADR 0003: Extract DesktopEnvironment (Boot Sequence Module Deepening)

**Date**: 2026-11-20  
**Status**: Decided  
**Deciders**: earnerbaymalay, Claude Haiku 4.5

## Context

Currently, desktop startup components scatter across repo:
- **Packages**: `packages/desktop/palexus-greeter`, `packages/desktop/palexus-hud`
- **Configuration**: `overlay/etc/skel/.config/`, `overlay/etc/skel/.themes/`
- **Boot Sequence**: Implicit in systemd services, no documented contract

**Pain Points**:
1. Boot order unclear: Does greeter start before HUD? After?
2. Component interactions implicit: Greeter assumes HUD will read a file (where? format?)
3. Can't test HUD without full greeter (tightly coupled)
4. Theme loading order uncertain (when are colors applied?)
5. Changing one component (greeter) requires careful coordination with others

## Decision

Extract a **DesktopEnvironment** Python module (`palexus/desktop/environment.py`) that:

1. **Owns**: Boot sequence orchestration
2. **Manages**: Component lifecycle and interactions
3. **Abstracts**: Components as adapters implementing well-defined interfaces
   - `GreeterAdapter` → implements `BootInterface`
   - `HUDAdapter` → implements `CommandInterface`
   - `ThemeAdapter` → implements `ThemeInterface`
4. **Exports**: Public interface
   - `DesktopEnvironment.boot()` → Execute boot sequence
   - `desktop.hud()` → Get HUD interface
   - `desktop.theme_loader()` → Get theme loader
   - `desktop.current_theme()` → Get active theme

Boot sequence (explicit order):
1. Load theme (TokenRegistry → Kitty, shell, XFCE colors)
2. Start greeter (user select, theme choice)
3. Wait for user selection
4. Start HUD (connected to theme)
5. Signal boot complete

## Benefits

### Locality
- **Before**: Boot sequence scattered across systemd services, overlay configs, implicit ordering
- **After**: Boot sequence defined in one place (DesktopEnvironment.boot())

### Testability
- Test greeter with mocked HUD
- Test HUD with mocked greeter
- Test theme loading independently
- No need for full desktop to verify component logic

### Extensibility
- Support alternative greeters by swapping GreeterAdapter
- Add new theme engines without changing boot sequence
- Component interfaces are contracts for future implementations

### Clarity
- Boot order explicit and documented
- Component responsibilities clear
- Interfaces define what each component must provide

## Tradeoffs

### Added Abstraction
- 3 adapter classes + DesktopEnvironment orchestrator
- Interfaces must be maintained as contracts

### Coordination
- Greeter and HUD must follow interface contracts
- Changes to boot order require DesktopEnvironment update

## Implementation Plan

1. Create `palexus/desktop/environment.py` with DesktopEnvironment class
2. Create adapters for Greeter, HUD, Theme
3. Define interfaces: BootInterface, CommandInterface, ThemeInterface
4. Write tests in `tests/desktop_test.py`
5. Update systemd services to use DesktopEnvironment.boot()

## Consequences

- Desktop boot sequence is now explicit and testable
- Components can be developed and tested independently
- Future alternative UIs (Wayland, alternative greeter) supported
- Boot failures have clear attribution (which adapter failed?)
