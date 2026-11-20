#!/usr/bin/env python3
"""Measure PalexusOS module performance against budgets.

Usage:
    python scripts/perf_baseline.py              # measure and print
    python scripts/perf_baseline.py --check      # exit 1 if any budget is exceeded
    python scripts/perf_baseline.py --record     # append results to .perf/history.jsonl
    python scripts/perf_baseline.py --with-tests # also time the full pytest suite
    python scripts/perf_baseline.py --json       # machine-readable output
"""

from __future__ import annotations

import argparse
import json
import platform
import statistics
import subprocess
import sys
import time
from collections.abc import Callable
from datetime import UTC, datetime
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
TOKENS_FILE = REPO_ROOT / "docs" / "design-system" / "tokens.json"
HISTORY_FILE = REPO_ROOT / ".perf" / "history.jsonl"

# Budgets in milliseconds. A measurement above its budget fails --check.
BUDGETS_MS: dict[str, float] = {
    "token_load": 50.0,
    "token_access": 1.0,
    "gate_run_all": 500.0,
    "desktop_boot": 50.0,
    "test_suite": 60_000.0,
}


def median_ms(fn: Callable[[], object], runs: int) -> float:
    """Run fn once to warm up, then return the median of `runs` timings in ms."""
    fn()
    samples = []
    for _ in range(runs):
        start = time.perf_counter()
        fn()
        samples.append((time.perf_counter() - start) * 1000)
    return statistics.median(samples)


def measure(runs: int, with_tests: bool) -> dict[str, float]:
    from palexus.build.gate_registry import GateRegistry
    from palexus.design.token_registry import TokenRegistry
    from palexus.desktop.environment import DesktopEnvironment

    registry = TokenRegistry(TOKENS_FILE)
    results = {
        "token_load": median_ms(lambda: TokenRegistry(TOKENS_FILE), runs),
        "token_access": median_ms(registry.colors, runs),
        "gate_run_all": median_ms(lambda: GateRegistry().run(REPO_ROOT), runs),
        "desktop_boot": median_ms(lambda: DesktopEnvironment().boot(), runs),
    }

    if with_tests:
        start = time.perf_counter()
        subprocess.run(
            [sys.executable, "-m", "pytest", "tests/", "-q", "-p", "no:cacheprovider"],
            cwd=REPO_ROOT,
            capture_output=True,
            check=False,
        )
        results["test_suite"] = (time.perf_counter() - start) * 1000

    return results


def over_budget(results: dict[str, float]) -> list[str]:
    return [
        f"{name}: {value:.2f}ms > {BUDGETS_MS[name]:.0f}ms budget"
        for name, value in results.items()
        if value > BUDGETS_MS[name]
    ]


def record(results: dict[str, float]) -> None:
    HISTORY_FILE.parent.mkdir(exist_ok=True)
    entry = {
        "timestamp": datetime.now(UTC).isoformat(timespec="seconds"),
        "python": platform.python_version(),
        "machine": platform.machine(),
        "results_ms": {k: round(v, 3) for k, v in results.items()},
    }
    with HISTORY_FILE.open("a") as f:
        f.write(json.dumps(entry) + "\n")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--runs", type=int, default=20, help="timed runs per operation")
    parser.add_argument("--check", action="store_true", help="fail if over budget")
    parser.add_argument("--record", action="store_true", help="append to history")
    parser.add_argument("--with-tests", action="store_true", help="time the pytest suite")
    parser.add_argument("--json", action="store_true", help="print JSON")
    args = parser.parse_args()

    results = measure(args.runs, args.with_tests)

    if args.json:
        print(json.dumps({k: round(v, 3) for k, v in results.items()}, indent=2))
    else:
        print(f"{'operation':<14} {'median':>11} {'budget':>10}")
        for name, value in results.items():
            mark = "ok" if value <= BUDGETS_MS[name] else "OVER"
            print(f"{name:<14} {value:>9.2f}ms {BUDGETS_MS[name]:>8.0f}ms  {mark}")

    if args.record:
        record(results)

    failures = over_budget(results)
    if args.check and failures:
        for line in failures:
            print(f"budget exceeded: {line}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
