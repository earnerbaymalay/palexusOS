# Troubleshooting & FAQ

Solutions for common issues when working with PalexusOS.

---

## Table of Contents

1. [Installation Issues](#installation-issues)
2. [Development Environment](#development-environment)
3. [Testing Problems](#testing-problems)
4. [Module-Specific Issues](#module-specific-issues)
5. [Git & Workflow](#git--workflow)
6. [Performance](#performance)
7. [FAQ](#faq)

---

## Installation Issues

### "No module named 'palexus'"

**Symptom**: `ModuleNotFoundError: No module named 'palexus'`

**Cause**: Package not installed in current Python environment

**Solution**:
```bash
# Install in development mode
pip install -e .

# Verify installation
python -c "import palexus; print(palexus.__file__)"
```

**Advanced**:
```bash
# Install with development dependencies
pip install -e ".[dev]"

# Check which Python and pip are being used
which python
which pip

# Verify correct environment
python -m site
```

---

### "ERROR: FileNotFoundError: [Errno 2] No such file"

**Symptom**: Build fails with file not found error

**Cause**: Missing source files, not running from project root, or file path issue

**Solution**:
```bash
# Make sure you're in project root
pwd  # Should end with /palexusOS

ls palexus/     # Verify source structure
ls tests/       # Verify test structure

# Try installation again from project root
pip install -e .
```

---

### "ERROR: Setuptools >= 65 required"

**Symptom**: Build fails with setuptools version error

**Cause**: Old setuptools installed

**Solution**:
```bash
pip install --upgrade setuptools wheel build
pip install -e .
```

---

## Development Environment

### "Black reformatted X files"

**Symptom**: Black changes files but doesn't fail the build

**Cause**: Code formatting differs from project style (100-char line length)

**Solution**:
```bash
# Format all code
make format

# Check what Black would do without changing files
make format-check

# Configure IDE to use Black
# VSCode: Install Black Formatter extension
# PyCharm: Settings → Tools → Python Integrated Tools → Black
```

---

### "Ruff found issues"

**Symptom**: Linting fails with ruff errors

**Cause**: Code style violations or unused imports

**Solution**:
```bash
# See what ruff found
make lint

# Common fixes:
# - Remove unused imports
# - Fix line too long (but we override this, so usually not an issue)
# - Remove trailing whitespace

# Format with Black to fix many issues automatically
make format

# Re-lint
make lint
```

---

### "mypy: error: incompatible types"

**Symptom**: Type checking fails with incompatibility errors

**Cause**: Type hints mismatch or missing annotations

**Solution**:
```bash
# See type errors
python -m mypy palexus/

# Add type hints to fix
# Example: def foo(x: str) -> int: return len(x)

# Or suppress if false positive (use sparingly)
# x = foo()  # type: ignore
```

---

## Testing Problems

### "FAILED: test count verification"

**Symptom**: Tests pass but CI reports "Expected at least 160 tests"

**Cause**: Test collection issue or tests removed

**Solution**:
```bash
# Count tests
python -m pytest tests/ --co -q | tail -1

# If less than 160, check what happened:
git diff HEAD~1 tests/  # What changed?

# Collect tests from specific modules
python -m pytest tests/test_design.py --co -q
python -m pytest tests/test_build.py --co -q
```

---

### "ModuleNotFoundError: test imports fail"

**Symptom**: Tests fail with import errors

**Cause**: PYTHONPATH not set or module structure wrong

**Solution**:
```bash
# Try pytest from project root
cd /path/to/palexusOS
python -m pytest tests/

# Or set PYTHONPATH
export PYTHONPATH=/path/to/palexusOS:$PYTHONPATH
pytest tests/

# Check module structure
ls palexus/__init__.py     # Should exist
ls palexus/design/__init__.py  # Should exist
```

---

### "test_xyz.py skipped"

**Symptom**: Some tests are skipped (marked with `s`)

**Cause**: Conditional skip decorator (usually missing optional dependency)

**Solution**:
```bash
# See why tests were skipped
python -m pytest tests/ -v | grep SKIP

# Install optional dependencies
pip install -e ".[test]"

# Re-run tests
make test
```

---

### "DeadlineExceeded: timeout"

**Symptom**: Tests timeout after 30 seconds

**Cause**: Test takes too long or hangs

**Solution**:
```bash
# Run single slow test to debug
python -m pytest tests/test_slow.py -v -s

# Add timeout in code if needed
import pytest

@pytest.mark.timeout(10)  # 10 second timeout
def test_something():
    ...
```

---

## Module-Specific Issues

### TokenRegistry

#### "FileNotFoundError: tokens.json not found"

**Solution**:
```bash
# Check if file exists
ls docs/design-system/tokens.json

# Create if missing (or copy from example)
mkdir -p docs/design-system/

# Verify path in code
# registry = TokenRegistry(Path("docs/design-system/tokens.json"))
```

---

#### "ValueError: Missing required token sections"

**Solution**:
```bash
# Check tokens.json structure
python -c "
import json
with open('docs/design-system/tokens.json') as f:
    data = json.load(f)
    print('Sections:', list(data.keys()))
    # Must have: colors, typography, spacing, radius
"

# Add missing sections to tokens.json
```

---

### GateRegistry

#### "No gates available"

**Solution**:
```bash
# Check gate_registry.py
ls palexus/build/gate_registry.py

# Verify gates initialized
python -c "
from palexus.build.gate_registry import GateRegistry
r = GateRegistry()
print(f'Gates: {len(r.gates)}')
for g in r.gates:
    print(f'  - {g}')
"
```

---

### DesktopEnvironment

#### "AttributeError: 'BootContext' object has no attribute 'current_phase'"

**Cause**: Code or an older doc written against an API that never existed.
`BootContext` is a dataclass with four fields: `phase`, `selected_user`,
`selected_theme` and `hud_enabled`. There are no `advance_phase()`,
`set_user()` or `set_theme()` methods; set fields directly and call `boot()`.

**Solution**:
```python
env = DesktopEnvironment()
env.context.hud_enabled = False
context = env.boot()
print(context.phase, context.selected_user)
```

See [API_REFERENCE.md](API_REFERENCE.md#palexusdesktop--desktopenvironment).

---

### TestOrchestrator

#### "TypeError: TestOrchestrator() takes X arguments"

**Solution**:
```bash
# Check constructor signature
python -c "
from palexus.test.orchestrator import TestOrchestrator
import inspect
print(inspect.signature(TestOrchestrator.__init__))
"

# Use correct arguments
```

---

## Git & Workflow

### "fatal: not a git repository"

**Symptom**: Git commands fail

**Solution**:
```bash
# Navigate to project root
cd /path/to/palexusOS

# Verify .git exists
ls -la .git/

# If not, initialize (only if needed)
git init
```

---

### "Your branch is ahead of 'origin/main' by X commits"

**Symptom**: Local commits not pushed

**Solution**:
```bash
# See unpushed commits
git log origin/main..HEAD

# Push to remote
git push origin main

# Or push branch
git push -u origin your-branch-name
```

---

### "Merge conflict"

**Symptom**: Merge/pull fails with conflict

**Solution**:
```bash
# See conflicted files
git status

# Edit conflicted files, remove conflict markers:
# <<<<<<< HEAD
# your code
# =======
# their code
# >>>>>>> branch-name

# Keep what you want, remove markers

# Stage and continue
git add .
git commit -m "Resolve merge conflict"

# Or abort
git merge --abort
```

---

### "detached HEAD"

**Symptom**: Git says you're in detached HEAD state

**Solution**:
```bash
# Get back to main branch
git checkout main

# Or create a branch from current state
git checkout -b new-branch-name
```

---

## Performance

### "Tests are very slow"

**Symptom**: `make test` takes > 30 seconds

**Cause**: I/O bound operations, file system slow, or missing optimization

**Solution**:
```bash
# Profile a test
python -m pytest tests/test_design.py::TestTokenRegistry::test_load \
  -v

# Use --durations to see slowest tests
python -m pytest tests/ --durations=10

# Run only fast tests
python -m pytest tests/ -m "not slow"
```

---

### "Memory usage high"

**Symptom**: Python uses lots of memory running tests

**Cause**: Loading large fixtures or not cleaning up

**Solution**:
```bash
# Monitor memory
watch -n 1 'ps aux | grep python'

# Run tests one at a time
python -m pytest tests/test_design.py -v

# Check for memory leaks in code
# - Close files properly: with open(...) as f:
# - Don't store test results: use fixtures with cleanup
```

---

## FAQ

### "How do I add a new token type?"

**Answer**: See [DEVELOPER_HANDBOOK.md → Adding Token Types](DEVELOPER_HANDBOOK.md#tokenregistry-adding-token-types)

```python
# 1. Add method to TokenRegistry
def new_tokens(self, category=None):
    tokens = self._data.get("new_tokens", {})
    return tokens.get(category, {}) if category else tokens

# 2. Write test first
def test_new_tokens():
    registry = TokenRegistry(test_file)
    tokens = registry.new_tokens()
    assert len(tokens) > 0

# 3. Update tokens.json with new section
# 4. Add export method (export_new_tokens)
```

---

### "How do I create a custom gate?"

**Answer**: See [DEVELOPER_HANDBOOK.md → Creating Custom Gates](DEVELOPER_HANDBOOK.md#gateregistry-creating-custom-gates)

---

### "How do I add a new boot phase?"

**Answer**: See [DEVELOPER_HANDBOOK.md → Custom Boot Phases](DEVELOPER_HANDBOOK.md#desktopenv-custom-boot-phases)

---

### "How do I run only design tests?"

```bash
make test-design
# Or
python -m pytest tests/test_design.py -v
```

---

### "How do I run a single test?"

```bash
python -m pytest tests/test_design.py::TestTokenRegistry::test_colors \
  -v
```

---

### "How do I see test output?"

```bash
# Show print() statements
python -m pytest tests/ -s

# Show more verbose output
python -m pytest tests/ -vv

# Show very verbose (all details)
python -m pytest tests/ -vvv
```

---

### "How do I skip a test temporarily?"

```python
@pytest.mark.skip(reason="WIP")
def test_something():
    ...

# Or mark as expected to fail
@pytest.mark.xfail(reason="Known issue")
def test_something_broken():
    ...
```

---

### "How do I debug a failing test?"

```bash
# Run with debugger
python -m pytest tests/test_design.py::TestTokenRegistry::test_colors \
  -v --pdb

# Or use print and -s flag to see output
def test_something():
    x = compute()
    print(f"DEBUG: x = {x}")
    assert x == expected

python -m pytest tests/ -s
```

---

### "What's the commit message style?"

```bash
# Format:
# <type>: <subject>
#
# <body>

# Types: feat, fix, docs, style, refactor, test, chore

# Example:
# feat: Add transition token type
#
# Add transitions as first-class tokens in TokenRegistry.
# Support fast/normal/slow timing functions.
#
# - Add transitions() method
# - Add export_transitions() 
# - Update tokens.json schema
```

---

### "How do I revert a commit?"

```bash
# See recent commits
git log --oneline -10

# Create a revert commit (doesn't delete history)
git revert <commit-hash>

# Or reset if not pushed yet
git reset --soft HEAD~1  # Keep changes
git reset --hard HEAD~1  # Discard changes
```

---

### "How do I see what I changed?"

```bash
# See unstaged changes
git diff

# See staged changes
git diff --staged

# See changes in last commit
git show HEAD

# See changes in specific file
git diff palexus/design/token_registry.py
```

---

### "Can I work on multiple features at once?"

```bash
# Create separate branches
git checkout -b feature-1
# ... work on feature-1 ...

git checkout -b feature-2
# ... work on feature-2 ...

# Switch between them
git checkout feature-1
git checkout feature-2

# Or stash changes temporarily
git stash
git checkout feature-2
git stash pop  # Back to feature-1
```

---

### "How do I keep my fork updated?"

```bash
# Add upstream remote (if working on a fork)
git remote add upstream https://github.com/earnerbaymalay/palexusOS.git

# Fetch latest from upstream
git fetch upstream

# Merge into your branch
git merge upstream/main

# Or rebase (cleaner history)
git rebase upstream/main
```

---

## Still Stuck?

1. **Check documentation** - Read QUICKSTART.md, ARCHITECTURE.md, CONTEXT.md
2. **Search examples** - Look at examples/01-04 for patterns
3. **Read existing tests** - See how tests/test_*.py work
4. **Review ADRs** - docs/adr/ explains design decisions
5. **Ask in issues** - Create a question issue with:
   - What you tried
   - What error you got
   - Expected behavior
   - Your environment (Python version, OS)

---

**Last Updated**: 2026-11-20  
**Status**: ✅ Complete troubleshooting guide
