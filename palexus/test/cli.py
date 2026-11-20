"""CLI tool for unified test orchestration."""

import argparse
import sys

from .orchestrator import Level, TestOrchestrator


def main() -> int:
    """Test orchestration CLI entry point."""
    parser = argparse.ArgumentParser(
        description="PalexusOS Test Framework: Run unified tests",
        prog="palexus-test",
    )
    subparsers = parser.add_subparsers(dest="command", help="Command to run")

    # Run tests command
    run_parser = subparsers.add_parser("run", help="Run tests")
    run_parser.add_argument(
        "--all",
        action="store_true",
        help="Run all tests (unit + gate + integration)",
    )
    run_parser.add_argument(
        "--unit",
        action="store_true",
        help="Run unit tests only",
    )
    run_parser.add_argument(
        "--gate",
        help="Run specific gate test",
    )
    run_parser.add_argument(
        "--integration",
        action="store_true",
        help="Run integration tests (boot sequence)",
    )
    run_parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Verbose output",
    )

    # List tests command
    subparsers.add_parser("list", help="List available tests")

    # Report command
    subparsers.add_parser("report", help="Generate test report")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return 0

    # Initialize orchestrator
    orchestrator = TestOrchestrator()

    # Execute command
    if args.command == "run":
        return cmd_run(orchestrator, args)
    elif args.command == "list":
        return cmd_list(orchestrator)
    elif args.command == "report":
        return cmd_report(orchestrator)

    return 0


def cmd_run(orchestrator: TestOrchestrator, args: argparse.Namespace) -> int:
    """Run tests."""
    print("Running tests...")
    print("-" * 50)

    try:
        if args.gate:
            # Run specific gate
            result = orchestrator.run_gate(args.gate)
            if result is None:
                print(f"✗ Gate '{args.gate}' not found", file=sys.stderr)
                return 1
            print(f"Gate {args.gate}: {result.summary()}")
            return 0 if result.passed > 0 else 1

        elif args.integration:
            # Run integration tests
            result = orchestrator.run_integration()
            if result is None:
                print("✗ Integration tests not available", file=sys.stderr)
                return 1
            print(f"Integration: {result.summary()}")
            return 0 if result.passed > 0 else 1

        elif args.unit:
            # Run unit tests
            level = Level.UNIT
            orchestrator.run_level(level)
            print(orchestrator.summary())
            return 0 if not orchestrator.report_failures() else 1

        else:
            # Run all (default)
            orchestrator.run_all()
            print(orchestrator.summary())
            return 0 if not orchestrator.report_failures() else 1

    except Exception as e:  # noqa: BLE001 - CLI boundary: report any failure as a clean error
        print(f"✗ Test execution failed: {e}", file=sys.stderr)
        return 1


def cmd_list(orchestrator: TestOrchestrator) -> int:
    """List available tests."""
    print("Available Tests:")
    print("-" * 50)
    print("  Unit tests:        Python test suite (tests/)")
    print("  Gate tests:        Quality verification gates (G1-G5)")
    print("  Integration tests: Boot sequence end-to-end")
    return 0


def cmd_report(orchestrator: TestOrchestrator) -> int:
    """Generate test report."""
    print("Test Report:")
    print("-" * 50)
    print(orchestrator.summary())

    failures = orchestrator.report_failures()
    if failures:
        print("\nFailed tests:")
        for failure in failures:
            print(f"  ✗ {failure}")
        return 1

    print("\n✓ All tests passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
