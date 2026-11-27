# PalexusOS Quick-Start Guide

**TL;DR**: PalexusOS is an AI-native rolling Linux distribution built on Arch with deep architectural modularity.

## For Developers

### Understanding the Codebase

1. **Read first**: [CONTEXT.md](CONTEXT.md) — Domain vocabulary
2. **Then explore**: [ARCHITECTURE.md](ARCHITECTURE.md) — Module structure
3. **Deep dive**: [docs/adr/](docs/adr/) — Specific decisions

### Common Tasks

#### Add a new design token
```bash
# 1. Edit tokens.json
vim docs/design-system/tokens.json

# 2. Update schema if needed
vim palexus/design/token_registry.py

# 3. Run tests
python -m pytest tests/test_design.py -v

# 4. Commit
git add docs/design-system/tokens.json
git commit \
  -m "feat: Add animation-timing token to design system"
```

#### Add a new quality gate
```bash
# 1. Create Gate class
vim palexus/build/gates.py
# Add: class MyGate(Gate): ...

# 2. Register in GateRegistry
vim palexus/build/gate_registry.py
# Add: MyGate() to self.gates

# 3. Write test
vim tests/test_build.py
# Add: test for MyGate

# 4. Run tests
python -m pytest tests/test_build.py -v

# 5. Run specific gate
python -m palexus.build run --gate mygate
```

#### Add a new test
```bash
# 1. Write test
vim tests/test_myconcern.py

# 2. Run test
python -m pytest tests/test_myconcern.py -v

# 3. Run all tests to verify no regressions
python -m pytest tests/ -q
```

### Key Directories

| Path | Purpose |
|------|---------|
| `palexus/` | Core Python modules (design, build, desktop, test) |
| `packages/` | Arch PKGBUILD definitions |
| `docs/design-system/` | Design tokens, theme files |
| `docs/adr/` | Architecture decisions |
| `overlay/` | System configuration |
| `tests/` | Python unit tests |
| `build/` | ISO generation, verification |
| `scripts/` | Build utilities |

### Running Tests

```bash
# All tests (160 passing)
python -m pytest tests/ -v

# Specific test file
python -m pytest tests/test_design.py -v

# Specific test class
python -m pytest tests/test_design.py::TokenRegistryTests \
  -v

# Specific test
python -m pytest tests/test_design.py::TokenRegistryTests::test_load_valid_tokens \
  -v

# Quiet mode
python -m pytest tests/ -q

# Show output
python -m pytest tests/ -s
```

## For Package Maintainers

### Available Packages

**Core system**:
- `packages/core/` — Kernel, firmware, boot system

**Desktop environment**:
- `packages/desktop/palexus-greeter` — Login screen
- `packages/desktop/palexus-hud` — LLM command interface
- `packages/desktop/palexus-theme` — Visual themes

**AI/ML**:
- `packages/ai/` — LLM integrations, local inference

**Tools**:
- `packages/tools/` — CLI utilities, profiling, security

### Build a Package

```bash
cd packages/core/palexus-kernel
makepkg -si  # Build in isolated chroot

# Or verify via gates
python -m palexus.build run --gate package
```

### Verify Quality

```bash
# Run all gates (package, ISO, graphics, boot, performance)
python -m palexus.build run --all

# Run specific gates
python -m palexus.build run --gates package,iso
```

## For System Administrators

### Boot Sequence

PalexusOS boots in 5 phases (see `palexus/desktop/environment.py`):

1. **Greeter** → User selection (`palexus-greeter`)
2. **User Select** → User confirms
3. **HUD** → LLM command interface starts (`llm-quickfire-panel`)
4. **Theme** → Design system applied (tokens → Kitty, shell, XFCE)
5. **Complete** → Ready for use

### Customizing Theme

Design system is centralized in `docs/design-system/tokens.json`:

```json
{
  "colors": {
    "primary": {
      "electric-mauve": "#cba6f7",  // Active states, focus
      "warm-gold": "#fab387"         // Warnings
    },
    "surface": {
      "900": "#11111b",  // Background
      "800": "#1e1e2e"   // Primary surface
    }
  }
}
```

Changes propagate to all outputs automatically:
- CSS custom properties
- Shell aliases
- Kitty terminal colors
- XFCE theme

## Resources

- **[CONTEXT.md](CONTEXT.md)** — Domain model, terminology
- **[ARCHITECTURE.md](ARCHITECTURE.md)** — Module structure, ownership
- **[docs/adr/](docs/adr/)** — Architecture decisions (0001–0004)
- **[INTEGRATION.md](docs/design-system/INTEGRATION.md)** — Design system integration guide

## Troubleshooting

### Tests failing?
1. Run with verbose output: `pytest tests/ -v`
2. Check CONTEXT.md for terminology
3. See specific ADR for component design

### Module import failing?
1. Ensure PYTHONPATH includes project root: `export PYTHONPATH=/home/user/palexusOS:$PYTHONPATH`
2. Check module __init__.py exports: `palexus/design/__init__.py`, etc.
3. Verify module files exist in `palexus/`

### Building package fails?
1. Check PKGBUILD syntax: `makepkg --version`
2. Verify dependencies listed in `depends=()` are installed
3. Run `makepkg -h` for options

## Next Steps

1. **Learn the modules**: Read CONTEXT.md, then pick a module to explore
2. **Run tests**: `python -m pytest tests/ -q` (160 passing tests)
3. **Make a change**: Edit a token, run tests, commit
4. **Understand a decision**: Read one ADR to see why a design was chosen

---

**Contributing**: All work follows [CONTEXT.md](CONTEXT.md) vocabulary and [ARCHITECTURE.md](ARCHITECTURE.md) principles. See ADRs for precedent before proposing architectural changes.

