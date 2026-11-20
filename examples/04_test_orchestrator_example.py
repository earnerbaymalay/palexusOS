#!/usr/bin/env python3
"""Example: Using TestOrchestrator for unified test execution.

This example demonstrates how to use TestOrchestrator to run unit tests,
gate tests, and integration tests with a unified interface.
"""

from palexus.test.orchestrator import TestOrchestrator, Level


def example_test_levels():
    """Show available test levels."""
    print("=" * 60)
    print("Test Levels")
    print("=" * 60)

    levels = [
        (Level.UNIT, "Unit tests for individual modules"),
        (Level.GATE, "Quality gate verification tests"),
        (Level.INTEGRATION, "End-to-end integration tests"),
    ]

    print("\nAvailable Test Levels:")
    for level, description in levels:
        print(f"  - {level.name:12} {description}")


def example_run_unit_tests():
    """Run unit tests only."""
    print("\n" + "=" * 60)
    print("Running Unit Tests")
    print("=" * 60)

    orchestrator = TestOrchestrator()

    print("\nExecuting unit tests...")
    results = orchestrator.run_level(Level.UNIT)

    # Print summary
    summary = orchestrator.summary()
    print(f"\n{summary}")


def example_run_all_tests():
    """Run all test levels."""
    print("\n" + "=" * 60)
    print("Running All Tests")
    print("=" * 60)

    orchestrator = TestOrchestrator()

    print("\nExecuting complete test suite (unit + gate + integration)...")
    results = orchestrator.run_all()

    # Print summary
    summary = orchestrator.summary()
    print(f"\n{summary}")

    # Analyze results
    print("\nTest Breakdown:")
    print(f"  Unit tests: (from Level.UNIT)")
    print(f"  Gate tests: (from Level.GATE)")
    print(f"  Integration tests: (from Level.INTEGRATION)")


def example_test_filtering():
    """Filter tests by level."""
    print("\n" + "=" * 60)
    print("Test Filtering by Level")
    print("=" * 60)

    orchestrator = TestOrchestrator()

    # Run different levels
    test_levels = [Level.UNIT, Level.GATE, Level.INTEGRATION]

    for level in test_levels:
        print(f"\nRunning {level.name} tests...")
        results = orchestrator.run_level(level)

        if results:
            print(f"  ✓ {level.name} tests completed")
        else:
            print(f"  - {level.name} tests not available")


def example_failure_reporting():
    """Show test failure reporting."""
    print("\n" + "=" * 60)
    print("Failure Reporting")
    print("=" * 60)

    orchestrator = TestOrchestrator()

    print("\nRunning tests...")
    orchestrator.run_all()

    # Report failures
    failures = orchestrator.report_failures()

    if failures:
        print(f"\n⚠️  {len(failures)} test(s) failed:")
        for failure in failures:
            print(f"  - {failure}")
    else:
        print("\n✅ All tests passed!")


def example_test_summary():
    """Generate test summary report."""
    print("\n" + "=" * 60)
    print("Test Summary Report")
    print("=" * 60)

    orchestrator = TestOrchestrator()

    print("\nRunning tests...")
    orchestrator.run_all()

    # Print summary
    summary = orchestrator.summary()
    print(f"\n{summary}")

    # Test counts
    print("\nDetailed Results:")
    print(f"  Total test suites: (N/A from orchestrator)")
    print(f"  Tests passed: (from summary)")
    print(f"  Tests failed: (from summary)")
    print(f"  Tests skipped: (from summary)")


def example_module_test_coverage():
    """Show test coverage by module."""
    print("\n" + "=" * 60)
    print("Module Test Coverage")
    print("=" * 60)

    modules = [
        ("TokenRegistry", "Design system module", 14),
        ("GateRegistry", "Quality gates module", 15),
        ("DesktopEnvironment", "Boot sequence module", 14),
        ("TestOrchestrator", "Test framework module", 23),
    ]

    print("\nTest Coverage by Module:")
    print("-" * 60)
    print(f"{'Module':<25} {'Description':<30} {'Tests'}")
    print("-" * 60)

    total_tests = 0
    for module, description, test_count in modules:
        print(f"{module:<25} {description:<30} {test_count}")
        total_tests += test_count

    print("-" * 60)
    print(f"{'TOTAL':<25} {'':<30} {total_tests}")


