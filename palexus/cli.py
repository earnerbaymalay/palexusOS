"""`palexus` command: one entry point for the design, build and test CLIs.

palexus design export css out.css   ==  palexus-design export css out.css
palexus build run                   ==  palexus-build run
palexus test run --all              ==  palexus-test run --all
"""

import sys
from collections.abc import Callable
from importlib.metadata import PackageNotFoundError, version

from .build import cli as build_cli
from .design import cli as design_cli
from .test import cli as test_cli

COMMANDS: dict[str, tuple[Callable[[list[str]], int], str]] = {
    "design": (design_cli.main, "Design tokens: list, validate, export"),
    "build": (build_cli.main, "Quality gates: list, run, status"),
    "test": (test_cli.main, "Test orchestration: list, run"),
}


def _version() -> str:
    try:
        return version("palexus")
    except PackageNotFoundError:
        return "unknown (not installed)"


def _usage() -> str:
    lines = ["usage: palexus <command> [args...]", "", "commands:"]
    lines += [f"  {name:8} {summary}" for name, (_, summary) in COMMANDS.items()]
    lines += ["", "Run 'palexus <command> --help' for a command's options."]
    return "\n".join(lines)


def main(argv: list[str] | None = None) -> int:
    args = sys.argv[1:] if argv is None else argv

    if not args or args[0] in ("-h", "--help"):
        print(_usage())
        return 0
    if args[0] in ("-V", "--version"):
        print(f"palexus {_version()}")
        return 0

    command, rest = args[0], args[1:]
    if command not in COMMANDS:
        print(f"palexus: unknown command '{command}'\n\n{_usage()}", file=sys.stderr)
        return 2

    run, _ = COMMANDS[command]
    return run(rest)


if __name__ == "__main__":
    sys.exit(main())
