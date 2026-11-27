# PalexusOS Domain Model & Architecture Terminology

**Last Updated**: 2026-11-20  
**Contributors**: earnerbaymalay, Claude Haiku 4.5

## Core Domain Concepts

### Operating System Layer
- **PalexusOS**: AI-native rolling Linux distribution. Merges CachyOS performance, EndeavourOS foundation, Omarchy aesthetics, and native AI subsystem.
- **Arch Linux Base**: Transparent PKGBUILD packaging, pacman package manager, AUR-compatible.
- **CachyOS Optimization**: Kernel schedulers (BORE/EEVDF), x86-64-v3/v4 CPU optimization, ZRAM swappiness=180, BBR TCP.
- **Kernel Configuration**: Performance tuning at boot; transparent to user.

### Design System
- **TokenRegistry**: Source-of-truth module for all design tokens (colors, typography, spacing, shadows). Owns validation, versioning, deprecation. Abstracts exporters (CSS, shell, Kitty, XFCE).
- **Design Tokens**: Semantic (named) values for colors, typography, spacing, shadows. E.g., `electric-mauve` (#cba6f7), `h1` (32px), `surface-500` (#45454f).
- **Palexus Color Palette**: Catppuccin Mocha Mauve base + cyberdeck aesthetic.
  - **Electric Mauve** (#cba6f7): Primary accent, focus states.
  - **Liquid Chrome** (#cdd6f4): Text, metallic accents.
  - **Smoked Obsidian** (#11111b): Background.
  - **Warm Gold** (#fab387): Warnings, secondary actions.
  - **Stealth Crimson** (#f38ba8): Errors, danger.
  - **Aerospace Sapphire** (#74c7ec): Links, info, network.
  - **Matrix Emerald** (#a6e3a1): Success, local AI.
- **Typography**: JetBrains Mono Nerd Font (monospace). Used for terminal, UI, documentation.

### Desktop Environment
- **DesktopEnvironment**: Module that owns boot sequence: greeter → user select → HUD start → theme apply. Manages component adapters (Greeter, HUD, Theme).
- **Palexus Greeter**: First-boot UI. Selects user, theme. Implements BootInterface.
- **Palexus HUD**: Heads-up display for AI commands. Implements CommandInterface.
- **Theme Loading**: Applies design system (tokens → Kitty, XFCE, shell) on boot.

### Build & Quality Gates
- **Gate**: Quality verification step (package build, ISO creation, graphics, boot, performance). Part of GateRegistry.
- **GateRegistry**: Module that owns gate definitions, execution order, dependencies, tracking. Abstracts individual gates.
- **PackageGate** (G1): `makepkg` succeeds for all PKGBUILD files.
- **ISOGate** (G2): ISO image exists, is bootable.
- **GraphicsGate** (G3): Qt6 renders without errors.
- **BootGate** (G4): QEMU boots, reaches login.
- **PerfGate** (G5): Build time under target.
- **Verification Suite**: `build/verify-gates.sh` runs all gates (or selected gates).

### Testing Infrastructure
- **TestOrchestrator**: Module that owns unified test interface. Manages unit tests, gate tests, integration tests. Abstracts QEMU setup/teardown, artifact management.
- **UnitTests**: Python test suite in `tests/`.
- **GateTests**: One test per Gate (from GateRegistry).
- **IntegrationTests**: End-to-end boot sequence (ISO → QEMU → login).

### Packages & Configuration
- **Package** (PKGBUILD): Arch Linux native. Defines build, install, packaging. Located in `packages/`.
- **Package Categories**:
  - **Core** (`packages/core/`): System fundamentals (kernel, firmware, boot).
  - **Desktop** (`packages/desktop/`): GUI, greeter, HUD, theme.
  - **Tools** (`packages/tools/`): CLI utilities, profiling, security.
  - **AI** (`packages/ai/`): LLM integrations, local inference.
- **Overlay** (`overlay/`): System configuration. Installed on top of packages.
  - `overlay/etc/skel/`: Home directory template.
  - `overlay/etc/skel/.config/`: User configs (Kitty, shell, XFCE).
  - `overlay/etc/skel/.themes/`: Theme definitions.

### Repository Structure
```
palexusOS/
├── packages/
│   ├── core/
│   ├── desktop/
│   ├── tools/
│   └── ai/
├── build/
├── overlay/
├── docs/
│   ├── design-system/
│   └── adr/
├── scripts/
├── tests/
└── palexus/
    ├── design/
    ├── build/
    ├── desktop/
    └── test/
```

- `packages/` — PKGBUILD definitions
- `build/` — ISO generation, verification
- `overlay/` — System configuration
- `docs/` — Documentation, design system
- `docs/design-system/` — Token definitions, integration guide
- `docs/adr/` — Architecture decision records
- `scripts/` — Utilities (design generation, CI)
- `tests/` — Python unit tests
- `palexus/` — Core Python modules
- `palexus/design/` — TokenRegistry, exporters
- `palexus/build/` — GateRegistry, gates
- `palexus/desktop/` — DesktopEnvironment, adapters
- `palexus/test/` — TestOrchestrator

## Architecture Vocabulary (from modular design theory)

**Module**: A unit of code with a clear boundary. Owns specific concepts, hides implementation, exports an interface.

**Interface**: What consumers see and depend on. Defines contracts (what goes in, what comes out). Separates public (interface) from private (implementation).

**Depth**: Ratio of interface complexity to implementation complexity. Deep modules have small, simple interfaces hiding substantial complexity. Shallow modules have interfaces nearly as complex as their implementation.

**Seam**: A boundary between modules. Where one module ends, another begins. Can be a function call, a file, a directory.

**Adapter**: A module that translates between two interfaces. Sits at a seam. Example: CSSExporter (reads TokenRegistry, writes CSS).

**Leverage**: The improvement in locality when a module is deepened. Example: extracting TokenRegistry means changes to design tokens no longer scatter across 7+ files.

**Locality**: How much of the codebase changes when you change one concept. High locality = changes are localized. Low locality = changes scatter.

**Deletion Test**: Would deleting a module concentrate complexity into its caller, or just move it? If it concentrates, the module is probably shallow and not worth extracting. If deletion makes code harder to understand, the module is deep and worth keeping.

---

## Decisions & Rationale

### Why TokenRegistry (Deep Module)
- **Problem**: Tokens scattered across tokens.json, tokens.css, palexus-colors.sh, Kitty config, XFCE theme, documentation. Adding a new token type requires editing 5+ files.
- **Solution**: TokenRegistry owns loading, validating, versioning. Exporters (CSS, shell, Kitty, XFCE) read from TokenRegistry, write their format.
- **Locality**: Adding a token now only requires editing tokens.json + TokenRegistry schema. All exporters inherit validation.

### Why GateRegistry (Deep Module)
- **Problem**: Gates mixed in 828-line shell script. Can't test gate #2 without gates #1–#5 passing. No gate independence or dependencies declared.
- **Solution**: GateRegistry owns gate definitions (as data), execution order, dependencies. Each Gate is a small class with run() method.
- **Locality**: Adding gate #6 is just a new Gate class + declaration. CI can run selective gates based on file changes.

### Why DesktopEnvironment (Deep Module)
- **Problem**: Greeter in `packages/desktop/palexus-greeter`, HUD in `packages/desktop/palexus-hud`, themes in `overlay/`. Boot sequence implicit. Can't test HUD without full greeter.
- **Solution**: DesktopEnvironment owns boot sequence: greeter → user select → HUD → theme. Component adapters (Greeter, HUD, Theme) implement interfaces.
- **Locality**: Changing greeter or HUD only affects their adapter. Boot sequence explicit. HUD can be tested with mocked Greeter.

### Why TestOrchestrator (Deep Module)
- **Problem**: Unit tests in Python, gate tests in shell, integration in QEMU. All-or-nothing gate testing. New quality checks have no home.
- **Solution**: TestOrchestrator owns unified test interface. Unit + gate + integration tests. Artifact management (ISO, results).
- **Locality**: New quality checks just register with orchestrator. CI can run selective tests.

---

## Related ADRs

- **ADR-0001**: TokenRegistry extraction rationale & interface design
- **ADR-0002**: GateRegistry extraction rationale & gate independence
- **ADR-0003**: DesktopEnvironment boot sequence abstraction
- **ADR-0004**: TestOrchestrator unified testing framework

---

## Questions & Open Items

1. **TokenRegistry caching**: Should tokens be cached? TTL? Invalidation?
2. **Gate parallelization**: Can independent gates run in parallel?
3. **DesktopEnvironment persistence**: Store user theme choice? Session state?
4. **TestOrchestrator CI integration**: How to map file changes to gate/test selection?
5. **Future extensibility**: Plugin system for gates? Custom exporters?
