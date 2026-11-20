"""CLI tool for build system gate verification."""

import argparse
import sys
from pathlib import Path

from .gate_registry import GateRegistry, GateResult, GateStatus

STATUS_MARK = {
    GateStatus.PASSED: "✓",
    GateStatus.FAILED: "✗",
    GateStatus.SKIPPED: "-",
    GateStatus.PENDING: "…",
}


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="PalexusOS Build System: Verify quality gates",
        prog="palexus-build",
    )
    parser.add_argument(
        "--repo-root",
        type=Path,
        default=Path.cwd(),
        help="Repository root the gates inspect (default: current directory)",
    )
    subparsers = parser.add_subparsers(dest="command", help="Command to run")

    run_parser = subparsers.add_parser("run", help="Run quality gates")
    run_parser.add_argument("--gates", help="Comma-separated gates to run (default: all)")
    run_parser.add_argument("--all", action="store_true", help="Run all gates (default)")

    subparsers.add_parser("list", help="List available gates")
    subparsers.add_parser("status", help="Run all gates and show each one's status")
    return parser


def main(argv: list[str] | None = None) -> int:
    """Build system CLI entry point."""
    parser = build_parser()
    args = parser.parse_args(argv)

    if not args.command:
        parser.print_help()
        return 0

    registry = GateRegistry()

    if args.command == "run":
        return cmd_run(registry, args.repo_root, args.gates)
    if args.command == "list":
        return cmd_list(registry)
    if args.command == "status":
        return cmd_status(registry, args.repo_root)
    return 0


def _print_results(results: dict[str, GateResult]) -> None:
    for name, result in results.items():
        message = f": {result.message}" if result.message else ""
        print(f"  {STATUS_MARK[result.status]} {name:10} {result.status.value}{message}")


def cmd_run(registry: GateRegistry, repo_root: Path, gates: str | None) -> int:
    """Run quality gates; exit 1 if any gate failed."""
    selected = [g.strip() for g in gates.split(",")] if gates else None
    if selected:
        unknown = [g for g in selected if g not in registry.gates]
        if unknown:
            print(f"✗ unknown gate(s): {', '.join(unknown)}", file=sys.stderr)
            print(f"  available: {', '.join(registry.gates)}", file=sys.stderr)
            return 1

    print("Running quality gates...")
    print("-" * 50)
    results = registry.run(repo_root, selected=selected)
    _print_results(results)

    passed = sum(1 for r in results.values() if r.status == GateStatus.PASSED)
    failed = sum(1 for r in results.values() if r.status == GateStatus.FAILED)
    print(f"\nResults: {passed}/{len(results)} gates passed")
    if failed:
        print(f"✗ {failed} gate(s) failed")
        return 1
    return 0


def cmd_list(registry: GateRegistry) -> int:
    """List available gates."""
    print("Available Quality Gates:")
    print("-" * 50)
    for name, gate in registry.gates.items():
        doc = (type(gate).__doc__ or "").strip().splitlines()
        description = doc[0] if doc else ""
        deps = f" (depends: {', '.join(sorted(gate.dependencies))})" if gate.dependencies else ""
        print(f"  {name:10} {description}{deps}")
    return 0


def cmd_status(registry: GateRegistry, repo_root: Path) -> int:
    """Show each gate's status. Gates are read-only checks, so this runs them."""
    print("Gate Status:")
    print("-" * 50)
    _print_results(registry.run(repo_root))
    return 0


if __name__ == "__main__":
    sys.exit(main())
