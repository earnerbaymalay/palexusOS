# PalexusOS Architecture Deepening: Context & Concepts

This document explains the 4 core architectural deepenings that unify scattered concerns into explicit, testable modules.

## 1. TokenRegistry: Design System Token Dispatch

**Problem**: Design tokens scattered across 7+ output formats (CSS, shell, Kitty, XFCE, etc.)

**Solution**: Single source of truth (`TokenRegistry`) with pluggable exporters

```python
registry = TokenRegistry(Path("docs/design-system/tokens.json"))
colors = registry.colors("primary")  # Type-safe access
css = CSSExporter(registry).export()  # Format-specific export
```

**Key Concepts**:
- **Registry**: Central token source (load, validate, query)
- **Exporters**: Adapters that convert tokens to environment formats
- **Locality**: Adding a token = edit 1 file (tokens.json)

**Files**:
- `palexus/design/token_registry.py` - Main module
- `tests/test_design.py` - 14 passing tests

## 2. GateRegistry: Verification Gates Monolith Extraction

**Problem**: 828-line shell script mixing 5 concerns (package, ISO, graphics, boot, perf)

**Solution**: 5 independent Gate classes + GateRegistry orchestration

```python
registry = GateRegistry()
results = registry.run(repo_root, selected=["package", "iso"])
# Results in dependency order, with selective execution
```

**Key Concepts**:
- **Gate**: Abstract quality check (name, dependencies, run(), test())
- **GateRegistry**: Topological sort + execution orchestration
- **Independence**: Each gate is independently testable
- **Locality**: Adding gate = write new Gate class

**Files**:
- `palexus/build/gate_registry.py` - 5 Gates + Registry
- `tests/test_build.py` - 15 passing tests

**Gate Hierarchy**:
```
PackageGate (no deps)
  ├─→ ISOGate
  └─→ GraphicsGate
        ├─→ BootGate
            └─→ PerfGate
```

## 3. DesktopEnvironment: Desktop Package Config Coupling

**Problem**: Greeter/HUD/Theme packages with implicit boot sequence contracts

**Solution**: Explicit boot phases + adapters that encapsulate component logic

```python
env = DesktopEnvironment()
context = env.boot()  # Greeter → HUD → Theme
# Boot context carries selected_user, theme, phase
```

**Key Concepts**:
- **BootPhase**: Explicit lifecycle (GREETER → USER_SELECT → HUD → THEME → COMPLETE)
- **Adapter**: Encapsulates component (Greeter, HUD, Theme) with initialize() contract
- **BootContext**: Shared state across phases (user selection, theme, flags)
- **Locality**: Changing greeter = edit one Adapter

**Files**:
- `palexus/desktop/environment.py` - 3 Adapters + Environment
- `tests/test_desktop.py` - 14 passing tests

## 4. TestOrchestrator: Testing Infrastructure Unification

**Problem**: Unit tests split from gate tests split from integration tests

**Solution**: Unified test framework with selective execution levels

```python
orchestrator = TestOrchestrator()
orchestrator.run_all()  # All tests
orchestrator.run_level(Level.GATE)  # Only gate tests
orchestrator.run_gate("package")  # Specific gate test
```

**Key Concepts**:
- **TestLevel**: Enum (UNIT, GATE, INTEGRATION, ALL)
- **Suite**: Collection of tests with metadata (test_count, passed, failed, pass_rate)
- **Result**: Individual test case record
- **Locality**: New quality check = register with orchestrator

**Files**:
- `palexus/test/orchestrator.py` - Main module
- `tests/test_orchestrator.py` - 12 passing tests

## Ralph Wiggum Methodology Applied

Each deepening follows **explicit, intentional design**:

✅ **Clear Problem Statements**
- Not just "this is scattered" but exact seams & boundaries
- TokenRegistry: 7+ outputs → 1 registry + N exporters
- GateRegistry: 828-line shell → 5 independent Gate classes

✅ **Defined Interfaces**
- Each module exports clear public API
- TokenRegistry.colors(), colors(category), color(cat, name)
- GateRegistry.run(), run(selected=...), test()
- DesktopEnvironment.boot(), hud_interface(), theme_loader()
- TestOrchestrator.run_all(), run_level(), run_gate()

✅ **Testable Boundaries**
- 66 passing tests verify each module in isolation
- Tests survive as module contracts evolve
- Each Gate, Adapter, Exporter independently testable

✅ **Locality of Change**
- Adding token: 1 file (tokens.json)
- Adding gate: 1 new Gate class
- Changing boot sequence: 1 BootPhase enum update + adapter
- New quality check: register new Suite with orchestrator

## Implementation Status

✅ **All 4 deepenings fully implemented**
- 66 passing tests
- Full module hierarchy: `palexus/design/`, `palexus/build/`, `palexus/desktop/`, `palexus/test/`
- Comprehensive tests in `tests/`

## Running Tests

```bash
# All 4 deepenings (66 tests)
pytest tests/test_design.py tests/test_build.py tests/test_desktop.py tests/test_orchestrator.py \
  -v

# Specific deepening
pytest tests/test_design.py -v  # TokenRegistry
pytest tests/test_build.py -v   # GateRegistry
pytest tests/test_desktop.py -v # DesktopEnvironment
pytest tests/test_orchestrator.py -v # TestOrchestrator
```

## Next Steps (Post-Implementation)

1. Integrate into build system (replace 828-line verify-gates.sh)
2. Update CI/CD to use new test orchestrator
3. Migrate theme generation to use TokenRegistry
4. Explicit desktop boot sequence in systemd or greeter startup
5. Document migration path for each consumer

---

**Philosophy**: Explicit > Implicit. Clear > Scattered. Tested > Assumed.
