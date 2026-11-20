# Quick Reference

One-page cheat sheet for common PalexusOS tasks.

---

## Installation

```bash
# From source
git clone https://github.com/earnerbaymalay/palexusOS.git
cd palexusOS
pip install -e .

# From PyPI (future)
pip install palexus

# Verify
python -c "from palexus import *; print('✓ Ready')"
```

---

## Common Commands

```bash
# Setup development environment
make setup

# Run all tests
make test

# Format code
make format

# Lint code
make lint

# Type check
make type-check

# Run specific test
python -m pytest tests/test_design.py::TestTokenRegistry::test_colors -v

# Run specific level
python -m pytest tests/ -k design

# Show test output
python -m pytest tests/ -s

# Generate HTML report
pytest --html=report.html tests/
```

---

## TokenRegistry

```python
from pathlib import Path
from palexus.design.token_registry import TokenRegistry

# Load tokens
registry = TokenRegistry(Path("docs/design-system/tokens.json"))

# Access tokens
colors = registry.colors()
spacing = registry.spacing()
typography = registry.typography()

# By category
primary_color = registry.colors("primary")

# Export formats
css = registry.export_css()          # CSS variables
shell = registry.export_shell()      # Shell env vars
kitty = registry.export_kitty()      # Kitty terminal config
xfce = registry.export_xfce()        # XFCE theme

# Write to file
Path("styles/tokens.css").write_text(registry.export_css())
```

---

## GateRegistry

```python
from palexus.build.gate_registry import GateRegistry

# Create registry
registry = GateRegistry()

# Run all gates
results = registry.run()

# Run specific gate
results = registry.run(selected=["Package"])

# Check results
for result in results:
    if result.passed:
        print(f"✓ {result.name}")
    else:
        print(f"✗ {result.name}: {result.error}")

# Filter by status
failed = [r for r in results if not r.passed]
print(f"Failed gates: {len(failed)}")

# Get gate info
for gate in registry.gates:
    print(f"{gate.name}: depends on {gate.dependencies}")
```

---

## DesktopEnvironment

```python
from palexus.desktop.environment import DesktopEnvironment, BootPhase

# Create environment
env = DesktopEnvironment()
context = env.boot_context

# Boot sequence (must be in order)
context.advance_phase(BootPhase.GREETER)
context.advance_phase(BootPhase.USER_SELECT)
context.set_user("alice")

context.advance_phase(BootPhase.HUD)
context.set_hud_enabled(True)

context.advance_phase(BootPhase.THEME)
context.set_theme("catppuccin-mocha")

context.advance_phase(BootPhase.COMPLETE)

# Get context
print(f"User: {context.get_user()}")
print(f"Theme: {context.get_theme()}")
print(f"Phase: {context.current_phase}")
```

---

## TestOrchestrator

```python
from palexus.test.orchestrator import TestOrchestrator, Level

# Create orchestrator
orchestrator = TestOrchestrator()

# Run all tests
results = orchestrator.run_all()

# Run specific level
unit_results = orchestrator.run_level(Level.UNIT)
gate_results = orchestrator.run_level(Level.GATE)
integration_results = orchestrator.run_level(Level.INTEGRATION)

# Check results
if orchestrator.all_passed():
    print("✓ All tests passed")
else:
    print(orchestrator.report_failures())

# Get summary
print(orchestrator.summary())

# Filter results
failed = orchestrator.filter_by_status(passed=False)
print(f"Failed tests: {len(failed)}")
```

---

## Git Workflow

```bash
# Update your local copy
git pull origin main

# Create feature branch
git checkout -b feature/your-feature-name

# Check what changed
git status

# Stage changes
git add path/to/file.py

# Commit
git commit -m "feat: Short description

Longer explanation if needed.

- Bullet point 1
- Bullet point 2"

# Push
git push -u origin feature/your-feature-name

# Create PR on GitHub

# Update PR with new changes
git add path/to/file.py
git commit -m "refactor: Address review feedback"
git push origin feature/your-feature-name

# After PR merges, clean up
git checkout main
git pull origin main
git branch -d feature/your-feature-name
```

---

## Debugging

```python
# Print debug info
from palexus.design.token_registry import TokenRegistry

registry = TokenRegistry(...)

# What's in it?
print(dir(registry))

# Check a specific token
print(registry._data.get("colors", {}).get("primary"))

# Type of object
print(type(registry))

# Inspect method signature
import inspect
print(inspect.signature(registry.colors))

# See docstring
print(registry.colors.__doc__)
```

```bash
# Run test with pdb debugger
python -m pytest tests/test_design.py::TestTokenRegistry::test_colors -v --pdb

# When stopped, use:
# n     = next line
# s     = step into
# c     = continue
# l     = list code
# p x   = print variable x
# pp x  = pretty print x
# h     = help
```

---

## Common Issues

