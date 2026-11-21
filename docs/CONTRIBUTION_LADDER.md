# Contribution Ladder

Pick an issue matched to your experience level and get started contributing to PalexusOS.

**Audience**: New contributors, maintainers assigning issues  
**Purpose**: Make onboarding smooth by matching contributors to appropriate difficulty levels  

---

## Table of Contents

1. [How to Use This Guide](#how-to-use-this-guide)
2. [Finding Your Level](#finding-your-level)
3. [Good First Issue (Rung 1)](#good-first-issue-rung-1)
4. [Intermediate (Rung 2)](#intermediate-rung-2)
5. [Advanced (Rung 3)](#advanced-rung-3)
6. [Architecture (Rung 4)](#architecture-rung-4)
7. [How to Contribute](#how-to-contribute)
8. [Issue Submission Guide](#issue-submission-guide)
9. [Mentorship](#mentorship)

---

## How to Use This Guide

**If you're new**: Start at "Good First Issue" and work through progressively harder problems.

**If you're experienced**: Jump to "Advanced" or "Architecture" and tackle complex challenges.

**If you're maintaining**: Label issues with difficulty tiers and use this guide to help contributors self-select.

---

## Finding Your Level

### Quick Self-Assessment

```
Can you...

Level 1 (Good First Issue)?
✓ Read and understand existing Python code
✓ Run tests with `make test`
✓ Follow instructions in CONTRIBUTING.md
✓ Ask for help on GitHub

Level 2 (Intermediate)?
✓ All of Level 1, plus:
✓ Fix a bug by reading error messages
✓ Add a test for existing functionality
✓ Modify existing functions without breaking others

Level 3 (Advanced)?
✓ All of Level 2, plus:
✓ Design a new feature from a spec
✓ Write tests first, then implementation
✓ Understand module interactions (TokenRegistry → GateRegistry)

Level 4 (Architecture)?
✓ All of Level 3, plus:
✓ Propose changes to core design
✓ Mentor other contributors
✓ Make decisions with architectural impact
```

---

## Good First Issue (Rung 1)

**Time commitment**: 15-30 minutes  
**Difficulty**: Easy  
**Label**: `good-first-issue`  

### What counts as "Good First Issue"

✅ **Documentation**
- Fix typos in existing docs
- Add missing code example
- Clarify confusing section
- Update outdated link

✅ **Low-Risk Code**
- Add a type hint to a function
- Fix a simple test
- Extract a magic number to a constant
- Add a missing docstring

✅ **Configuration**
- Add a new linter rule
- Update a dependency version
- Improve the Makefile
- Add a GitHub Actions step

### Example Issues

#### "Add docstring to TokenRegistry.colors()"

```python
# Current (missing docstring):
def colors(self, category=None):
    """Missing docstring"""
    tokens = self._data.get("colors", {})
    return tokens.get(category, {}) if category else tokens

# Expected (with docstring):
def colors(self, category=None):
    """Get color tokens by category.
    
    Args:
        category: Optional color category (e.g., 'primary', 'secondary').
                 If None, returns all colors.
    
    Returns:
        Dict of color tokens or specific category.
    """
    tokens = self._data.get("colors", {})
    return tokens.get(category, {}) if category else tokens
```

**Steps to solve**:
1. Find the function: `palexus/design/token_registry.py`
2. Write a docstring (see existing docstrings for style)
3. Run `make test` to verify nothing broke
4. Submit PR

---

#### "Add example in README for TokenRegistry export"

**Current README**:
```markdown
# PalexusOS

## Quick Start

```python
from palexus.design.token_registry import TokenRegistry
registry = TokenRegistry()
```
```

**Expected addition**:
```markdown
# PalexusOS

## Quick Start

```python
from palexus.design.token_registry import CSSExporter, TokenRegistry
from pathlib import Path

# Load tokens
registry = TokenRegistry(Path("docs/design-system/tokens.json"))

# Export to CSS
css = CSSExporter(registry).export()
print(css)  # Prints CSS variables
```
```

**Steps to solve**:
1. Open `README.md`
2. Find the Quick Start section
3. Add the example (compare with `examples/01_token_registry_example.py` for style)
4. Test it works: `python -c "..."`
5. Submit PR

---

#### "Update Python version in GitHub Actions from 3.9 to 3.11"

**Location**: `.github/workflows/test.yml`

**Steps to solve**:
1. Open `.github/workflows/test.yml`
2. Find: `python-version: ['3.9', '3.10', '3.11', '3.12']`
3. Change to: `python-version: ['3.10', '3.11', '3.12']`
4. Run `make test` locally (doesn't test CI, but verifies setup)
5. Submit PR with rationale: "Drop 3.9 support; focus on actively maintained versions"

---

### How to Submit a Good First Issue

```markdown
## Title
Add docstring to TokenRegistry.colors()

## Description
The `TokenRegistry.colors()` method is missing a docstring, making it hard for new users to understand its parameters and return value.

## Expected behavior
Add a docstring following the project's style (see CONTRIBUTING.md style guide).

## Difficulty
Good First Issue

## Resources
- Existing docstrings: palexus/design/token_registry.py
- Style guide: See lines X-Y in CONTRIBUTING.md
```

---

## Intermediate (Rung 2)

**Time commitment**: 1-2 hours  
**Difficulty**: Medium  
**Label**: `help-wanted`  

### What counts as "Intermediate"

✅ **Small Features**
- Add a new export format to TokenRegistry
- Create a new test for existing functionality
- Fix a small bug with a clear reproduction step
- Add a new validation rule to GateRegistry

✅ **Code Improvements**
- Refactor a function (keeping API the same)
- Extract repeated code into a helper
- Improve error messages
- Add type hints to a module

✅ **Integration**
- Connect two existing modules
- Add an example using multiple modules
- Create a helper script

### Example Issues

#### "Add JSON export format to TokenRegistry"

**Spec**:
```python
# Should support, alongside CSSExporter, ShellExporter, KittyExporter, XFCEExporter:
JSONExporter(registry).export()  # Returns JSON string with all tokens
# and on the command line:  palexus design export json out.json

# Output format:
{
  "colors": {"primary": "#cba6f7", ...},
  "typography": {...},
  "spacing": {...}
}
```

**Steps to solve**:
1. Write a test first (see `test_design.py` for examples)
2. Add `JSONExporter` in `palexus/design/token_registry.py` and register it in `EXPORTERS` in `palexus/design/cli.py`
3. Run `make test` to verify
4. Update `API_REFERENCE.md` with new method
5. Submit PR

---

#### "Fix: TestOrchestrator.run_level() doesn't report timeout errors"

**Repro**:
```python
orchestrator = TestOrchestrator()
# When a test times out, run_level() returns None instead of a failure
results = orchestrator.run_level(Level.UNIT)  # Test times out → None returned
```

**Expected**:
```python
results = orchestrator.run_level(Level.UNIT)  # Returns [Result(passed=False, error="Timeout")]
```

**Steps to solve**:
1. Reproduce the issue locally
2. Find where timeout is handled: `palexus/test/orchestrator.py`
3. Write a test that reproduces the timeout
4. Fix the timeout handling to return proper Result
5. Run `make test`
6. Submit PR

---

#### "Create example: Custom gate for documentation coverage"

**Purpose**: Show how to extend GateRegistry with a custom gate

**Deliverable**:
```python
# examples/custom_gate_example.py

from pathlib import Path

from palexus.build.gate_registry import Gate, GateRegistry, GateResult, GateStatus


class DocumentationGate(Gate):
    """Verify all public functions are documented."""

    def __init__(self):
        super().__init__("docs", dependencies={"package"})

    def run(self, repo_root: Path) -> GateResult:
        undocumented = count_undocumented_functions(repo_root / "palexus")  # you write this
        if undocumented:
            return GateResult(self.name, GateStatus.FAILED, f"{undocumented} functions lack docs")
        return GateResult(self.name, GateStatus.PASSED, "All public functions documented")

    def test(self) -> bool:
        return self.name == "docs"


# Usage:
registry = GateRegistry()
registry.gates["docs"] = DocumentationGate()
results = registry.run(Path("."))
```

**Steps to solve**:
1. See `examples/02_gate_registry_example.py` for structure
2. Implement the custom gate example
3. Add explanation comments
4. Run it: `python examples/custom_gate_example.py`
5. Update `examples/README.md` to mention it
6. Submit PR

---

### How to Submit an Intermediate Issue

```markdown
## Title
Add JSON export format to TokenRegistry

## Description
Currently TokenRegistry supports CSS, Shell, Kitty, and XFCE export formats. 
Adding JSON export would enable JavaScript apps and other tools to consume tokens.

## Acceptance Criteria
- [ ] `JSONExporter(registry).export()` returns all tokens as JSON
- [ ] JSON structure matches existing format in tokens.json
- [ ] All tests pass: make test
- [ ] API_REFERENCE.md updated

## Difficulty
help-wanted

## Resources
- Current exports: palexus/design/token_registry.py lines X-Y
- JSON format: docs/design-system/tokens.json
- API_REFERENCE.md: docs/API_REFERENCE.md
```

---

## Advanced (Rung 3)

**Time commitment**: 2-4 hours  
**Difficulty**: Hard  
**Label**: `type:enhancement`  

### What counts as "Advanced"

✅ **New Features**
- Add a new module or component
- Design a new test level for TestOrchestrator
- Extend DesktopEnvironment with new boot phases
- Add variable scopes to TokenRegistry

✅ **Architecture Improvements**
- Refactor module interface (with tests proving compatibility)
- Add performance optimization
- Improve error handling across a module
- Design a new pattern for token inheritance

✅ **Deep Integration**
- Make all 4 modules work together in one workflow
- Add cross-module validation
- Create a comprehensive example

### Example Issues

#### "Add token inheritance: semantic tokens inherit from primitives"

**Current state**:
```json
{
  "primitives": {"blue/500": "#0066FF"},
  "semantic": {"color/bg/primary": "#0066FF"}  // Hardcoded, not linked
}
```

**Expected state**:
```json
{
  "primitives": {"blue/500": "#0066FF"},
  "semantic": {
    "color/bg/primary": {"ref": "blue/500"}  // References primitive
  }
}
```

**When blue/500 changes, semantic/color/bg/primary changes automatically.**

**Steps to solve**:
1. Design the reference system (write an ADR)
2. Update tokens.json schema
3. Modify TokenRegistry to resolve references
4. Write tests for reference resolution
5. Update export formats (CSS, Shell, etc.) to resolve references
6. Submit PR with ADR

---

#### "Design test levels for browser automation testing"

**Goal**: TestOrchestrator.run_level(Level.BROWSER) should run Playwright tests

**Spec**:
```python
class Level(Enum):
    UNIT = "unit"           # Existing
    GATE = "gate"           # Existing
    INTEGRATION = "integration"  # Existing
    BROWSER = "browser"     # NEW: Playwright/browser tests
    E2E = "e2e"             # NEW: Full end-to-end

orchestrator.run_level(Level.BROWSER)
# Runs all tests/test_browser_*.py
# Returns results with performance metrics
```

**Steps to solve**:
1. Write a design spec (or ADR)
2. Create test file: `tests/test_browser_*.py` with Playwright examples
3. Extend TestOrchestrator to recognize BROWSER level
4. Implement browser test discovery and execution
5. Add performance tracking for browser tests
6. Submit PR

---

#### "Create comprehensive workflow: Token → Design System → App CSS"

**Purpose**: Show full integration of TokenRegistry → CSS export → app integration

**Deliverable**:
```python
# examples/05_complete_workflow.py

# 1. Load tokens from design system
registry = TokenRegistry(Path("docs/design-system/tokens.json"))

# 2. Export to CSS
css = CSSExporter(registry).export()

# 3. Write to app
with open("docs/example-app/styles/tokens.css", "w") as f:
    f.write(css)

# 4. Verify app renders correctly
assert verify_css_valid(css)

# 5. Test that all tokens are used (optional)
app_code = Path("docs/example-app/src").read_text()
unused_tokens = find_unused_tokens(css, app_code)
print(f"Unused tokens: {unused_tokens}")
```

**Steps to solve**:
1. Design a small example app structure
2. Implement the workflow
3. Add documentation and comments
4. Create app example (simple HTML + CSS)
5. Run the workflow end-to-end
6. Submit PR

---

### How to Submit an Advanced Issue

```markdown
## Title
Add token inheritance: semantic tokens inherit from primitives

## Description
Currently, semantic tokens like `color/bg/primary` are hardcoded values that 
duplicate primitives like `blue/500`. When primitives change, semantic tokens must 
be manually updated.

By adding a reference system, semantic tokens can inherit from primitives, 
ensuring consistency and reducing duplication.

## Design
See ADR-XXXX for detailed design. Key points:
- Primitives layer is source of truth
- Semantic layer references primitives via `{"ref": "blue/500"}`
- Export formats resolve references at build time

## Acceptance Criteria
- [ ] Design ADR written (docs/adr/0005-token-references.md)
- [ ] tokens.json schema updated
- [ ] TokenRegistry resolves references
- [ ] All export formats (CSS, Shell, etc.) handle references
- [ ] Comprehensive tests pass
- [ ] All 160+ tests still pass
- [ ] No performance regression

## Difficulty
type:enhancement

## Resources
- Current token format: docs/design-system/tokens.json
- TokenRegistry implementation: palexus/design/token_registry.py
- Design system spec: docs/ARCHITECTURE.md → TokenRegistry section
```

---

## Architecture (Rung 4)

**Time commitment**: 4+ hours  
**Difficulty**: Very Hard  
**Label**: `type:architecture`  

### What counts as "Architecture"

✅ **Major Design Changes**
- Redesign a module interface
- Add a new module to PalexusOS
- Reshape how modules interact
- Propose new Ralph Wiggum patterns

✅ **Performance / Scalability**
- Optimize for 10,000+ tokens
- Add caching layer
- Parallelize verification
- Reduce test suite runtime

✅ **Ecosystem**
- Integrations with external tools
- CLI tool improvements
- Build system enhancements
- Deployment automation

### Example Issues

#### "Design and implement a new module: ThemeManager"

**Problem**: Users want to manage multiple themes (light/dark, brand variants, accessibility modes) without duplicating token definitions.

**Solution**: ThemeManager module that:
1. Loads multiple token sets (base, dark-mode, a11y-high-contrast)
2. Merges and resolves conflicts
3. Exports theme-specific variables

**Steps to solve**:
1. Write architectural spec (1-2 pages)
2. Design module interface and API
3. Create ADR for the design
4. Implement core functionality
5. Add comprehensive tests (40+ test cases)
6. Integrate with TokenRegistry
7. Write documentation and examples
8. Submit PR with ADR + implementation

---

#### "Add performance benchmark suite"

**Goal**: Track and prevent performance regressions

**Deliverable**:
```bash
make benchmark
# Runs:
# - Token loading: 100k tokens in <1s
# - Gate verification: All 5 gates in <5s
# - Test execution: Full suite in <30s
# - Memory usage: Baseline <500MB

# Output:
# ✓ Token loading: 0.8s (target 1s)
# ✗ Gate verification: 6.5s (target 5s) - REGRESSION
```

**Steps to solve**:
1. Design benchmark suite with realistic scenarios
2. Create baseline measurements for all 4 modules
3. Implement benchmark runner
4. Add GitHub Actions check to detect regressions
5. Document baseline and targets
6. Submit PR

---

#### "Implement automatic token sync: code ↔ design system"

**Goal**: Keep PalexusOS tokens in sync with Figma design system

**Deliverable**:
```bash
# CLI command:
palexus-cli sync-figma --file-key ABC123 --output tokens.json

# Fetches tokens from Figma, writes to tokens.json
# Optionally commits to git with changelog
```

**Steps to solve**:
1. Research Figma API (token variables endpoint)
2. Design sync strategy (pull-only vs. bi-directional)
3. Create Figma API client
4. Implement sync logic with conflict resolution
5. Add CLI command
6. Write comprehensive tests
7. Document setup and usage
8. Submit PR

---

### How to Submit an Architecture Issue

```markdown
## Title
Design and implement ThemeManager module

## Description
PalexusOS currently supports a single token set at a time. Users managing 
light/dark modes, brand variants, or accessibility themes must duplicate tokens 
or manage multiple TokenRegistry instances.

A ThemeManager module would enable:
- Multiple theme definitions sharing a base
- Dynamic theme switching at runtime
- Automatic variable overrides and resolution
- Export per-theme token sets

## Architecture
See proposed ADR below:

### Design (high-level)
1. ThemeManager loads and merges multiple token sets
2. Conflict resolution via priority (accessibility > brand-specific > base)
3. Export per-theme or combined token sets
4. Integrates with existing DesktopEnvironment for runtime switching

### Module Structure
palexus/design/theme_manager.py
- class ThemeManager: Manage multiple themes
- class Theme: Individual theme definition
- class ThemeResolver: Resolve token conflicts

### Integration
- Part of design subsystem (like TokenRegistry)
- Used by DesktopEnvironment for theme switching
- Shares token format with TokenRegistry

## Acceptance Criteria
- [ ] Detailed ADR written (architecture decision + tradeoffs)
- [ ] Module fully implemented with 40+ tests
- [ ] All existing tests still pass
- [ ] Integration example created
- [ ] Documentation updated (ARCHITECTURE.md, examples/)
- [ ] Zero performance regression

## Difficulty
type:architecture

## Mentorship
Happy to pair on this or discuss design before starting.
```

---

## How to Contribute

### Step-by-Step Workflow

```
1. PICK AN ISSUE
   ├─ Find on GitHub (filter by label)
   ├─ Read the full issue description
   └─ Ask for clarification if needed

2. UNDERSTAND THE WORK
   ├─ Read CONTEXT.md (domain vocabulary)
   ├─ Read relevant section of ARCHITECTURE.md
   ├─ Look at existing examples
   └─ Run existing tests to understand patterns

3. ENVIRONMENT SETUP
   ├─ Fork the repository
   ├─ Clone your fork
   ├─ Run: make install-dev && pre-commit install
   ├─ Run: make test (verify all pass)
   └─ Create feature branch: git checkout -b feature/your-issue-name

4. IMPLEMENT
   ├─ Write a failing test first (TDD)
   ├─ Implement the code
   ├─ Run: make test
   ├─ Run: make lint
   └─ Commit with clear message

5. VERIFY
   ├─ Run full test suite: make test
   ├─ Run every hook: pre-commit run --all-files
   ├─ Verify documentation is current
   └─ Review your own code once

6. SUBMIT
   ├─ Push: git push -u origin feature/...
   ├─ Create PR via GitHub
   ├─ Provide context (what, why, how)
   ├─ Link the issue: "Fixes #123"
   └─ Wait for review

7. RESPOND TO FEEDBACK
   ├─ Address all comments
   ├─ Explain if you disagree (respectfully)
   ├─ Commit updates (don't rewrite history)
   └─ Comment when ready for another review

8. MERGED!
   └─ Celebrate 🎉
```

### Commands You'll Use

```bash
# Setup (first time only)
make install-dev
pre-commit install

# While developing
make test              # Run all tests
make lint              # Check code style
pre-commit run --all-files   # ruff + black with CI's versions
make format            # Auto-format code

# Before submitting
make test              # Final test run
make lint              # Final lint check
git diff               # Review your changes
git log --oneline -10  # Review your commits
```

---

## Issue Submission Guide

### Writing a Great Issue

```markdown
## Title
[Type] Short description

Types: 
- [Good First Issue] - Rung 1
- [Help Wanted] - Rung 2
- [Enhancement] - Rung 3
- [Architecture] - Rung 4

## Description
Clear explanation of what you want, why it matters, and how it benefits users.

## Current Behavior
What happens now? (include code examples if applicable)

## Expected Behavior
What should happen instead?

## Steps to Reproduce (if bug)
1. Run: `...`
2. Observe: `...`
3. Expected: `...`

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] All tests pass: make test

## Resources / Context
- Related issue: #XYZ
- Relevant docs: docs/ARCHITECTURE.md → Section
- Figma: [link]

## Difficulty Level
[ ] Good First Issue (15-30 min)
[ ] Help Wanted (1-2 hours)
[ ] Enhancement (2-4 hours)
[ ] Architecture (4+ hours)
```

---

## Mentorship

### How to Get Help

**Before starting**:
- Read GETTING_STARTED_TUTORIAL.md for a real workflow
- Ask clarifying questions on the issue itself

**While implementing**:
- Stuck? Post a code snippet and explain what you've tried
- Not sure about design? Open a draft PR early for feedback
- Want a second opinion? Request a review

**After submitting**:
- Respond to all review comments
- Ask for clarification if feedback is unclear
- Explain your reasoning if you disagree

### Code Review Process

Expect feedback on:
1. **Correctness** — Does it work?
2. **Testing** — Are edge cases covered?
3. **Style** — Does it match project conventions?
4. **Documentation** — Would another dev understand it?
5. **Performance** — Any regressions?

Feedback is **collaborative**, not judgmental. The goal is making you a better contributor and improving PalexusOS together.

---

## Recognition

**Contributors are recognized in**:
- CHANGELOG.md (each release)
- README.md (contributor list, once you've had a PR merged)
- GitHub (you're listed as a co-author)

**We celebrate**:
- Your first merged PR 🎉
- 5+ merged PRs (mention in release notes)
- Major features or architectural improvements

---

**Last Updated**: 2026-11-20  
**Status**: ✅ Complete contribution ladder
