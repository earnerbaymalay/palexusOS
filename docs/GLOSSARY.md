# Glossary

Quick reference for PalexusOS domain terminology and concepts.

---

## Core Concepts

### Design Token
A single value that represents a design decision (e.g., a color, spacing size, or typography style). Tokens are the atomic unit of a design system. PalexusOS uses tokens for `colors`, `typography`, `spacing`, and `radius`.

**Examples**: `color-primary: #cba6f7`, `spacing-md: 16px`, `radius-sm: 4px`

**Related**: TokenRegistry, Token Value, Token Category

---

### Token Category
A grouping of related tokens within a design system layer. Main categories: `colors` (UI colors), `typography` (font sizes/weights), `spacing` (padding/margins), `radius` (border radius), `shadows` (drop shadows).

**Example**: The `colors` category contains `primary`, `secondary`, `accent`, `text`, `background` subcategories.

**Related**: Token, TokenRegistry

---

### Token Layer
A level in the token hierarchy. PalexusOS defines:
- **Primitives**: Raw values (blue/500, font-family-mono)
- **Semantic**: Named for purpose (bg-primary, text-secondary)
- **Component**: Specific to components (button-primary-bg, input-border)

**Usage**: Primitives are source of truth; semantic tokens reference primitives; components reference semantic tokens.

**Related**: Token, Token Inheritance

---

### Gate
A quality verification step that checks a specific aspect of system integrity. PalexusOS includes 5 gates: `Package`, `Graphics`, `ISO`, `Boot`, `Performance`.

**Purpose**: Catch quality regressions early, prevent bad deployments.

**Example**: The `Package` gate verifies Python packaging is correct before distribution.

**Related**: GateRegistry, Gate Result

---

### Gate Result
The outcome of running a gate. Contains: name, passed (bool), and error message if failed.

**Example**: `Result(name="Package", passed=True)`

**Related**: Gate, GateRegistry

---

### Boot Phase
A stage in the system initialization sequence. PalexusOS defines 5 sequential phases:
1. **GREETER**: Display welcome screen
2. **USER_SELECT**: Let user choose identity
3. **HUD**: Initialize heads-up display
4. **THEME**: Apply user's theme choice
5. **COMPLETE**: Finish and transition to running state

**Invariant**: Phases must be executed in order; can't skip or jump ahead.

**Related**: DesktopEnvironment, Boot Context

---

### Boot Context
State maintained during the boot sequence. Tracks: current phase, logged-in user, active theme, HUD state.

**Purpose**: Allow boot phases to communicate and persist settings.

**Example**: Phase 2 sets user; Phase 4 uses it to apply user-specific theme.

**Related**: Boot Phase, DesktopEnvironment

---

### Test Level
A category of tests in the unified testing framework:
- **Unit**: Test single functions in isolation
- **Gate**: Test quality gates (5 gates)
- **Integration**: Test modules working together

**Purpose**: Organize tests by scope and speed.

**Example**: `TestOrchestrator.run_level(Level.UNIT)` runs only unit tests.

**Related**: TestOrchestrator

---

### Module
A self-contained component of PalexusOS with a clear responsibility. The 4 core modules:
- **TokenRegistry**: Design token management
- **GateRegistry**: Quality verification
- **DesktopEnvironment**: Boot orchestration
- **TestOrchestrator**: Unified testing

**Design Principle**: Each module is usable standalone or composed with others.

**Related**: Interface, Depth, Locality

---

## Architecture Concepts

### Interface
The public API of a module—what other modules see and use. Consists of classes, methods, and return types.

**Example**: TokenRegistry interface: `colors()`, `spacing()`, `load()`

**Design Principle**: Interface is minimal and stable; internals can change.

**Related**: Module, Depth

---

### Depth
How much complexity a module hides behind its interface. **Deep modules** are complex inside but have simple interfaces. **Shallow modules** have interfaces nearly as complex as their implementation.

**Example**: TokenRegistry is deep—the interface is simple (`colors()`, `spacing()`) but the implementation handles file I/O, JSON parsing, validation.

**Design Principle**: Prefer deep modules for testability and maintainability.

**Related**: Module, Interface

---

### Locality
How much code needs to be understood to modify a module. High locality means changes are contained; low locality means changes ripple everywhere.

**Example**: TokenRegistry has high locality—changing how colors load affects only the loading code, not the entire codebase.

**Design Principle**: Maximize locality to reduce bugs.

**Related**: Module, Testability

---

### Seam
A boundary between two modules—the place where they interact. Good seams are well-defined interfaces with clear contracts.

**Example**: The seam between TokenRegistry and GateRegistry: GateRegistry calls `registry.colors()`, TokenRegistry returns a dict.

**Design Principle**: Make seams explicit and testable.

**Related**: Interface, Dependency

---

## Design System Concepts

### Design System
A single source of truth for design and UI decisions across a product. Includes tokens (values), components (UI elements), patterns (behaviors), and documentation.

**PalexusOS approach**: Tokens + gates + boot sequences + tests = design system infrastructure.

**Related**: Token, Component, Pattern

---

### Catppuccin Mocha
The default color palette used in PalexusOS design system. A warm, monochromatic dark theme with pastel accent colors.

