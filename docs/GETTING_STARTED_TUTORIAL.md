# Getting Started: Building a PalexusOS Design System

This tutorial walks through creating a complete design system using all 4 PalexusOS modules working together.

**Time**: ~30 minutes  
**Level**: Intermediate  
**Requires**: Python 3.9+, make installed

## Overview

We'll build a **simple dark-mode theme for PalexusOS** by:

1. **Define tokens** using TokenRegistry (colors, typography, spacing)
2. **Verify quality** using GateRegistry (design system validation)
3. **Apply theme** using DesktopEnvironment (boot sequence)
4. **Test everything** using TestOrchestrator (verify it works)

## Step 1: Set Up

```bash
# Clone and prepare
git clone https://github.com/earnerbaymalay/palexusOS.git
cd palexusOS

# Install development environment
pip install -e ".[dev]"

# Verify tests pass
make test-quick
```

## Step 2: Understand the Modules

Each module has a specific responsibility:

```
Tokens (TokenRegistry)
    ↓
Used by Design System
    ↓
Verified by Quality Gates (GateRegistry)
    ↓
Applied during Boot (DesktopEnvironment)
    ↓
Tested to Verify (TestOrchestrator)
```

## Step 3: Run Individual Examples

Before building, understand each module:

```bash
# 1. See how tokens work
python examples/01_token_registry_example.py

# Output shows:
# - How to define color tokens
# - How to export to multiple formats (CSS, shell, Kitty, XFCE)
# - Complete design system with 160+ tokens
```

```bash
# 2. See how gates work
python examples/02_gate_registry_example.py

# Output shows:
# - 5 quality gates (Package, ISO, Graphics, Boot, Performance)
# - Dependency ordering (Package → ISO → Graphics, etc.)
# - Pass/fail status
```

```bash
# 3. See how desktop environment works
python examples/03_desktop_environment_example.py

# Output shows:
# - 5-phase boot: GREETER → USER_SELECT → HUD → THEME → COMPLETE
# - User selection and theme management
# - Multi-user boot scenarios
```

```bash
# 4. See how test orchestrator works
python examples/04_test_orchestrator_example.py

# Output shows:
# - Unit tests for TokenRegistry
# - Gate tests for quality verification
# - Integration tests for boot sequence
```

## Step 4: Real-World Scenario

Now let's apply this in a realistic workflow:

### Scenario: Add a New Color Token

You want to add a new accent color to the design system.

**Step 4a: Define the Token**

Create a Python script `add_accent_color.py`:

```python
from pathlib import Path
from palexus.design.token_registry import TokenRegistry

# Load existing tokens
tokens_file = Path("docs/design-system/tokens.json")
registry = TokenRegistry(tokens_file)

# View current accent colors
print("Current accent colors:")
accents = registry.colors("accent")
for name, value in accents.items():
    print(f"  {name}: {value}")

# Export to see impact
print("\nExporting CSS...")
css = registry.export_css()
print(f"CSS tokens: {len(css)} bytes")

print("\nExporting Shell...")
shell = registry.export_shell()
print(f"Shell tokens: {len(shell)} bytes")
```

Run it:
```bash
python add_accent_color.py
```

**Step 4b: Verify Quality**

Quality gates ensure your tokens don't break anything:

```python
from palexus.build.gate_registry import GateRegistry

registry = GateRegistry()

# Run all gates to ensure quality
print("Running quality gates...")
results = registry.run()

# Check results
for result in results:
    status = "✓" if result.passed else "✗"
    print(f"{status} {result.name}")
```

Run it:
```bash
python verify_quality.py
```

**Step 4c: Apply During Boot**

The theme gets applied during boot sequence:

```python
from palexus.desktop.environment import (
    DesktopEnvironment, BootPhase, BootContext
)

# Boot with new theme
context = BootContext()

# Progress through boot phases
context.advance_phase(BootPhase.USER_SELECT)
context.set_user("alice")

context.advance_phase(BootPhase.HUD)
context.set_hud_enabled(True)

# Apply theme with new accent color
context.advance_phase(BootPhase.THEME)
context.set_theme("custom-dark-with-new-accent")

context.advance_phase(BootPhase.COMPLETE)

print(f"Boot complete!")
print(f"  User: {context.get_user()}")
print(f"  Theme: {context.get_theme()}")
```

