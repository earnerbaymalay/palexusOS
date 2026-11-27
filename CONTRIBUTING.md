# Contributing to PalexusOS

Thank you for your interest in contributing to PalexusOS! This guide will help you understand our workflow, architecture philosophy, and submission process.

## Philosophy: Ralph Wiggum Methodology

PalexusOS uses the Ralph Wiggum methodology for intentional, testable architecture:

1. **Explicit Intent**: Be clear about what you're doing and why
2. **Clear Boundaries**: Define module ownership and contracts
3. **Intentional Design**: Document decisions in ADRs
4. **Locality**: Changes stay localized to their modules
5. **Testability**: Each module independently verifiable

Read `CONTEXT.md` for the domain model and `ARCHITECTURE.md` for module ownership.

## Development Workflow

### 1. Set Up Your Environment

```bash
# Clone the repository
git clone https://github.com/earnerbaymalay/palexusOS.git
cd palexusOS

# Install development dependencies
pip install -e ".[dev]"

# Run tests to verify setup
make test
```

### 2. Understand the Architecture

Before writing code:

- Read `CONTEXT.md` to understand the domain vocabulary (TokenRegistry, GateRegistry, DesktopEnvironment, TestOrchestrator)
- Read `ARCHITECTURE.md` to find module ownership
- Review relevant ADRs in `docs/adr/` for design decisions
- Check `QUICKSTART.md` for common development tasks

### 3. Create a Feature Branch

```bash
git checkout -b feat/your-feature-name
```

Branch naming convention: `feat/`, `fix/`, `docs/`, `refactor/`, `test/`

### 4. Make Your Changes

**Golden Rules:**
- One logical change per commit
- Write tests BEFORE implementation (test-driven development)
- Keep changes localized to their module
- Follow the existing code style (enforced by `black` and `ruff`)
- Add ADR if making a design decision

**Common tasks:**

```bash
# Add a design token
make docs
# Then follow QUICKSTART.md "Add a token" section

# Add a quality gate
# See QUICKSTART.md "Add a gate" section

# Run tests
make test-quick         # Quick mode
make test              # Full suite
make test-verbose      # With details

# Format code
make format

# Lint code
make lint
```

### 5. Test Your Changes

All 160+ tests must pass locally before pushing:

```bash
# Run full test suite
make test

# Run specific test module
make test-design       # TokenRegistry tests
make test-build        # GateRegistry tests
make test-desktop      # DesktopEnvironment tests

# Run with coverage (if needed)
python -m pytest tests/ --cov=palexus
```

GitHub Actions will verify:
- All tests pass on Python 3.11–3.14
- `ruff` linting passes
- `black` formatting is correct
- Test count ≥ 160

### 6. Commit with Clear Messages

Commits should be atomic and clear:

```bash
git add palexus/design/token_registry.py tests/test_design.py
git commit -m "Add ColorPrimitive token type

Add a new ColorPrimitive class to support advanced color semantics.
Includes unit tests and documentation.

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>"
```

**Commit message format:**
- First line: imperative, under 50 chars, capitalize
- Blank line
- Body: explain what and why (not how — the code shows that)
- If fixing an issue: `Fixes #123` on a new line

### 7. Push and Create a Pull Request

```bash
git push -u origin feat/your-feature-name
```

**PR Description Template** (see `.github/pull_request_template.md`):

```markdown
## Summary

Brief description of what this PR does.

## Changes

- Change 1
- Change 2

## Verification

- [x] All 160+ tests pass
- [x] No new linting errors
- [x] Documentation updated (if applicable)
- [x] ADR written (if design decision)

## Related Issues

Fixes #123
```

### 8. Respond to Review