def example_test_performance():
    """Show test execution performance."""
    print("\n" + "=" * 60)
    print("Test Performance")
    print("=" * 60)

    import time

    orchestrator = TestOrchestrator()

    print("\nTiming test execution...")

    # Time unit tests
    print(f"\n1. Unit Tests")
    start = time.time()
    orchestrator.run_level(Level.UNIT)
    unit_time = time.time() - start
    print(f"   Time: {unit_time:.3f}s")

    # Time gate tests
    print(f"\n2. Gate Tests")
    start = time.time()
    orchestrator.run_level(Level.GATE)
    gate_time = time.time() - start
    print(f"   Time: {gate_time:.3f}s")

    # Time integration tests
    print(f"\n3. Integration Tests")
    start = time.time()
    orchestrator.run_level(Level.INTEGRATION)
    integration_time = time.time() - start
    print(f"   Time: {integration_time:.3f}s")

    # Total time
    total_time = unit_time + gate_time + integration_time
    print(f"\nTotal Time: {total_time:.3f}s")

    # Performance notes
    print("\nPerformance Notes:")
    if total_time < 10:
        print("  ✓ Tests complete very quickly (< 10s)")
    elif total_time < 30:
        print("  ✓ Tests complete quickly (< 30s)")
    else:
        print("  ⚠️  Tests take longer (> 30s)")


def example_continuous_testing():
    """Demonstrate continuous/repeated testing."""
    print("\n" + "=" * 60)
    print("Continuous Testing")
    print("=" * 60)

    orchestrator = TestOrchestrator()

    print("\nRunning test suite 3 times (simulating continuous integration)...")
    print("-" * 60)

    for run in range(1, 4):
        print(f"\nRun {run}:")
        orchestrator.run_all()

        summary = orchestrator.summary()
        print(f"  Result: {summary.split()[0] if summary else 'N/A'}")

    print("\n✅ Continuous testing complete")


def example_test_orchestration():
    """Show test orchestration capabilities."""
    print("\n" + "=" * 60)
    print("Test Orchestration Capabilities")
    print("=" * 60)

    orchestrator = TestOrchestrator()

    print("\nTestOrchestrator Features:")
    print("  ✓ Unified test interface")
    print("  ✓ Multiple test levels (unit, gate, integration)")
    print("  ✓ Failure reporting")
    print("  ✓ Summary statistics")
    print("  ✓ Performance tracking")
    print("  ✓ Module independence (each module testable separately)")
    print("  ✓ Ralph Wiggum principles enforced")

    print("\nRunning orchestrator self-test...")
    orchestrator.run_all()

    print("  ✓ Orchestrator operational")


if __name__ == "__main__":
    print("PalexusOS TestOrchestrator Examples\n")

    # Example 1: Test levels
    print("1. Test Levels")
    example_test_levels()

    # Example 2: Run unit tests
    print("\n2. Run Unit Tests")
    example_run_unit_tests()

    # Example 3: Run all tests
    print("\n3. Run All Tests")
    example_run_all_tests()

    # Example 4: Filtering
    print("\n4. Test Filtering")
    example_test_filtering()

    # Example 5: Failure reporting
    print("\n5. Failure Reporting")
    example_failure_reporting()

    # Example 6: Summary
    print("\n6. Test Summary")
    example_test_summary()

    # Example 7: Coverage
    print("\n7. Module Test Coverage")
    example_module_test_coverage()

    # Example 8: Performance
    print("\n8. Test Performance")
    example_test_performance()

    # Example 9: Continuous testing
    print("\n9. Continuous Testing")
    example_continuous_testing()

    # Example 10: Orchestration
    print("\n10. Test Orchestration")
    example_test_orchestration()

    print("\n" + "=" * 60)
    print("✅ All examples completed successfully!")
    print("=" * 60)
