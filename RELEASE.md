# Release Guide

This guide covers how to release new versions of PalexusOS to production and community channels.

## Versioning Strategy

PalexusOS uses **Semantic Versioning** (SemVer):

```
MAJOR.MINOR.PATCH
  |      |      └─ Bug fixes, no API changes
  |      └─────── New features, backward compatible
  └───────────── Breaking changes
```

**Examples:**
- `0.1.0` → `0.1.1`: Bug fix release
- `0.1.0` → `0.2.0`: New features, backward compatible
- `0.1.0` → `1.0.0`: Breaking changes

## Pre-Release Checklist

Before releasing, verify all items are complete:

### Code Quality (Automated in CI)

- [ ] All 160+ tests pass on Python 3.9–3.12
- [ ] Ruff linting passes (`make lint`)
- [ ] Black formatting passes (`make format-check`)
- [ ] No new warnings in build
- [ ] Type checking passes (mypy)

**Run locally:**
```bash
make test
make lint
make format-check
```

### Security & Dependencies

- [ ] No critical or high CVEs in dependencies
- [ ] `pip-audit` or `pip install -U pip` shows no issues
- [ ] No hardcoded secrets (checked by pre-commit)
- [ ] All changes reviewed and approved

**Check:**
```bash
pip audit
grep -r "FIXME\|TODO\|XXX" palexus/ || echo "No critical TODOs"
```

### Documentation

- [ ] `CHANGELOG.md` updated with version and changes
- [ ] `README.md` reflects new features
- [ ] ADRs written for any design decisions
- [ ] `INSTALL.md` updated if setup changed
- [ ] `QUICKSTART.md` updated if workflow changed
- [ ] Version bumped in `pyproject.toml`

**Check:**
```bash
grep "0.X.X" pyproject.toml README.md CHANGELOG.md
```

### Integration

- [ ] GitHub Actions workflows pass
- [ ] Wheel and sdist build successfully
- [ ] Package structure verified
- [ ] Changelog has user-facing summary

## Release Process

### 1. Update Version

Edit `pyproject.toml`:

```toml
[project]
name = "palexus"
version = "0.2.0"  # Bump version here
```

### 2. Update Changelog

Create entry in `CHANGELOG.md`:

```markdown
# Changelog

## [0.2.0] - 2026-11-20

### Added
- New feature X (TokenRegistry)
- New feature Y (GateRegistry)

### Fixed
- Bug fix for issue #123
- Bug fix for issue #456

### Changed
- API change to Z (see ADR-0005)

### Deprecated
- Old command (use new command instead)

---

## [0.1.0] - 2026-11-01

Initial release...
```

### 3. Create Commit

```bash
git add pyproject.toml CHANGELOG.md README.md docs/

git commit -m "Release v0.2.0

- Add TokenRegistry enhancements
- Add GateRegistry features
- Fix critical bugs

Co-Authored-By: Claude Haiku 4.5 <noreply@anthropic.com>"
```

### 4. Create Git Tag

```bash
# Annotated tag with message
git tag -a v0.2.0 -m "Release version 0.2.0

## Summary
Major improvements to design system and test framework.

## Modules Changed
- TokenRegistry: New color primitives
- GateRegistry: Performance gates
- TestOrchestrator: Parallel execution

## Breaking Changes
None.

## Security Fixes
None."

# Push to remote
git push origin main
git push origin v0.2.0
```

### 5. Verify Release

GitHub Actions will automatically:
1. Run full test suite
2. Build wheel and sdist
3. Upload artifacts (kept 7 days)
4. Post build status

**Manual verification:**
```bash
git show v0.2.0
# Should show tag annotation

git log --oneline v0.1.0..v0.2.0
# Should show all changes
```

## Publishing to PyPI

Once ready to publish to PyPI (future):

```bash
# Build distributions
python -m build

# Install twine
pip install twine

# Upload to TestPyPI first (optional)
twine upload --repository testpypi dist/

# Upload to production PyPI
twine upload dist/
```

## Release Announcement

After publishing:

1. **GitHub**: Create Release notes from tag
   - Copy from CHANGELOG.md
   - Highlight breaking changes
   - Link to documentation

2. **Community**: Announce on appropriate channels
   - Email announcements (if applicable)
   - Forum/discussion posts
   - Social media (if applicable)

**Release notes template:**

```markdown
## 🚀 Version 0.2.0 Released

### What's New

- **TokenRegistry**: New color primitives for advanced semantics
- **GateRegistry**: Performance verification gates
- **TestOrchestrator**: Parallel test execution

### Improvements

- 15% faster gate verification
- Better error messages in CLI
- Improved documentation

### Bug Fixes

- Fixed edge case in token validation (#123)
- Fixed test timeout on slow systems (#456)

### Breaking Changes

None.

### Installation

```bash
pip install --upgrade palexus
```

### Documentation

- [QUICKSTART](QUICKSTART.md)
- [ARCHITECTURE](ARCHITECTURE.md)
- [What's new](CHANGELOG.md)
```

## Hotfix Releases

For critical bugs in production (e.g., v0.1.1):

```bash
# Create hotfix branch from tag
git checkout -b hotfix/0.1.1 v0.1.0

# Make fix
git commit -am "Fix critical bug in TokenRegistry"

# Tag and push
git tag -a v0.1.1 -m "Hotfix: critical TokenRegistry bug"
git push origin hotfix/0.1.1
git push origin v0.1.1

# Merge back to main
git checkout main
git merge hotfix/0.1.1
git push origin main
```

## Rollback Strategy

If a release has critical issues:

```bash
# Revert tag (if not yet widely released)
git tag -d v0.2.0
git push origin :v0.2.0

# Or create a new patch release with fix
git checkout v0.2.0
git checkout -b hotfix/0.2.1
# ... make fix ...
git tag -a v0.2.1 -m "Fix for v0.2.0"
git push origin v0.2.1
```

## Release Cadence

- **Regular releases**: Monthly or as features accumulate
- **Hotfixes**: Within 24 hours of critical bugs
- **Major versions**: When API stability is achieved

## Post-Release

After 1 week:

- [ ] Monitor for user feedback and bug reports
- [ ] Check installation metrics (if published)
- [ ] Verify no major issues reported
- [ ] Update roadmap based on feedback

## CI/CD Integration

GitHub Actions automatically:

```yaml
# On tag push to main
on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Verify tests pass
        run: make test
      - name: Build distributions
        run: python -m build
      - name: Create GitHub Release
        # Uses GitHub REST API
```

## Maintenance Branches

For security or critical bug patches:

```bash
# Create maintenance branch
git checkout -b maint/0.1.x v0.1.0

# Make patches on this branch
git commit -am "Security patch for v0.1"
git tag -a v0.1.2 -m "Security patch"
git push origin maint/0.1.x
git push origin v0.1.2

# Merge back to main
git checkout main
git merge v0.1.2
```

## Questions?

- Review `CHANGELOG.md` for past releases
- Check `CONTRIBUTING.md` for general workflow
- See ADRs for design decisions affecting releases

---

**Last Updated**: 2026-11-20
**Maintainer**: earnerbaymalay
