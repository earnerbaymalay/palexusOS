# Documentation Index

Navigate PalexusOS documentation by role and goal.

---

## 👥 By Role

### End Users (Just Want to Use PalexusOS)

**Goal**: Install and run PalexusOS

**Reading Path**:
1. ✅ [README.md](../README.md) - Project overview (5 min)
2. ✅ [INSTALL.md](../INSTALL.md) - Installation steps (5 min)
3. ✅ [QUICKSTART.md](../QUICKSTART.md) - First run (5 min)

**Need help?** → [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

### New Contributors (Want to Contribute Code)

**Goal**: Understand architecture and start contributing

**Reading Path**:
1. ✅ [README.md](../README.md) - Project overview (5 min)
2. ✅ [CONTRIBUTING.md](../CONTRIBUTING.md) - How to contribute (10 min)
3. ✅ [QUICKSTART.md](../QUICKSTART.md) - Dev setup (5 min)
4. ✅ [CONTEXT.md](../CONTEXT.md) - Domain terminology (10 min)
5. ✅ [ARCHITECTURE.md](design/ARCHITECTURE.md) - Module design (15 min)
6. ✅ [examples/01-04](../examples/README.md) - See it working (20 min)
7. ✅ [GETTING_STARTED_TUTORIAL.md](GETTING_STARTED_TUTORIAL.md) - Real workflow (30 min)

**Next Steps**:
- Pick a "good first issue" (tagged in GitHub)
- Create a feature branch
- Run tests: `make test`
- Submit PR with tests

**Need help?** → [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

### Advanced Contributors (Want to Extend Modules)

**Goal**: Modify module internals, add features

**Reading Path**:
1. ✅ [ARCHITECTURE.md](design/ARCHITECTURE.md) - Module ownership
2. ✅ [CONTEXT.md](../CONTEXT.md) - Domain model
3. ✅ [docs/adr/](adr/) - Design decisions (all 4 ADRs)
4. ✅ [DEVELOPER_HANDBOOK.md](DEVELOPER_HANDBOOK.md) - Extension patterns (45 min)
5. ✅ [API_REFERENCE.md](API_REFERENCE.md) - Method signatures (20 min)
6. ✅ [examples/01-04](../examples/README.md) - See current API in use

**Extension Workflow**:
1. Write failing test (define new interface)
2. Implement core (business logic)
3. Add integration test (verify isolation)
4. Document in ADR (design rationale)
5. Submit PR with all above

**Code Examples**: See [DEVELOPER_HANDBOOK.md](DEVELOPER_HANDBOOK.md) for:
- Adding token types
- Creating custom gates
- Custom boot phases
- Custom test levels

**Need help?** → [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

### Maintainers (Managing Releases & Project)

**Goal**: Release, review PRs, manage roadmap

**Reading Path**:
1. ✅ [CONTRIBUTING.md](../CONTRIBUTING.md) - Contributor flow (review section)
2. ✅ [RELEASE.md](../RELEASE.md) - Release process (20 min)
3. ✅ [docs/adr/](adr/) - Architecture decisions
4. ✅ [CHANGELOG.md](../CHANGELOG.md) - Version history
5. ✅ [PRE_LAUNCH_CHECKLIST.md](../PRE_LAUNCH_CHECKLIST.md) - Release readiness

**Maintenance Tasks**:
- Review PRs (see CONTRIBUTING.md review section)
- Merge to main
- Create git tag: `git tag -a v0.X.0 -m "Release vX.X.0"`
- Update CHANGELOG.md
- Publish to PyPI (see RELEASE.md)

**Need help?** → [RELEASE.md](../RELEASE.md) or [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

## 🎯 By Goal

### "I want to get started quickly"

→ [INSTALL.md](../INSTALL.md) + [QUICKSTART.md](../QUICKSTART.md) (10 min)

---

### "I want to understand the architecture"

→ [ARCHITECTURE.md](design/ARCHITECTURE.md) (15 min)

---

### "I want to see code examples"

→ [examples/01-04](../examples/README.md) (30 min)

---

### "I want to contribute a feature"

→ [CONTRIBUTING.md](../CONTRIBUTING.md) (10 min)
→ [GETTING_STARTED_TUTORIAL.md](GETTING_STARTED_TUTORIAL.md) (30 min)

---

### "I want to extend a module"

→ [DEVELOPER_HANDBOOK.md](DEVELOPER_HANDBOOK.md) (45 min)
→ [API_REFERENCE.md](API_REFERENCE.md) (20 min)

---

### "I'm stuck and need help"

→ [TROUBLESHOOTING.md](TROUBLESHOOTING.md) (search for your issue)

---

### "I want to understand design decisions"

→ [docs/adr/](adr/) - All 4 architecture decision records

---

### "I want to release a new version"

→ [RELEASE.md](../RELEASE.md) (20 min)

---

## 📚 Documentation Map

### Quick Reference (5-15 min)

| Document | Purpose | Audience |
|----------|---------|----------|
| [README.md](../README.md) | Project overview & features | Everyone |
| [INSTALL.md](../INSTALL.md) | Installation methods | Users & developers |
| [QUICKSTART.md](../QUICKSTART.md) | Developer setup & common tasks | Developers |
| [CONTEXT.md](../CONTEXT.md) | Domain vocabulary | Developers |
| [CONTRIBUTING.md](../CONTRIBUTING.md) | How to contribute | Contributors |

### In-Depth Guides (20-45 min)

- [ARCHITECTURE.md](design/ARCHITECTURE.md)
  - Purpose: Module design & ownership
  - Audience: Developers, contributors
- [GETTING_STARTED_TUTORIAL.md](GETTING_STARTED_TUTORIAL.md)
  - Purpose: Real-world workflow
  - Audience: New contributors
- [DEVELOPER_HANDBOOK.md](DEVELOPER_HANDBOOK.md)
  - Purpose: How to extend modules
  - Audience: Advanced contributors
- [API_REFERENCE.md](API_REFERENCE.md)
  - Purpose: Method signatures & examples
  - Audience: Extension developers
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
  - Purpose: Solutions for common issues
  - Audience: Anyone stuck
- [INTEGRATION_GUIDE.md](INTEGRATION_GUIDE.md)
  - Purpose: Using the modules from another project or CI
  - Audience: Integrators
- [MIGRATION.md](MIGRATION.md)
  - Purpose: What changes between versions
  - Audience: Users upgrading
- [PERFORMANCE_BASELINES.md](PERFORMANCE_BASELINES.md)
  - Purpose: Measured timings and budgets
  - Audience: Maintainers
- [V0.2.0_IMPLEMENTATION.md](V0.2.0_IMPLEMENTATION.md)
  - Purpose: Plan for the next release
  - Audience: Contributors

### Decision & Process (10-30 min)

- [docs/adr/](adr/)
  - Purpose: Architecture decisions (4 ADRs)
  - Audience: Developers
- [RELEASE.md](../RELEASE.md)
  - Purpose: Release process & versioning
  - Audience: Maintainers
- [CHANGELOG.md](../CHANGELOG.md)
  - Purpose: Version history
  - Audience: Everyone
- [PRE_LAUNCH_CHECKLIST.md](../PRE_LAUNCH_CHECKLIST.md)
  - Purpose: Release verification
  - Audience: Maintainers

### Code Examples (20-50 min)

- [examples/01_token_registry_example.py](../examples/01_token_registry_example.py)
  - Purpose: Using TokenRegistry
  - Level: Beginner
- [examples/02_gate_registry_example.py](../examples/02_gate_registry_example.py)
  - Purpose: Using GateRegistry
  - Level: Beginner
- [examples/03_desktop_environment_example.py](../examples/03_desktop_environment_example.py)
  - Purpose: Using DesktopEnvironment
  - Level: Beginner
- [examples/04_test_orchestrator_example.py](../examples/04_test_orchestrator_example.py)
  - Purpose: Using TestOrchestrator
  - Level: Beginner
- [examples/README.md](../examples/README.md)
  - Purpose: Running examples
  - Level: Beginner

---

## 🚀 Learning Paths

### Path 1: User (5-10 min)

```
README.md
    ↓
INSTALL.md
    ↓
Run PalexusOS
```

---

### Path 2: Contributor (1-2 hours)

```
README.md
    ↓
CONTRIBUTING.md
    ↓
QUICKSTART.md
    ↓
CONTEXT.md + ARCHITECTURE.md
    ↓
examples/01-04
    ↓
GETTING_STARTED_TUTORIAL.md
    ↓
Make your first contribution
```

---

### Path 3: Advanced Developer (3-4 hours)

```
Path 2 (above)
    ↓
docs/adr/0001-0004.md
    ↓
DEVELOPER_HANDBOOK.md
    ↓
API_REFERENCE.md
    ↓
Extend a module
```

---

### Path 4: Maintainer (1-2 hours)

```
CONTRIBUTING.md (review section)
    ↓
RELEASE.md
    ↓
docs/adr/ (understand all decisions)
    ↓
PRE_LAUNCH_CHECKLIST.md
    ↓
Manage releases
```

---

## 📋 Documentation Standards

All documentation follows these principles:

✅ **Explicit**: Clear purpose and audience  
✅ **Clear**: Simple language, no jargon  
✅ **Actionable**: Steps or examples  
✅ **Complete**: No broken references  
✅ **Current**: Updated with each release  

---

## 🔄 Document Relationships

```
README.md (entry point)
    ↓
├─→ INSTALL.md (users)
├─→ CONTRIBUTING.md (contributors)
├─→ QUICKSTART.md (developers)
│
├─→ CONTEXT.md (domain model)
│   └─→ ARCHITECTURE.md (design)
│       └─→ docs/adr/ (decisions)
│
├─→ examples/01-04 (code)
│   └─→ GETTING_STARTED_TUTORIAL.md (workflow)
│
├─→ DEVELOPER_HANDBOOK.md (extensions)
│   └─→ API_REFERENCE.md (methods)
│
├─→ TROUBLESHOOTING.md (help)
│
├─→ RELEASE.md (process)
│   └─→ CHANGELOG.md (history)
│
└─→ PRE_LAUNCH_CHECKLIST.md (verification)
```

---

## 🆘 Documentation Issues

**Found unclear documentation?**
1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md) first
2. Search GitHub issues for similar problems
3. Create an issue with:
   - What you were trying to do
   - What was unclear
   - What would help

**Want to improve documentation?**
1. Fork the repository
2. Edit the .md file
3. Submit a PR
4. See [CONTRIBUTING.md](../CONTRIBUTING.md)

---

## 📊 Documentation Statistics

- **README.md**
  - Lines: 300+
  - Topics: 10+
  - Examples: 5+
- **QUICKSTART.md**
  - Lines: 210+
  - Topics: 8+
  - Examples: 20+
- **CONTRIBUTING.md**
  - Lines: 500+
  - Topics: 12+
  - Examples: 30+
- **ARCHITECTURE.md**
  - Lines: 280+
  - Topics: 8+
  - Examples: 10+
- **CONTEXT.md**
  - Lines: 200+
  - Topics: 15+
  - Examples: Various
- **GETTING_STARTED_TUTORIAL.md**
  - Lines: 485+
  - Topics: 6+
  - Examples: 15+
- **DEVELOPER_HANDBOOK.md**
  - Lines: 1,100+
  - Topics: 20+
  - Examples: 50+
- **API_REFERENCE.md**
  - Lines: 900+
  - Topics: 50+
  - Examples: 100+
- **TROUBLESHOOTING.md**
  - Lines: 672+
  - Topics: 30+
  - Examples: 50+
- **Total**
  - Lines: **~4,700**
  - Topics: **~140**
  - Examples: **~300+**

---

## ✅ Verification

This index is complete when:
- [ ] Every document is listed
- [ ] Every link works (check in raw markdown)
- [ ] Every role has a reading path
- [ ] Every goal has a recommendation
- [ ] No duplicated information

**Last verified**: 2026-11-20

---

## 🎓 For Organizations

Using PalexusOS in your organization?

1. **Onboarding**: Send new team members to [QUICKSTART.md](../QUICKSTART.md)
2. **Learning**: Use [GETTING_STARTED_TUTORIAL.md](GETTING_STARTED_TUTORIAL.md)
3. **Extending**: Link [DEVELOPER_HANDBOOK.md](DEVELOPER_HANDBOOK.md)
4. **Contributing**: Share [CONTRIBUTING.md](../CONTRIBUTING.md)
5. **Help**: Point to [TROUBLESHOOTING.md](TROUBLESHOOTING.md)

---

**Last Updated**: 2026-11-20  
**Status**: ✅ Complete documentation index