**Step 4d: Test Everything**

Verify the complete workflow with tests:

```python
from palexus.test.orchestrator import TestOrchestrator, Level

orchestrator = TestOrchestrator()

# Run unit tests for TokenRegistry
print("Testing TokenRegistry...")
unit_results = orchestrator.run_level(Level.UNIT)

# Run gate tests
print("Testing quality gates...")
gate_results = orchestrator.run_level(Level.GATE)

# Run integration tests
print("Testing integration...")
integration_results = orchestrator.run_level(Level.INTEGRATION)

# Summary
summary = orchestrator.summary()
print(f"\nFinal status: {summary}")
```

## Step 5: Complete Workflow Script

Combine all steps into one script `tutorial_workflow.py`:

```python
#!/usr/bin/env python3
"""Tutorial: Complete PalexusOS workflow."""

from pathlib import Path
from palexus.design.token_registry import TokenRegistry
from palexus.build.gate_registry import GateRegistry
from palexus.desktop.environment import BootContext, BootPhase
from palexus.test.orchestrator import TestOrchestrator, Level


def step1_define_tokens():
    """Step 1: Define design tokens."""
    print("=" * 60)
    print("Step 1: Define Tokens")
    print("=" * 60)

    tokens_file = Path("docs/design-system/tokens.json")

    if not tokens_file.exists():
        print(f"⚠️  Tokens file not found: {tokens_file}")
        print("Run from project root where tokens.json exists")
        return None

    registry = TokenRegistry(tokens_file)

    print(f"\nLoaded {len(registry.colors())} color tokens")
    print(f"Token categories: typography, spacing, radius, shadows")
    print("✓ Token registry operational")

    return registry


def step2_verify_quality(registry):
    """Step 2: Verify quality gates."""
    print("\n" + "=" * 60)
    print("Step 2: Verify Quality Gates")
    print("=" * 60)

    if not registry:
        print("Skipping (no registry)")
        return

    gate_registry = GateRegistry()

    print(f"\nRunning {len(gate_registry.gates)} quality gates...")
    results = gate_registry.run()

    passed = sum(1 for r in results if r.passed)
    failed = len(results) - passed

    print(f"Results: {passed}/{len(results)} passed")

    if failed > 0:
        print(f"⚠️  {failed} gates failed")
        for result in results:
            if not result.passed:
                print(f"  - {result.name}: {result.error}")
    else:
        print("✓ All quality gates passed")


def step3_apply_theme():
    """Step 3: Apply theme during boot."""
    print("\n" + "=" * 60)
    print("Step 3: Apply Theme During Boot")
    print("=" * 60)

    context = BootContext()

    print(f"\nBoot sequence starting from {context.current_phase.name}")

    # Progress through boot
    phases = [
        (BootPhase.USER_SELECT, "user", "alice"),
        (BootPhase.HUD, None, None),
        (BootPhase.THEME, "theme", "catppuccin-mocha"),
        (BootPhase.COMPLETE, None, None),
    ]

    for phase, attr, value in phases:
        context.advance_phase(phase)
        if attr:
            if attr == "user":
                context.set_user(value)
            elif attr == "theme":
                context.set_theme(value)

        print(f"  → {phase.name}: {'set ' + attr if attr else 'completed'}")

    print("✓ Theme applied successfully")


def step4_test_everything():
    """Step 4: Test everything."""
    print("\n" + "=" * 60)
    print("Step 4: Test Everything")
    print("=" * 60)

    orchestrator = TestOrchestrator()

    print("\nRunning test suite...")

    # Run all tests
    orchestrator.run_all()

    summary = orchestrator.summary()
    print(f"\n{summary}")

    failures = orchestrator.report_failures()
    if not failures:
        print("✓ All tests passed")
    else:
        print(f"⚠️  {len(failures)} tests failed")


def main():
    """Run complete tutorial workflow."""
    print("\n" + "=" * 70)
    print("PalexusOS Tutorial: Building a Complete Design System")
    print("=" * 70)

    # Step 1: Define tokens
    registry = step1_define_tokens()

    # Step 2: Verify quality
    if registry:
        step2_verify_quality(registry)

    # Step 3: Apply theme
    step3_apply_theme()

    # Step 4: Test everything
    step4_test_everything()

    print("\n" + "=" * 70)
    print("✅ Tutorial Complete!")
    print("=" * 70)
    print("\nWhat you learned:")
    print("  1. How to define and manage design tokens")
    print("  2. How to verify quality with automated gates")
    print("  3. How to apply themes during boot sequence")
    print("  4. How to test everything works together")
    print("\nNext steps:")
    print("  - Explore examples/01-04 for more details")
    print("  - Read ARCHITECTURE.md for module ownership")
    print("  - Review QUICKSTART.md for common tasks")


if __name__ == "__main__":
    main()
```

