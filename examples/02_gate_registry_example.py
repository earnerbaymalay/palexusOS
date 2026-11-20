#!/usr/bin/env python3
"""Example: Using GateRegistry for quality verification.

This example demonstrates how to use GateRegistry to run quality gates,
verify dependencies, and check gate status.
"""

from palexus.build.gate_registry import GateRegistry


def example_list_gates():
    """List all available quality gates."""
    registry = GateRegistry()

    print("=" * 60)
    print("Available Quality Gates")
    print("=" * 60)

    for gate in registry.gates:
        deps = f" (depends: {', '.join(gate.dependencies)})" if gate.dependencies else ""
        print(f"\n{gate.name}")
        print(f"  Description: {gate.description}")
        print(f"  Dependencies: {deps if deps else 'None'}")


def example_run_all_gates():
    """Run all quality gates."""
    registry = GateRegistry()

    print("\n" + "=" * 60)
    print("Running All Quality Gates")
    print("=" * 60)

    results = registry.run()

    print(f"\nResults: {len(results)} gates executed")
    print("-" * 60)

    passed = 0
    failed = 0

    for result in results:
        status = "✓ PASS" if result.passed else "✗ FAIL"
        print(f"{status:8} {result.name:20} {result.error or ''}")

        if result.passed:
            passed += 1
        else:
            failed += 1

    print("-" * 60)
    print(f"Summary: {passed} passed, {failed} failed")

    return results


def example_run_specific_gates():
    """Run specific quality gates."""
    registry = GateRegistry()

    print("\n" + "=" * 60)
    print("Running Specific Gates")
    print("=" * 60)

    # Run only package gate
    print("\n1. Package Gate Only:")
    results = registry.run(selected=["Package"])

    for result in results:
        print(f"  {result.name}: {'✓ PASS' if result.passed else '✗ FAIL'}")

    # Run multiple gates
    print("\n2. Package + Graphics Gates:")
    results = registry.run(selected=["Package", "Graphics"])

    for result in results:
        print(f"  {result.name}: {'✓ PASS' if result.passed else '✗ FAIL'}")


def example_gate_dependencies():
    """Show gate dependency chain."""
    registry = GateRegistry()

    print("\n" + "=" * 60)
    print("Gate Dependencies")
    print("=" * 60)

    # Build dependency map
    dep_map = {}
    for gate in registry.gates:
        dep_map[gate.name] = gate.dependencies

    # Show dependency chain
    print("\nDependency Graph:")
    for gate_name, deps in dep_map.items():
        if deps:
            print(f"  {gate_name}")
            for dep in deps:
                print(f"    ← {dep}")
        else:
            print(f"  {gate_name} (no dependencies)")

    # Show execution order
    print("\nSuggested Execution Order:")
    executed = set()
    order = 1

    while len(executed) < len(dep_map):
        for gate_name, deps in dep_map.items():
            if gate_name not in executed:
                # Check if all dependencies are satisfied
                if all(d in executed for d in deps):
                    print(f"  {order}. {gate_name}")
                    executed.add(gate_name)
                    order += 1
                    break


def example_gate_status():
    """Check gate status after running."""
    registry = GateRegistry()

    print("\n" + "=" * 60)
    print("Gate Status Check")
    print("=" * 60)

    # Run gates first
    print("\nRunning gates...")
    results = registry.run()

    # Check status
    print(f"\nGate Status Report ({len(results)} total):")
    print("-" * 60)

    for result in results:
        status_icon = "✓" if result.passed else "✗"
        status_text = "PASSED" if result.passed else f"FAILED: {result.error}"
        print(f"{status_icon} {result.name:20} {status_text}")

    # Summary
    passed = sum(1 for r in results if r.passed)
    failed = len(results) - passed

    print("-" * 60)
    print(f"Summary: {passed}/{len(results)} gates passed ({100*passed//len(results)}%)")

    if failed > 0:
        print(f"\n⚠️  {failed} gate(s) failed. Review above for details.")
    else:
        print("\n✅ All gates passed!")


def example_gate_filtering():
    """Filter gates by name pattern."""
    registry = GateRegistry()

    print("\n" + "=" * 60)
    print("Gate Filtering")
    print("=" * 60)

    # Find gates matching pattern
    all_gates = {g.name: g for g in registry.gates}

    # Filter for package-related gates
    print("\nGates matching 'Package' pattern:")
    for name in all_gates.keys():
        if "Package" in name or "package" in name.lower():
            print(f"  - {name}")

    # Filter for boot-related gates
    print("\nGates matching 'Boot' pattern:")
    for name in all_gates.keys():
        if "Boot" in name or "boot" in name.lower():
            print(f"  - {name}")

    # Filter for graphics-related gates
    print("\nGates matching 'Graphics' pattern:")
    for name in all_gates.keys():
        if "Graphics" in name or "graphics" in name.lower():
            print(f"  - {name}")


def example_gate_history():
    """Track gate results over time."""
    registry = GateRegistry()

    print("\n" + "=" * 60)
    print("Gate Results History")
    print("=" * 60)

    # Run gates multiple times
    print("\nRun 1:")
    results1 = registry.run()
    passed1 = sum(1 for r in results1 if r.passed)
    print(f"  Results: {passed1}/{len(results1)} passed")

    print("\nRun 2:")
    results2 = registry.run()
    passed2 = sum(1 for r in results2 if r.passed)
    print(f"  Results: {passed2}/{len(results2)} passed")

    print("\nRun 3:")
    results3 = registry.run()
    passed3 = sum(1 for r in results3 if r.passed)
    print(f"  Results: {passed3}/{len(results3)} passed")

    # Summary
    print("\nHistory Summary:")
    print(f"  Run 1: {passed1}/{len(results1)} ✓")
    print(f"  Run 2: {passed2}/{len(results2)} ✓")
    print(f"  Run 3: {passed3}/{len(results3)} ✓")

    if passed1 == passed2 == passed3:
        print("\n✅ Gate results are stable across runs")
    else:
        print("\n⚠️  Gate results vary across runs (flaky?)")


if __name__ == "__main__":
    print("PalexusOS GateRegistry Examples\n")

    # Example 1: List gates
    print("1. Available Gates")
    example_list_gates()

    # Example 2: Run all gates
    print("\n2. Run All Gates")
    example_run_all_gates()

    # Example 3: Run specific gates
    print("\n3. Run Specific Gates")
    example_run_specific_gates()

    # Example 4: Dependencies
    print("\n4. Gate Dependencies")
    example_gate_dependencies()

    # Example 5: Status check
    print("\n5. Gate Status Check")
    example_gate_status()

    # Example 6: Filtering
    print("\n6. Gate Filtering")
    example_gate_filtering()

    # Example 7: History
    print("\n7. Gate Results History")
    example_gate_history()

    print("\n" + "=" * 60)
    print("✅ All examples completed successfully!")
    print("=" * 60)
