# Installation Guide

PalexusOS is a modular, AI-native Linux distribution toolkit available as a Python package. This guide covers installation, setup, and verification.

## System Requirements

- **Python**: 3.11, 3.12, 3.13 or 3.14
- **OS**: Linux, macOS, or Windows (WSL2)
- **Disk**: ~100 MB for core package + dependencies
- **RAM**: 2 GB recommended for full test suite

## Quick Start

### 1. Install from Source (Development)

For contributors and local development:

```bash
# Clone the repository
git clone https://github.com/earnerbaymalay/palexusOS.git
cd palexusOS

# Install in development mode
pip install -e .

# Install with development dependencies (recommended)
pip install -e ".[dev]"

# Verify installation
palexus-design list
palexus-build list
palexus-test list
```

### 2. Install from PyPI (Release)

For end users (once published):

```bash
# Install from PyPI
pip install palexus

# Verify installation
palexus-design --help
```

## Installation Methods

### From Source (Recommended for Contributors)

```bash
git clone https://github.com/earnerbaymalay/palexusOS.git
cd palexusOS
pip install -e ".[dev]"
```

**What this installs:**
- Core PalexusOS package (palexus)
- Development dependencies: pytest, black, mypy, ruff
- Test dependencies

**Verify:**
```bash
make test          # Run full 160+ test suite
make lint          # Check code quality
make format-check  # Verify formatting
```

### From Wheel (Production)

```bash
pip install dist/palexus-0.1.0-py3-none-any.whl
```

### From Source Distribution

```bash
pip install dist/palexus-0.1.0.tar.gz
```

### Via Arch Package (Linux)

For Arch Linux systems (builds locally):

```bash
cd packages/core/palexus-lib
makepkg -si
```

## Verification

After installation, verify each CLI tool works:

```bash
# Design system CLI
palexus-design list          # Show available tokens
palexus-design validate      # Validate token schema
palexus-design export css    # Export to CSS format

# Build system CLI
palexus-build list           # Show quality gates
palexus-build run --all      # Run all gates
palexus-build status         # Check gate status

# Test orchestrator CLI
palexus-test list            # Show available tests
palexus-test run --all       # Run all tests
palexus-test report          # Generate test report
```

## Development Setup

### 1. Install Development Environment

```bash
git clone https://github.com/earnerbaymalay/palexusOS.git
cd palexusOS
pip install -e ".[dev]"
```

### 2. Configure Git Pre-Commit (Optional)

Create `.git/hooks/pre-commit`:

```bash
#!/bin/bash
set -e
make lint
make format-check
make test-quick
```

```bash
chmod +x .git/hooks/pre-commit
```

### 3. Run Full Test Suite

```bash
make test

# Or test individual modules
make test-design      # TokenRegistry tests
make test-build       # GateRegistry tests
make test-desktop     # DesktopEnvironment tests
```

## Common Tasks

### Run Tests

```bash
# Quick mode (quiet)
make test-quick

# Full suite with output
make test

# Verbose with tracebacks
make test-verbose

# Single test module
make test-design
```

### Format Code

```bash
# Auto-format with black
make format

# Check formatting without changes
make format-check

# Check with ruff
make lint
```

### View Documentation

```bash
# Quick links to all docs
make docs

# List architecture decisions
make docs-adr

# View Ralph Wiggum methodology principles
make ralph
```

### Build Package

```bash
# Build wheel and source distribution
make build

# Build Arch package
make pkg-build
```

## Troubleshooting

### "Command not found: palexus-design"

**Issue**: CLI tools not found after installation

**Solution**: Ensure installation was successful:

```bash
pip install -e .
python -m palexus.design.cli --help
```

If still not found, verify pip location:

```bash
which pip
which python
pip show palexus
```

### "No module named palexus"

**Issue**: Import fails despite installation

**Solution**: Verify package is installed in the active Python:

```bash
python -c "import palexus; print(palexus.__file__)"
```

If not found, reinstall:

```bash
pip uninstall palexus -y
pip install -e .
```

### Tests Fail on Import

**Issue**: PyQt6 or other optional dependencies missing

**Solution**: Install test dependencies explicitly:

```bash
pip install -e ".[test]"
make test
```

### "ModuleNotFoundError" During Tests

**Issue**: Module import path issue

**Solution**: Verify pytest can find modules:

```bash
python -m pytest tests/ -v
```

If still failing, check PYTHONPATH:

```bash
export PYTHONPATH=/home/user/palexusOS:$PYTHONPATH
make test
```

### Installation Hangs or Fails

**Issue**: Network or build issues

**Solution**: Try with more verbose output:

```bash
pip install -e . -v
```

If build fails, check Python version:

```bash
python --version  # Must be 3.11+
```

For Arch packages, check dependencies:

```bash
cd packages/core/palexus-lib
makepkg -si --nocheck  # Skip tests during build
```

## Upgrading

### From Earlier Version

```bash
pip install --upgrade palexus
```

Or from source:

```bash
git pull origin main
pip install -e . --upgrade
make test
```

## Uninstalling

```bash
pip uninstall palexus -y
```

## Next Steps

After installation:

1. **Read** `QUICKSTART.md` for common development tasks
2. **Explore** `CONTEXT.md` to understand the domain model
3. **Review** `ARCHITECTURE.md` to find module ownership
4. **Check** `CONTRIBUTING.md` for the contribution workflow
5. **Run** `make ralph` to understand the design methodology

## Support

- **Documentation**: Read `QUICKSTART.md`, `ARCHITECTURE.md`, `CONTEXT.md`
- **Issues**: Check existing issues or create a new one
- **Contributing**: See `CONTRIBUTING.md` for the full workflow
- **Architecture**: Review ADRs in `docs/adr/` for design decisions

## Security

PalexusOS follows these security practices:

- No secrets in repository (checked by git hooks)
- All dependencies specified in `pyproject.toml`
- Code quality enforced by linting and type checking
- Tests run on every commit via GitHub Actions

For security concerns, see `CONTRIBUTING.md` for responsible disclosure.

---

**Version**: 0.1.0
**Last Updated**: 2026-11-20
**Maintainer**: earnerbaymalay
