# palexus Python Layer Roadmap (`palexus-lib`)

Plans for the `palexus/` Python modules (TokenRegistry, GateRegistry, DesktopEnvironment, TestOrchestrator), packaged as `palexus-lib`.

> Version numbers in this file are the Python package's own (`pyproject.toml`), not the distro's. Distro releases (`v0.2.0-alpha`, `v0.2.1-alpha`, ...) and the phase plan live in the root [ROADMAP.md](../ROADMAP.md).

---

## Table of Contents

1. [palexus-lib 0.1.0 (Current)](#palexus-lib-010-current)
2. [palexus-lib 0.2.0 (Next)](#palexus-lib-020-next)
3. [palexus-lib 0.3.0 (1-2 Quarters)](#palexus-lib-030-1-2-quarters)
4. [palexus-lib 1.0.0 (Stable Release)](#palexus-lib-100-stable-release)
5. [Longer Vision (Year+)](#longer-vision-year)
6. [Principles](#principles)
7. [How to Influence](#how-to-influence)

---

## palexus-lib 0.1.0 (Current)

**Landed on main**: 2026-11-20 (not tagged on its own; ships inside the distro as `palexus-lib`)  
**Status**: In development  

### What exists

**Core modules**
- TokenRegistry: design token management with 4 export formats (CSS, Shell, Kitty, XFCE)
- GateRegistry: quality verification with 5 gates and topological sorting
- DesktopEnvironment: boot orchestration with a 5-phase sequence
- TestOrchestrator: unified testing (unit, gate, integration levels)

**Documentation**
- Architecture: CONTEXT.md, ARCHITECTURE.md, 4 ADRs
- GETTING_STARTED_TUTORIAL.md, DEVELOPER_HANDBOOK.md, API_REFERENCE.md, TROUBLESHOOTING.md, SECURITY_HARDENING.md, INTEGRATION_GUIDE.md

**Examples**
- One runnable example per module under `examples/`

**Tooling**
- GitHub Actions: pytest on Python 3.11, 3.12, 3.13 and 3.14
- Makefile, pyproject.toml packaging, Arch PKGBUILD (`packages/core/palexus-lib`)
- PRE_LAUNCH_CHECKLIST.md, RELEASE.md

### Measuring it

Run these instead of trusting numbers written in docs:

```bash
pytest tests/ -q            # 2026-11-21: 192 passed, 8 skipped (whole repo suite)
./build/verify-gates.sh
```

Coverage, performance and doc-size figures are not measured yet.

### What's Stable

- Core module APIs (won't break without deprecation notice)
- Token format (tokens.json structure)
- Gate system architecture
- Bootstrap sequence
- Export formats

---

## palexus-lib 0.2.0 (Next)

**Target**: Q1 2027  
**Theme**: Expansion — more modules, more formats, community features  

### Planned Features

#### New Modules (2)

**ThemeManager** — Multi-theme support
- Load and merge multiple token sets (base, light/dark, accessibility, brand variants)
- Conflict resolution with priority-based merging
- Dynamic theme switching at runtime
- Per-theme variable exports
- Status: Design phase

**VariableRegistry** — Cross-module variable sharing
- Central registry for environment variables and secrets
- Secure credential management (not in Git)
- Build-time and runtime variable injection
- Integration with DesktopEnvironment
- Status: Spec phase

#### TokenRegistry Enhancements

**Token Inheritance** — Semantic tokens reference primitives
- Design primitive base layer
- Semantic layer with `{"ref": "primitive-name"}` references
- Automatic resolution in export formats
- Change propagation (update primitive → all dependents update)

**Token Localization** — Multi-language support
- Localized token values (copy, icons, right-to-left support)
- Language-specific exports
- Fallback chain (locale → language → default)

**Advanced Export Formats**
- Figma plugin sync (read/write tokens from Figma)
- JSON Schema validation (validate tokens.json structure)
- GraphQL schema export (for API consumers)

#### GateRegistry Enhancements

**Custom Gate Templates** — Easier gate creation
- Pre-built gate templates (performance, security, documentation)
- Composable gate builders
- Gate composites (run sub-gates, aggregate results)

**Gate Plugins** — Extend gate system
- Plugin API for third-party gates
- Community gate registry
- NPM/pip gate packages

#### DesktopEnvironment Enhancements

**Conditional Boot Phases** — Context-aware sequences
- Skip phases based on conditions (headless mode, CI environment)
- Dynamic phase insertion
- Parallel-safe context operations

**State Persistence** — Remember user preferences
- Save theme/user/settings across sessions
- Configuration profiles
- Rollback capability

#### Ecosystem Features

**CLI Tool** (`palexus-cli`) — Command-line interface
- `palexus-cli tokens export --format css --output styles.css`
- `palexus-cli gates run --gate Package`
- `palexus-cli boot init --theme catppuccin-mocha --user alice`
- `palexus-cli sync-figma --file-key ABC123`

**Web Dashboard** (Optional) — Visualize system state
- Real-time test results
- Gate verification status
- Token management UI
- Performance metrics

**Community Hub**
- Community gates registry
- Shared themes repository
- Integration examples showcase

### Breaking Changes (None Planned)

v0.2.0 will maintain backward compatibility with v0.1.0 APIs.

---

## palexus-lib 0.3.0 (1-2 Quarters)

**Target**: Q3 2027  
**Theme**: Performance & Scale  

### Planned Work

**Performance Optimization**
- Lazy-load large token sets (1000+ tokens)
- In-memory caching with invalidation
- Parallel gate verification
- Incremental test runs

**Scale Support**
- 10,000+ token sets without degradation
- Monorepo support (multiple TokenRegistry instances)
- Distributed gate verification
- Federated test orchestration

**Observability**
- Structured logging throughout
- Metrics export (Prometheus format)
- Distributed tracing support (OpenTelemetry)
- Performance profiling CLI

**Security Hardening**
- Secrets detection in tokens.json
- Signed releases and checksums
- Dependency vulnerability scanning in CI
- SBOM generation

### New Modules (1)

**PerformanceMonitor** — Track and prevent regressions
- Establish performance baselines
- Alert on regressions
- Historical trends and analysis
- Comparative benchmarking across versions

---

## palexus-lib 1.0.0 (Stable Release)

**Target**: Q1 2028  
**Theme**: Stability & Maturity  

### Success Criteria

✅ **API Stability**
- All public APIs documented and frozen
- Deprecation policy established
- Migration guides for any breaking changes

✅ **Community**
- 50+ contributors
- Active discussions and feature requests
- 3+ community-contributed modules

✅ **Production Readiness**
- Used in 5+ production systems
- Zero critical security issues
- 99%+ test pass rate

✅ **Performance**
- Handles 100k tokens without issues
- Sub-second token exports
- <30s full test suite even with 1000+ tests

✅ **Documentation**
- Zero ambiguous documentation
- Complete API reference with real-world examples
- Video tutorials for core workflows

✅ **Ecosystem**
- 10+ integrations (Figma, Storybook, Next.js, etc.)
- 5+ CLI tools and utilities
- Published on major package managers (PyPI, npm, Arch Linux)

---

## Longer Vision (Year+)

### Year 2 (2028-2029)

**PalexusOS Ecosystem**
- Official integrations with popular design tools (Figma, Adobe XD)
- Design system package manager (share themes, gates, examples)
- Bi-directional sync with design tools
- Design system analytics (token usage, adoption metrics)

**AI-Native Features**
- AI-powered gate suggestions
- LLM-based code generation from tokens
- Automated accessibility analysis
- Design system chatbot

**Distributed Systems**
- Multi-repository support
- Design system federation
- Cross-team collaboration features
- Change tracking and audit logs

### Speculative (2029+)

**Autonomous Design Systems**
- Self-healing design systems (detect and fix token mismatches)
- Predictive design recommendations
- Automatic a11y remediation

**Interop & Portability**
- Design system export to multiple formats
- Vendor-agnostic token specifications
- OpenAPI/GraphQL schema generation
- Cross-platform component generation

**Research**
- Design system best practices guide (from collected data)
- Design token standards proposal
- Papers on design system automation

---

## Principles

### Guiding Philosophy

1. **Modularity**: Each component should be usable standalone or composed together
2. **Explicitness**: Clear intent, no magic, debuggable behavior
3. **Testability**: Every feature must be testable
4. **Performance**: O(n) algorithms, caching where it matters
5. **Security**: Secure by default, no secrets in Git
6. **Community**: Contribute directly or through plugins

### Release Cadence

- **Patch releases** (v0.1.1, v0.1.2): Bug fixes, as needed
- **Minor releases** (v0.2.0, v0.3.0): New features, quarterly
- **Major releases** (v1.0.0): Stability/maturity, annual or milestone-driven

### Stability Guarantees

- **v0.x.y**: APIs may change between minor versions; deprecated with 1 minor version notice
- **v1.x.y**: Semantic versioning; breaking changes only on major version bump

---

## How to Influence

### Request a Feature

1. **Check existing issues** — search "is:issue" on GitHub
2. **Write a proposal** — use [CONTRIBUTION_LADDER.md](CONTRIBUTION_LADDER.md) template
3. **Post on GitHub** — open an issue with your proposal
4. **Discuss with maintainers** — feedback, feasibility, alignment with roadmap

### Propose a New Module

1. **Write a design doc** (1-2 pages)
2. **Explain the use case** (who needs this, why now)
3. **Show how it fits** (integrations with existing modules)
4. **Post on discussions** — start a discussion thread
5. **Refine with community** — iterate based on feedback

### Contribute Implementation

1. **Pick an issue** — see [CONTRIBUTION_LADDER.md](CONTRIBUTION_LADDER.md)
2. **Claim the work** — comment "I want to work on this"
3. **Implement** — follow CONTRIBUTING.md
4. **Submit PR** — include tests, docs, examples
5. **Respond to review** — address feedback
6. **Celebrate** — your code is in production!

### Sponsor or Partner

Interested in sponsoring development or partnering?
- 📧 Email: earnerbaymalay@gmail.com
- 🗣️ GitHub Discussions: https://github.com/earnerbaymalay/palexusOS/discussions
- 📌 Issues: Upvote issues that matter to you

---

## Tracking Progress

- **palexus-lib 0.1.0**
  - Status: On main, unreleased
  - Link: [CHANGELOG.md](../CHANGELOG.md)
- **palexus-lib 0.2.0**
  - Status: 📋 Planning
  - Link: [GitHub](https://github.com/earnerbaymalay/palexusOS/milestones)
- **Design Docs**
  - Status: 📝 In Progress
  - Link: [docs/adr/](adr/)
- **Community Discussion**
  - Status: 💬 Active
  - Link: [Discussions](https://github.com/earnerbaymalay/palexusOS/discussions)

---

## FAQ

### Q: When will feature X be ready?

**A**: Check the roadmap above. Features in "Planned" are under active development. Features in "Speculative" are ideas with no committed timeline. For exact status, check GitHub issues and milestones.

### Q: Can I request a feature not on this roadmap?

**A**: Absolutely! Open an issue or start a discussion. We're always open to good ideas and use cases.

### Q: Can I implement something from the roadmap myself?

**A**: Yes! Pick an issue from the GitHub milestone, claim it, and start implementing. See [CONTRIBUTION_LADDER.md](CONTRIBUTION_LADDER.md) for guidance.

### Q: How do you prioritize?

**A**: We consider:
1. Community demand (issue votes, discussion engagement)
2. Strategic importance (aligns with vision)
3. Contributor availability (who can implement)
4. Dependencies (what needs to be done first)

### Q: Will PalexusOS ever break backward compatibility?

**A**: Not in v1.x. We follow semantic versioning strictly. If a breaking change is ever needed, it's only for a v2.0.0 release, and we provide migration guides.

---

## Acknowledgments

This roadmap is shaped by:
- Community feedback and feature requests
- Maintainer vision for the project
- Real-world use cases and pain points
- Best practices from similar projects

We're grateful for every contributor, user, and person who gave feedback to get here.

---

**Last Updated**: 2026-11-20  
**Next Review**: 2027-02-20 (after v0.2.0 scope is finalized)  
**Status**: ✅ Complete roadmap
