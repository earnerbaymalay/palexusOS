#!/usr/bin/env python3
"""TestOrchestrator: collect results into suites and report on them.

The orchestrator does not discover or execute tests yet: run_* returns each
registered suite with the results it was registered with. So the pattern is
"run checks yourself, record Results in a Suite, let the orchestrator
aggregate and report". Here the checks are the gate self-tests.

Run from anywhere:  python examples/04_test_orchestrator_example.py
"""

import time
from pathlib import Path

from palexus.build.gate_registry import GateRegistry
from palexus.test.orchestrator import Level, Result, Suite, TestOrchestrator

REPO_ROOT = Path(__file__).resolve().parent.parent


def suite_from_checks(name: str, level: Level, checks: dict[str, bool]) -> Suite:
    results = [
        Result(name=check, level=level, passed=ok, error=None if ok else "check returned False")
        for check, ok in checks.items()
    ]
    passed = sum(r.passed for r in results)
    return Suite(
        name=name,
        level=level,
        test_count=len(results),
        passed=passed,
        failed=len(results) - passed,
        tests=results,
    )


def gate_self_tests() -> Suite:
    registry = GateRegistry()
    start = time.perf_counter()
    checks = {name: registry.test(name) for name in registry.gates}
    suite = suite_from_checks("gate_self_tests", Level.GATE, checks)
    suite.duration_ms = (time.perf_counter() - start) * 1000
    return suite


def main() -> None:
    orchestrator = TestOrchestrator(REPO_ROOT)
    print("before registering:", orchestrator.summary())

    orchestrator.register_suite(gate_self_tests())
    # A suite with a failure, to show report_failures().
    orchestrator.register_suite(
        suite_from_checks("example_unit", Level.UNIT, {"adds": 1 + 1 == 2, "broken": 1 + 1 == 3})
    )

    print("\n== All levels ==")
    for name, suite in orchestrator.run_all().items():
        print(f"  {name:16} {suite.passed}/{suite.test_count} passed ({suite.pass_rate:.0f}%)")
    print(" ", orchestrator.summary())
    print("  failures:", orchestrator.report_failures())

    print("\n== One level ==")
    print("  gate suites:", list(orchestrator.run_level(Level.GATE)))

    print("\n== One test record ==")
    print(" ", orchestrator.test_specific("gate_self_tests", "package"))


if __name__ == "__main__":
    main()
