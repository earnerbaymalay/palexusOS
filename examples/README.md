# PalexusOS Examples

Comprehensive examples demonstrating how to use each PalexusOS module.

## Structure

Each module has a dedicated example file:

- **01_token_registry_example.py** - Design token management
- **02_gate_registry_example.py** - Quality gate verification
- **03_desktop_environment_example.py** - Boot sequence orchestration
- **04_test_orchestrator_example.py** - Unified test execution

## Running Examples

### Individual Examples

Run any example directly:

```bash
python examples/01_token_registry_example.py
python examples/02_gate_registry_example.py
python examples/03_desktop_environment_example.py
python examples/04_test_orchestrator_example.py
```

### From Project Root

```bash
cd /home/user/palexusOS
python examples/01_token_registry_example.py
```

## Example Descriptions

### 01: TokenRegistry

Demonstrates design token management:

- Register color, typography, and spacing tokens
- Export to 4 formats: CSS, Shell, Kitty, XFCE
- Build complete design systems
- Manage token organization (primitives → semantics)

**Key Operations:**
```python
registry = TokenRegistry()
registry.register_token("color/primary", "#cba6f7")
css = registry.export_css()
shell = registry.export_shell()
```

### 02: GateRegistry

Demonstrates quality gate verification:

- List available gates (5 total: Package, ISO, Graphics, Boot, Performance)
- Run all or specific gates
- Understand gate dependencies and execution order
- Track gate status and results
- Filter gates by pattern

**Key Operations:**
```python
registry = GateRegistry()
results = registry.run()
results = registry.run(selected=["Package", "Graphics"])
```

### 03: DesktopEnvironment

Demonstrates boot sequence orchestration:

- Understand 5 phases: GREETER → USER_SELECT → HUD → THEME → COMPLETE
- Manage boot context state
- Handle user selection and theme management
- Initialize command HUD
- Support multi-user boot scenarios

**Key Operations:**
```python
context = BootContext()
context.advance_phase(BootPhase.USER_SELECT)
context.set_user("alice")
context.set_theme("catppuccin-mocha")
```

### 04: TestOrchestrator

Demonstrates unified test execution:

- Run tests at different levels (unit, gate, integration)
- Get summary statistics and failure reports
- Track test performance
- Coverage by module
- Continuous testing patterns

**Key Operations:**
```python
orchestrator = TestOrchestrator()
results = orchestrator.run_level(Level.UNIT)
results = orchestrator.run_all()
summary = orchestrator.summary()
```

## Learning Path

For new developers:

1. **Start with TokenRegistry** (01) - Understanding design systems
2. **Continue with GateRegistry** (02) - Understanding quality verification
3. **Then DesktopEnvironment** (03) - Understanding boot sequences
4. **Finally TestOrchestrator** (04) - Understanding test execution

## Integration Between Modules

The examples show how modules work together:

- **Tokens** drive design system (used by DesktopEnvironment for theming)
- **Gates** verify design quality and package integrity
- **DesktopEnvironment** applies tokens during boot sequence
- **TestOrchestrator** verifies all modules work correctly

## Ralph Wiggum Methodology

All examples follow Ralph Wiggum principles:

✓ **Explicit Intent** - Each example clearly states what it's doing  
✓ **Clear Boundaries** - Modules have distinct responsibilities  
✓ **Intentional Design** - Decisions documented in ADRs  
✓ **Locality** - Examples stay scoped to single modules  
✓ **Testability** - Each module independently demonstrable  

## Common Patterns

### Error Handling

Each example shows graceful error handling:

```python
try:
    # Operation
except Exception as e:
    # Handle or log
    pass
```

### Performance Tracking

Examples include performance timing:

```python
import time
start = time.time()
# Operation
duration = time.time() - start
```

### Status Reporting

Examples show how to track status:

```python
if result.passed:
    print("✓ PASS")
else:
    print(f"✗ FAIL: {result.error}")
```

## Extending Examples

To create a new example:

1. Follow the naming pattern: `NN_module_example.py`
2. Include docstring with module description
3. Create separate functions for each concept
4. Use `if __name__ == "__main__"` for entry point
5. Print clear section headers
6. Add to this README with brief description

## Troubleshooting

### "ModuleNotFoundError: No module named 'palexus'"

Install the package:
```bash
pip install -e .
```

### Examples crash or fail

Ensure all tests pass first:
```bash
make test
```

### Need more context?

Read the documentation:
- **QUICKSTART.md** - Developer onboarding
- **ARCHITECTURE.md** - Module ownership
- **CONTEXT.md** - Domain vocabulary
- **docs/adr/*** - Architecture decisions

## Support

For issues with examples:

1. Check QUICKSTART.md
2. Review the example docstrings
3. Run tests to verify setup
4. Open an issue with error output

---

**All examples are verified to run successfully.**  
**Last updated**: 2026-11-20
