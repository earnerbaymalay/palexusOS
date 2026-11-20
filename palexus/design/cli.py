"""CLI tool for design system token management."""

import argparse
import json
import sys
from pathlib import Path
from typing import Any

from .token_registry import (
    CSSExporter,
    KittyExporter,
    ShellExporter,
    TokenRegistry,
    XFCEExporter,
)

DEFAULT_TOKENS = Path("docs/design-system/tokens.json")

EXPORTERS: dict[str, type[CSSExporter | ShellExporter | KittyExporter | XFCEExporter]] = {
    "css": CSSExporter,
    "shell": ShellExporter,
    "kitty": KittyExporter,
    "xfce": XFCEExporter,
}


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="PalexusOS Design System: Manage design tokens",
        prog="palexus-design",
    )
    parser.add_argument(
        "--tokens",
        type=Path,
        default=DEFAULT_TOKENS,
        help=f"Path to tokens.json (default: {DEFAULT_TOKENS})",
    )
    subparsers = parser.add_subparsers(dest="command", help="Command to run")

    list_parser = subparsers.add_parser("list", help="List color tokens")
    list_parser.add_argument(
        "--format", choices=["table", "json"], default="table", help="Output format"
    )

    subparsers.add_parser("validate", help="Validate token schema")

    export_parser = subparsers.add_parser("export", help="Export tokens to format")
    export_parser.add_argument("format", choices=sorted(EXPORTERS), help="Export format")
    export_parser.add_argument("output", help="Output file path")
    return parser


def main(argv: list[str] | None = None) -> int:
    """Design system CLI entry point."""
    parser = build_parser()
    args = parser.parse_args(argv)

    if not args.command:
        parser.print_help()
        return 0

    if not args.tokens.exists():
        print(f"Error: {args.tokens} not found", file=sys.stderr)
        return 1

    try:
        registry = TokenRegistry(args.tokens)
    except Exception as e:  # noqa: BLE001 - CLI boundary: report any failure as a clean error
        print(f"Error loading tokens: {e}", file=sys.stderr)
        return 1

    if args.command == "list":
        return cmd_list(registry, args.format)
    if args.command == "validate":
        return cmd_validate(registry)
    if args.command == "export":
        return cmd_export(registry, args.format, args.output)
    return 0


def _flatten(node: dict[str, Any], prefix: str = "") -> list[tuple[str, Any]]:
    rows: list[tuple[str, Any]] = []
    for key, value in node.items():
        name = f"{prefix}.{key}" if prefix else key
        if isinstance(value, dict):
            rows.extend(_flatten(value, name))
        else:
            rows.append((name, value))
    return rows


def cmd_list(registry: TokenRegistry, fmt: str) -> int:
    """List color tokens."""
    colors = registry.colors()

    if fmt == "json":
        print(json.dumps(colors, indent=2))
        return 0

    print("Design System Colors:")
    print("-" * 50)
    for name, value in _flatten(colors):
        print(f"  {name:30} {value}")
    return 0


def cmd_validate(registry: TokenRegistry) -> int:
    """Validate token schema."""
    try:
        registry.validate()
    except Exception as e:  # noqa: BLE001 - CLI boundary: report any failure as a clean error
        print(f"✗ Token validation failed: {e}", file=sys.stderr)
        return 1
    print("✓ Token schema valid")
    return 0


def cmd_export(registry: TokenRegistry, fmt: str, output: str) -> int:
    """Export tokens to format."""
    try:
        content = EXPORTERS[fmt](registry).export()
        Path(output).parent.mkdir(parents=True, exist_ok=True)
        Path(output).write_text(content)
    except Exception as e:  # noqa: BLE001 - CLI boundary: report any failure as a clean error
        print(f"✗ Export failed: {e}", file=sys.stderr)
        return 1
    print(f"✓ Exported to {output}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
