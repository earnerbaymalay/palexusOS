# PalexusOS Architecture

## Overview

PalexusOS is an **AI-native rolling Linux distribution** with deep architectural modularity. This document guides developers through the codebase structure, module ownership, and design decisions.

**Start here**: Read [CONTEXT.md](CONTEXT.md) for domain terminology and vocabulary.

## Core Modules (Deepenings)

### 1. TokenRegistry (Design System)
**Location**: `palexus/design/token_registry.py`  
**Purpose**: Single source of truth for all design tokens (colors, typography, spacing, shadows)

**Owns**:
- Loading, parsing, validating tokens.json
- Token schema and versioning
- Exporting to CSS, shell, Kitty, XFCE formats

**How to add a token**:
1. Edit `docs/design-system/tokens.json`
2. Update TokenRegistry schema if adding new token type
3. Run tests: `python -m pytest tests/test_design.py`

**Exporters** (read from TokenRegistry, write format-specific files):
- `CSSExporter` → CSS custom properties
- `ShellExporter` → Shell aliases
- `KittyExporter` → Kitty terminal config
- `XFCEExporter` → XFCE theme colors

**Key insight**: Adding a new token or exporter no longer requires touching multiple files.

---

### 2. GateRegistry (Build Quality)
**Location**: `palexus/build/gate_registry.py`  
**Purpose**: Quality verification gates (package, ISO, graphics, boot, performance)

**Owns**:
- Gate definitions and execution
- Dependency resolution (ISO depends on Package)
- Gate ordering and selection

**Gate Classes**:
- `PackageGate` (G1): Build all packages successfully
- `ISOGate` (G2): Create bootable ISO
- `GraphicsGate` (G3): Qt6 rendering works
- `BootGate` (G4): QEMU boot to login
- `PerfGate` (G5): Build time within target

**How to add Gate #6**:
1. Create new Gate class in `palexus/build/gates.py`
2. Declare name, description, dependencies
3. Implement run() method
4. Register in GateRegistry

**Run specific gates**:
```bash
python -m palexus.build run --gate package
python -m palexus.build run --gates iso,graphics
```

**Key insight**: Gates are now independently testable and can run in CI on-demand.

---

### 3. DesktopEnvironment (Boot Sequence)
**Location**: `palexus/desktop/environment.py`  
**Purpose**: Explicit, testable boot sequence orchestration

**Boot Phases** (in order):
1. `GREETER` → User selection (GreeterAdapter)
2. `USER_SELECT` → User confirmed
3. `HUD` → LLM command panel (HUDAdapter)
4. `THEME` → Theme application (ThemeAdapter)
5. `COMPLETE` → Ready

**Adapters** (implement boot interfaces):
- `GreeterAdapter`: Wraps palexus-greeter
- `HUDAdapter`: Wraps llm-quickfire-panel
- `ThemeAdapter`: Loads design tokens, applies theme

**Usage**:
```python
from palexus.desktop import DesktopEnvironment

env = DesktopEnvironment()
context = env.boot()  # Execute full sequence

hud_status = env.hud_interface()  # Check HUD state
```

**Key insight**: Boot order is now explicit and each component can be tested in isolation.

---

### 4. TestOrchestrator (Unified Testing)
**Location**: `palexus/test/orchestrator.py`  
**Purpose**: Unified interface for unit, gate, and integration tests

**Test Levels**:
- `Level.UNIT`: Python unit tests
- `Level.GATE`: Quality gate tests
- `Level.INTEGRATION`: End-to-end boot
- `Level.ALL`: Everything

**Usage**:
```bash
python -m palexus.test run --all                 # All tests
python -m palexus.test run --gate package        # Single gate
python -m palexus.test run --integration         # Boot sequence
```

**Key insight**: New quality checks register with orchestrator and inherit framework.

---

## Architecture Vocabulary

**Module**: A unit of code with clear boundary, owned concepts, hidden implementation.

**Interface**: Public contract (what consumers depend on). Separates public from private.

**Depth**: Ratio of interface complexity to implementation complexity. Deep modules have simple interfaces hiding substantial complexity.

**Seam**: Boundary between modules. Where one module ends, another begins.

**Adapter**: Translates between two interfaces. Sits at a seam.

**Locality**: How much code changes when you change one concept. High locality = changes localized. Low locality = changes scatter.

---

## Repository Structure

```
palexusOS/
├── palexus/                    # Core Python modules
│   ├── design/                 # TokenRegistry + exporters
│   ├── build/                  # GateRegistry + gates
│   ├── desktop/                # DesktopEnvironment + adapters
│   └── test/                   # TestOrchestrator
├── packages/                   # Arch PKGBUILD definitions
│   ├── core/                   # System fundamentals
│   ├── desktop/                # Greeter, HUD, themes
│   ├── tools/                  # CLI utilities
│   └── ai/                     # LLM integrations
├── build/                      # ISO generation, verification
├── overlay/                    # System configuration (/etc, /usr/share, /etc/skel)
├── docs/
│   ├── design-system/          # Tokens, integration guide
│   └── adr/                    # Architecture decision records
├── scripts/                    # Build utilities (design generation, CI)
├── tests/                      # Python unit tests
└── CONTEXT.md                  # Domain model & terminology
```

---

## ADRs (Decisions)

- **ADR-0001**: [TokenRegistry](docs/adr/0001-token-registry.md) — Design system deepening
- **ADR-0002**: [GateRegistry](docs/adr/0002-gate-registry.md) — Build quality gates
- **ADR-0003**: [DesktopEnvironment](docs/adr/0003-desktop-environment.md) — Boot sequence
- **ADR-0004**: [TestOrchestrator](docs/adr/0004-test-orchestrator.md) — Unified testing

---

## Development Workflow

### Add a new design token
1. Edit `docs/design-system/tokens.json`
2. Update TokenRegistry schema if needed
3. `python -m pytest tests/test_design.py`
4. Commit with attribution

### Add a new quality gate
1. Create new Gate class in `palexus/build/gates.py`
2. Write test in `tests/test_build.py`
3. Register in GateRegistry
4. `python -m pytest tests/test_build.py`
5. Commit with attribution

### Add a new test
1. Write in `tests/` following pytest patterns
2. Register with TestOrchestrator if appropriate
3. `python -m pytest tests/`
4. Commit with attribution

---

## Key Design Principles

1. **Locality**: Changes to one concept should localize (not scatter across codebase)
2. **Testability**: Modules can be tested independently
3. **Extensibility**: Adding new functionality doesn't require rewriting existing modules
4. **Clarity**: Module ownership and contracts explicit
5. **Intentionality**: Every design decision recorded (ADRs)

---

## Running Tests

```bash
# All tests
python -m pytest tests/

# Specific module
python -m pytest tests/test_design.py -v
python -m pytest tests/test_build.py -v
python -m pytest tests/test_desktop.py -v

# Skip slow tests (PyQt6, graphics)
python -m pytest tests/ -m "not slow"
```

---

## Questions?

See [CONTEXT.md](CONTEXT.md) for domain terminology.  
Check [docs/adr/](docs/adr/) for specific decisions.  
Run tests with `python -m pytest tests/ -v` to verify changes.