| Issue | Solution |
|-------|----------|
| `ModuleNotFoundError: No module named 'palexus'` | Run `pip install -e .` from project root |
| Tests fail: `FileNotFoundError: tokens.json` | Make sure `docs/design-system/tokens.json` exists |
| Black reformatted files | Run `make format` before committing |
| Ruff linting errors | Run `make lint` to see errors, then `make format` to fix |
| Type checking fails | Add type hints to functions or add `# type: ignore` comment |
| Import error in tests | Check PYTHONPATH: `export PYTHONPATH=.:$PYTHONPATH` |
| Merge conflict | Edit file, remove conflict markers, stage, commit |

---

## Documentation Map

| Need | Read |
|------|------|
| "What is PalexusOS?" | [README.md](../README.md) |
| "How do I install?" | [INSTALL.md](../INSTALL.md) |
| "First 30 minutes" | [GETTING_STARTED_TUTORIAL.md](GETTING_STARTED_TUTORIAL.md) |
| "How do modules work?" | [ARCHITECTURE.md](ARCHITECTURE.md) |
| "API details" | [API_REFERENCE.md](API_REFERENCE.md) |
| "How do I extend?" | [DEVELOPER_HANDBOOK.md](DEVELOPER_HANDBOOK.md) |
| "How do I contribute?" | [CONTRIBUTING.md](../CONTRIBUTING.md) |
| "Issues by difficulty" | [CONTRIBUTION_LADDER.md](CONTRIBUTION_LADDER.md) |
| "I'm stuck" | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |
| "Design decisions" | [docs/adr/](adr/) |
| "Design tokens & system" | [CONTEXT.md](CONTEXT.md) |

---

## Environment Variables

```bash
# Debug output
export DEBUG=1
python -m pytest tests/ -s

# Specific test level
export TEST_LEVEL=unit  # or gate, integration

# Custom token file
export TOKENS_FILE=/path/to/tokens.json
python -c "from palexus import *; ..."

# Verbose logging
export LOG_LEVEL=DEBUG
make test
```

---

## Keyboard Shortcuts (IDE)

```
Ctrl+K Ctrl+F    Format document (VSCode + Black)
Ctrl+K Ctrl+L    Go to line
Ctrl+Shift+P     Open command palette (VSCode)
Ctrl+/           Toggle comment
Ctrl+D           Select word (VSCode)
Ctrl+Shift+L     Select all occurrences
Alt+Arrow Up     Move line up (VSCode)
Alt+Arrow Down   Move line down (VSCode)
```

---

## File Structure Quick Reference

```
palexusOS/
├── palexus/                    # Main package
│   ├── design/                 # Token management
│   │   └── token_registry.py
│   ├── build/                  # Quality gates
│   │   └── gate_registry.py
│   ├── desktop/                # Boot orchestration
│   │   └── environment.py
│   └── test/                   # Test framework
│       └── orchestrator.py
├── tests/                      # Test files (160+ tests)
│   ├── test_design.py
│   ├── test_build.py
│   ├── test_desktop.py
│   └── test_test.py
├── docs/                       # Documentation
│   ├── ARCHITECTURE.md
│   ├── CONTEXT.md
│   ├── adr/                    # Architecture decisions
│   └── ...
├── examples/                   # Complete examples
│   └── 01-04_*.py
├── Makefile                    # Common commands
├── pyproject.toml              # Python config
├── pytest.ini                  # Test config
└── .github/workflows/          # CI/CD
    └── test.yml
```

---

## Performance Targets

```
Test suite:               < 30 seconds
Single test:              < 1 second
Gate verification:        < 5 seconds
Token export:             < 100ms
Memory usage:             < 500MB
Code coverage:            > 90%
Test pass rate:           100%
```

---

## Useful Links

- **GitHub**: https://github.com/earnerbaymalay/palexusOS
- **Issues**: https://github.com/earnerbaymalay/palexusOS/issues
- **Pull Requests**: https://github.com/earnerbaymalay/palexusOS/pulls
- **Discussions**: https://github.com/earnerbaymalay/palexusOS/discussions
- **Releases**: https://github.com/earnerbaymalay/palexusOS/releases

---

## Checklists

### Before Committing

```
□ make test          (all 160+ pass)
□ make lint          (no errors)
□ make type-check    (no errors)
□ make format        (code formatted)
□ git status         (review changes)
□ git diff           (review code)
```

### Before Opening a PR

```
□ Branch name clear (feature/xyz)
□ Commits logical (1-2 commits per feature)
□ Tests added (all scenarios covered)
□ Docs updated (docstrings, README)
□ No debug code (console.log, print, debugger)
□ No secrets (API keys, passwords)
```

### Before Merging to Main

```
□ All tests pass
□ All reviews approved
□ Conflicts resolved
□ Linked issues/PRs
□ Changelog updated
```

---

## Alfred / Command Palette

Customize your CLI or IDE with these snippets:

```bash
# Git workflow
alias gpf="git push -u origin $(git rev-parse --abbrev-ref HEAD)"
alias gpb="git checkout -b"
alias gpr="git pull --rebase"

# Testing
alias mt="make test"
alias ml="make lint"
alias mf="make format"

# Common operations
alias pd="python -c \"from pathlib import Path; print(Path.cwd())\""
alias venv="source venv/bin/activate"
```

---

**Last Updated**: 2026-11-20  
**Status**: ✅ Complete quick reference