**Primary accent**: Electric Mauve (#cba6f7)

**Base colors**: Blues, grays, with pastel overlays.

**Usage**: Buttons, highlights, focus states.

**Related**: Token, Color Palette

---

### JetBrains Mono Nerd Font
The default typography used in PalexusOS. A monospace font with Nerd Font glyphs (icons, symbols).

**Usage**: Terminal, code, UI text.

**Weights**: Regular (400), Medium (500), Bold (700).

**Related**: Typography Token

---

### Typography Scale
The set of font sizes used in PalexusOS: `xs` (12px), `sm` (14px), `md` (16px), `lg` (18px), `xl` (20px), `2xl` (24px).

**Purpose**: Consistent text sizing across UI.

**Related**: Typography Token, Scale

---

## Process Concepts

### Ralph Wiggum Methodology
A design and development approach emphasizing:
- **Explicit intent**: Clear purpose and goals
- **Clear boundaries**: Well-defined interfaces
- **Intentional design**: No magic, debuggable
- **Locality**: Changes contained to affected code
- **Testability**: Every feature must be testable

**Named after**: Ralph Wiggum's wisdom: "Me fail English? That's unpossible!" → Fail early and visibly.

**Related**: Module, Locality, Testability

---

### Topological Sorting
An algorithm used by GateRegistry to order gates by dependencies. Example:
- Package gate (no dependencies) runs first
- ISO gate (depends on Package) runs after
- Boot gate (depends on Graphics) runs after Graphics

**Purpose**: Ensure gates run in the correct order.

**Related**: Gate, Dependency

---

### Pre-commit Hook
A Git hook that runs before you commit code. PalexusOS pre-commit hooks:
- Run formatters (black, ruff)
- Run type checker (mypy)
- Run tests
- Verify no secrets committed

**Purpose**: Catch problems before they reach Git history.

**Related**: Commit, Quality

---

### ADR (Architecture Decision Record)
A document recording a significant architectural decision: what it is, why it was chosen, trade-offs, and consequences.

**PalexusOS ADRs**:
- 0001: TokenRegistry design and token format
- 0002: GateRegistry gate system and ordering
- 0003: DesktopEnvironment boot sequence
- 0004: TestOrchestrator test levels

**Purpose**: Make design decisions explicit and revisitable.

**Related**: Architecture, Decision

---

## Community Concepts

### Good First Issue
An issue suitable for new contributors—small, focused, with clear instructions and learning resources.

**Characteristics**: 15-30 minutes, no dependencies, good learning value.

**Example**: "Add docstring to TokenRegistry.colors()"

**Related**: Contribution Ladder

---

### Contribution Ladder
A system for matching contributors to tasks by difficulty:
1. **Good First Issue**: 15-30 min tasks (docstrings, examples)
2. **Help Wanted**: 1-2 hour tasks (new features, bug fixes)
3. **Enhancement**: 2-4 hour tasks (feature design, integration)
4. **Architecture**: 4+ hour tasks (new modules, major refactors)

**Purpose**: Make onboarding smooth and reduce friction.

**Related**: Good First Issue, Difficulty

---

### Semantic Versioning (SemVer)
A versioning scheme: `MAJOR.MINOR.PATCH` (e.g., `1.2.3`)
- **MAJOR**: Breaking changes (rarely)
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes

**PalexusOS approach**: v0.x for rapid evolution, v1.0.0 for stability, follow SemVer strictly after.

**Related**: Release, Version

---

### Release
A versioned snapshot of the codebase, tagged in Git and published to package managers. Includes: version bump, changelog, documentation updates, announcement.

**PalexusOS releases**: Published to PyPI, Arch Linux AUR, GitHub releases.

**Related**: SemVer, Tag

---

### Rollback
Reverting a deployment that caused problems. Strategies:
- Feature flag: Turn off feature if it's broken
- Revert commit: `git revert <commit>`
- Restore backup: Use pre-deployment backup

**Purpose**: Minimize damage from bad deployments.

**Related**: Deploy, Incident

---

## Tools & Technologies

### Makefile
A build automation file defining common tasks:
- `make test` → run tests
- `make lint` → lint code
- `make format` → format code
- `make install-dev` → install with development dependencies

**Usage**: `make <target>`

**Related**: Automation, Development

---

### pytest
Python testing framework used by PalexusOS. Features:
- Parametrized tests
- Fixtures for test setup
- Plugins for extensions
- `-v` for verbose, `-s` to show output

**Example**: `pytest tests/test_design.py -v`

**Related**: Test, Unit Test

---

### mypy
Python type checker. Verifies that type hints are correct and consistent.

**Usage**: `mypy palexus/`

**Related**: Type Hint, Quality

---

### ruff
Fast Python linter. Checks code style and finds errors.

**Usage**: `ruff check palexus/`

**Related**: Lint, Quality

---

### black
Python code formatter. Auto-formats code to a standard style (100-char lines in PalexusOS).

**Usage**: `black palexus/`

**Related**: Format, Quality

---

### GitHub Actions
CI/CD system integrated with GitHub. PalexusOS uses it to:
- Run tests on Python 3.9–3.12
- Lint and type-check code
- Publish releases
- Deploy documentation

**Related**: CI/CD, Deploy

---

## See Also

- [CONTEXT.md](../CONTEXT.md) — Extended domain model
- [ARCHITECTURE.md](design/ARCHITECTURE.md) — System design
- [API_REFERENCE.md](API_REFERENCE.md) — Complete API docs
- [docs/adr/](adr/) — Architecture decision records

---

**Last Updated**: 2026-11-20  
**Status**: ✅ Complete glossary