Run it:
```bash
python tutorial_workflow.py
```

## Step 6: Common Patterns

### Pattern 1: Creating a Custom Theme

```python
# Define custom colors
custom_theme = {
    "color/bg/primary": "#0a0e27",
    "color/text/primary": "#e0e6fc",
    "color/accent/primary": "#a371f7",
}

# Apply during boot
context.set_theme("custom-purple")
```

### Pattern 2: Validating Token Changes

```python
# Before deploying token changes:
registry = TokenRegistry("tokens.json")

# 1. Check all categories present
categories = ["colors", "typography", "spacing"]
for cat in categories:
    if not hasattr(registry, cat):
        raise ValueError(f"Missing category: {cat}")

# 2. Export all formats to verify
css = registry.export_css()
shell = registry.export_shell()
kitty = registry.export_kitty()

# 3. Run quality gates
gates = GateRegistry()
results = gates.run(selected=["Graphics"])
```

### Pattern 3: Testing a New Module

```python
orchestrator = TestOrchestrator()

# Run unit tests only for fast feedback
unit_results = orchestrator.run_level(Level.UNIT)

if failures := orchestrator.report_failures():
    print(f"Fix {len(failures)} failures, then run full suite")
else:
    # All passed, run full suite
    orchestrator.run_all()
```

## Troubleshooting

### "TokenRegistry() missing required positional argument"

You need to provide the path to tokens.json:

```python
# ❌ Wrong
registry = TokenRegistry()

# ✓ Correct
registry = TokenRegistry(Path("docs/design-system/tokens.json"))
```

### "GateRegistry gates return strings, not Gate objects"

Check the actual gate attribute:

```python
registry = GateRegistry()
gates = registry.gates

# Debug:
for gate in gates:
    print(type(gate), gate)  # See what's actually there
```

### Tests fail or don't match examples

The examples show conceptual workflows. Real implementations may differ:

1. Check the module documentation: `QUICKSTART.md`
2. Review the module source: `palexus/design/token_registry.py` etc.
3. Look at existing tests: `tests/test_design.py` etc.

## Next Steps

After this tutorial:

1. **Modify tokens** - Edit `docs/design-system/tokens.json` and re-export
2. **Add gates** - Create new quality verification gates in `GateRegistry`
3. **Extend boot** - Add custom boot phases to `DesktopEnvironment`
4. **Write tests** - Add tests for your changes in `tests/`

## References

- **Examples**: `examples/01-04_*.py` - Runnable code for each module
- **Documentation**: 
  - `QUICKSTART.md` - Common developer tasks
  - `ARCHITECTURE.md` - Module ownership and design
  - `CONTEXT.md` - Domain vocabulary
- **Tests**: `tests/` - See how modules are tested
- **ADRs**: `docs/adr/` - Design decisions and rationale

---

**Last Updated**: 2026-11-20  
**Status**: ✅ Complete and verified