- Address feedback directly (don't just agree)
- Push new commits; don't force-push to an open PR
- Ask clarifying questions if feedback is unclear
- Request re-review once changes are made

## Code Style

PalexusOS uses:

- **Python**: 3.11+ (use `X | None` and `dict[str, ...]`, not `Optional`/`Dict`)
- **Formatter**: `black` 26.10.1, line length 100
- **Linter**: `ruff` 0.17.6 with `--extend-ignore=E501`
- **Type hints**: on all public functions

The versions match CI. `pre-commit install` runs both on every commit.

```python
# Good: clear naming, type hints where useful
class TokenRegistry:
    def color(self, category: str, name: str) -> str:
        """Get specific color value. Raises KeyError if not found."""
        return self.colors(category)[name]
```

Run `make format` and `make lint`, or `pre-commit run --all-files`, before committing.

## Testing

All changes require tests. Use test-driven development:

1. Write a failing test first
2. Implement code to make it pass
3. Refactor if needed

**Test organization:**

```
tests/
├── test_design.py
├── test_build.py
├── test_desktop.py
├── test_orchestrator.py
├── test_cli.py
└── test_examples.py
```

- `test_design.py` — TokenRegistry tests
- `test_build.py` — GateRegistry tests
- `test_desktop.py` — DesktopEnvironment tests
- `test_orchestrator.py` — TestOrchestrator tests
- `test_cli.py` — palexus command-line tools
- `test_examples.py` — every script in examples/ must run

**Example test:**

```python
def test_color_lookup(tmp_path):
    """TokenRegistry returns one colour by category and name."""
    tokens = tmp_path / "tokens.json"
    tokens.write_text(json.dumps({
        "colors": {"primary": {"mauve": "#cba6f7"}},
        "typography": {}, "spacing": {}, "radius": {},
    }))
    registry = TokenRegistry(tokens)
    assert registry.color("primary", "mauve") == "#cba6f7"
```

## Documentation

### ADR (Architecture Decision Record)

If your change involves a design decision, write an ADR:

```bash
# Create docs/adr/0005-your-decision.md
```

**ADR template:**

```markdown
# ADR-0005: Your Decision Title

## Status

Accepted

## Context

Why we're making this decision.

## Decision

What we decided to do.

## Consequences

What changes as a result.

## Alternatives Considered

Other options and why we didn't choose them.
```

### Documentation Updates

- Update `README.md` if adding new CLI commands
- Update `QUICKSTART.md` if adding common developer tasks
- Update `ARCHITECTURE.md` if changing module ownership
- Update `CONTEXT.md` if introducing new domain concepts

## Reporting Issues

**Before opening an issue:**
- Check existing issues (use search)
- Verify the issue on latest `main`
- Collect reproduction steps

**Issue template** (see `.github/issue_template.md`):

```markdown
## Describe the bug

Clear description of what's broken.

## Reproduction steps

1. Run command X
2. Observe behavior Y
3. Expected behavior Z

## Environment

- Python version: 3.11
- OS: Linux/macOS/Windows
- Branch: main
```

## Review Guidelines

PalexusOS uses **five-axis code review**:

1. **Correctness**: Does it work? Are there edge cases?
2. **Readability**: Can another developer understand this?
3. **Architecture**: Does it follow Ralph Wiggum principles? Is it localized?
4. **Security**: Any vulnerabilities? Input validation?
5. **Performance**: Any N+1s? Unnecessary work?

Expect feedback on all five axes. It's not personal — it makes code better.

## Release Process

Releases happen on `main` with git tags:

```bash
# Maintainers only
git tag -a v0.2.0 -m "Release version 0.2.0"
git push origin v0.2.0
```

**Version scheme**: Semantic Versioning (MAJOR.MINOR.PATCH)

- MAJOR: Breaking API changes
- MINOR: New features (backward compatible)
- PATCH: Bug fixes

Maintainers will:
1. Bump version in `pyproject.toml`
2. Update `CHANGELOG.md`
3. Create git tag
4. Publish to PyPI

## Questions?

- Check `QUICKSTART.md` for common tasks
- Read `ARCHITECTURE.md` for module questions
- Open an issue with the `question` label

## Code of Conduct

- Be respectful and inclusive
- Assume good intent
- Provide constructive feedback
- Help others learn

Thank you for contributing to PalexusOS! 🚀
