# Changelog

All notable changes to PalexusOS are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added
- Initial architecture design with 4 core modules
- TokenRegistry for unified design token management (4 format exporters: CSS, Shell, Kitty, XFCE)
- GateRegistry for quality verification (5 independent gates with topological dependency sorting)
- DesktopEnvironment with explicit 5-phase boot sequence (GREETER → USER_SELECT → HUD → THEME → COMPLETE)
- TestOrchestrator for unified test framework (unit + gate + integration)
- Unit, gate and integration tests for all four modules (`pytest tests/`)
- CLI tools for design system (palexus-design), build system (palexus-build), and test orchestration (palexus-test)
- GitHub Actions CI/CD workflows for multi-version Python testing (3.11–3.14)
- Modern Python packaging with pyproject.toml (PEP 517/518)
- Comprehensive documentation: CONTEXT.md, ARCHITECTURE.md, QUICKSTART.md
- 4 Architecture Decision Records (ADRs) documenting core design decisions
- Developer Makefile with 20+ convenience targets
- Contributor guidelines (CONTRIBUTING.md)
- Pull request and issue templates
- Installation guide (INSTALL.md)
- Release guide (RELEASE.md)

### Module Details

#### TokenRegistry (ADR-0001)
- Design token registry with primitives → semantics → scopes flow
- Support for colors, typography, spacing, radii, effects
- 4 format exporters: CSS variables, shell functions, Kitty conf, XFCE theme
- Catppuccin Mocha Mauve palette with Electric Mauve (#cba6f7) accent
- JetBrains Mono Nerd Font integration

#### GateRegistry (ADR-0002)
- 5 quality gates: Package, ISO, Graphics, Boot, Performance
- Topological dependency sorting for execution order
- Independent verification interface
- Idempotent gate execution

#### DesktopEnvironment (ADR-0003)
- Explicit 5-phase boot orchestration
- Adapter pattern for desktop environment integration
- Context firewall for boot state management
- Deterministic phase transitions

#### TestOrchestrator (ADR-0004)
- Unified test framework bridging unit, gate, and integration tests
- Suite and Level abstraction
- Result tracking with passed/failed/skipped counts
- Failure reporting mechanism

### CLI Tools

#### palexus-design
- `list` - Show available tokens
- `validate` - Verify token schema
- `export` - Output tokens in multiple formats (css, shell, kitty, xfce)

#### palexus-build
- `run` - Execute quality gates
- `list` - Show available gates
- `status` - Display gate results

#### palexus-test
- `run` - Execute tests (all, unit, gate, integration)
- `list` - Show test types
- `report` - Generate test report

### Packaging & Distribution

#### Arch Linux Package (palexus-lib PKGBUILD)
- Installs all core Python modules
- Distributes documentation and ADRs
- Runs pytest during package build (quality gate)
- Multi-version Python support (3.9–3.12)

#### Python Packaging (pyproject.toml)
- Modern setuptools-based build system
- Explicit dependencies: none for core, pytest/black/mypy/ruff for dev/test
- Entry points for all CLI tools
- Configured for PyPI publication

#### Distributions
- Wheel (.whl) for binary installation
- Source distribution (.tar.gz) for source builds
- Arch Linux PKGBUILD for native integration

### Code Quality

#### Linting & Formatting
- Ruff for static analysis (E501 override for long lines)
- Black for code formatting (100 char line length)
- Multi-version Python validation (3.9–3.12)

#### Testing
- 160+ tests across all modules
- Unit tests for each module's functionality
- Integration tests for boot sequence and module interactions
- Test count verification in CI/CD (>= 160 required)

#### Documentation
- README.md with quick links to docs
- CONTEXT.md with domain vocabulary (200+ lines)
- ARCHITECTURE.md with module ownership (280+ lines)
- QUICKSTART.md with developer onboarding (210+ lines)
- 4 ADRs documenting rationale for each deepening

### Ralph Wiggum Methodology

- **Explicit Intent**: Clear ownership and contracts in ARCHITECTURE.md
- **Clear Boundaries**: Module interfaces documented in CONTEXT.md
- **Intentional Design**: Decisions recorded in ADRs
- **Locality**: Changes scoped to individual modules
- **Testability**: 160+ tests verify each module

### Infrastructure

#### GitHub Actions Workflows

**tests.yml**: Multi-version Python testing
- Runs on Python 3.9, 3.10, 3.11, 3.12
- Executes full test suite with pytest -v
- Verifies test count >= 160
- Ruff linting on palexus/ and tests/
- Black formatting check (100 char line)

**build.yml**: Quality gates and distribution
- Verifies package builds as wheel and sdist
- Checks package structure integrity
- Verifies all 160+ tests pass
- Uploads distributions as artifacts (7 day retention)

#### Development Tools

**Makefile** with targets:
- Testing: test, test-quick, test-verbose, test-design, test-build, test-desktop
- Quality: lint (ruff), format (black), format-check
- Development: install, install-dev, dev
- CLI: cli-design, cli-build, cli-test
- Documentation: docs, docs-adr, ralph
- Package: build, pkg-build
- Utilities: clean, clean-all, status

## Version History

### [0.1.0] - 2026-11-20

**Initial Release**

This is the first production release of PalexusOS with complete architecture design, 4 core modules, 160+ tests, and comprehensive documentation.

- TokenRegistry for design token management
- GateRegistry for quality verification
- DesktopEnvironment for boot orchestration
- TestOrchestrator for unified testing
- Complete documentation and ADRs
- GitHub Actions CI/CD
- Modern Python packaging
- Contributor workflows

---

## Guidelines

### How to Report a Bug

Report bugs as GitHub issues with:
- Clear reproduction steps
- Expected vs actual behavior
- Python version and OS
- Relevant error output

### How to Request a Feature

Request features with:
- Clear use case
- Proposed API or workflow
- Affected module(s)
- Alternatives considered

### How to Contribute

See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Development setup
- Testing requirements
- Commit conventions
- Review process
- Release criteria

---

**Maintainer**: earnerbaymalay  
**Repository**: https://github.com/earnerbaymalay/palexusOS  
**License**: Apache 2.0 (assumed)
