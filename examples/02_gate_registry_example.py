#!/usr/bin/env python3
"""GateRegistry: run the quality gates in dependency order and read the results.

Run from anywhere:  python examples/02_gate_registry_example.py
"""

import tempfile
from pathlib import Path

from palexus.build.gate_registry import GateRegistry, GateResult, GateStatus

REPO_ROOT = Path(__file__).resolve().parent.parent


def show(results: dict[str, GateResult]) -> None:
    for name, result in results.items():
        print(f"  {name:9} {result.status.value:8} {result.message}")


def list_gates(registry: GateRegistry) -> None:
    print("== Gates and their dependencies ==")
    for name, gate in registry.gates.items():
        deps = ", ".join(sorted(gate.dependencies)) or "-"
        print(f"  {name:9} depends on: {deps}")


def run_all() -> None:
    print("\n== Run every gate against this repository ==")
    # run() returns dict[gate name -> GateResult], in execution order.
    results = GateRegistry().run(REPO_ROOT)
    show(results)
    passed = [n for n, r in results.items() if r.status == GateStatus.PASSED]
    print(f"  {len(passed)}/{len(results)} passed")


def run_selected() -> None:
    print("\n== Run selected gates ==")
    # Only the named gates run; dependencies are not pulled in automatically.
    show(GateRegistry().run(REPO_ROOT, selected=["package", "iso"]))


def failure_propagation() -> None:
    print("\n== A failure skips everything that depends on it ==")
    # An empty directory has no design system, so the graphics gate fails;
    # boot (needs graphics) and perf (needs boot) are skipped, not run.
    with tempfile.TemporaryDirectory() as empty:
        show(GateRegistry().run(Path(empty)))


def self_test(registry: GateRegistry) -> None:
    print("\n== Gate self-tests ==")
    for name in registry.gates:
        print(f"  {name:9} {'ok' if registry.test(name) else 'FAILED'}")


def main() -> None:
    registry = GateRegistry()
    list_gates(registry)
    run_all()
    run_selected()
    failure_propagation()
    self_test(registry)


if __name__ == "__main__":
    main()
