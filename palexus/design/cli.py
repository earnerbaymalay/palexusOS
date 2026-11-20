"""CLI tool for design system token management."""

import argparse
import json
import sys
from pathlib import Path

from .token_registry import TokenRegistry


def main() -> int:
    """Design system CLI entry point."""
    parser = argparse.ArgumentParser(
        description="PalexusOS Design System: Manage design tokens",
        prog="palexus-design",
    )
    subparsers = parser.add_subparsers(dest="command", help="Command to run")

    # List tokens command
    list_parser = subparsers.add_parser("list", help="List all design tokens")
    list_parser.add_argument(
        "--format", choices=["table", "json"], default="table", help="Output format"
    )

    # Validate tokens command
    subparsers.add_parser("validate", help="Validate token schema")

    # Export command
    export_parser = subparsers.add_parser("export", help="Export tokens to format")
    export_parser.add_argument(
        "format",
        choices=["css", "shell", "kitty", "xfce"],
        help="Export format",
    )
    export_parser.add_argument("output", help="Output file path")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        return 0

    # Load tokens
    tokens_file = Path("docs/design-system/tokens.json")
    if not tokens_file.exists():
        print(f"Error: {tokens_file} not found", file=sys.stderr)
        return 1

    try:
        registry = TokenRegistry(tokens_file)
    except Exception as e:  # noqa: BLE001 - CLI boundary: report any failure as a clean error
        print(f"Error loading tokens: {e}", file=sys.stderr)
        return 1

    # Execute command
    if args.command == "list":
        return cmd_list(registry, args.format)
    elif args.command == "validate":
        return cmd_validate(registry)
    elif args.command == "export":
        return cmd_export(registry, args.format, args.output)

    return 0


def cmd_list(registry: TokenRegistry, fmt: str) -> int:
    """List all design tokens."""
    colors = registry.colors()

    if fmt == "json":
        print(json.dumps(colors, indent=2))
    else:
        # Table format
        print("Design System Colors:")
        print("-" * 50)
        for name, value in colors.items():
            print(f"  {name:30} {value}")

    return 0


def cmd_validate(registry: TokenRegistry) -> int:
    """Validate token schema."""
    try:
        registry.validate()
        print("✓ Token schema valid")
        return 0
    except Exception as e:  # noqa: BLE001 - CLI boundary: report any failure as a clean error
        print(f"✗ Token validation failed: {e}", file=sys.stderr)
        return 1


def cmd_export(registry: TokenRegistry, fmt: str, output: str) -> int:
    """Export tokens to format."""
    from .exporters import CSSExporter, KittyExporter, ShellExporter, XFCEExporter

    exporters = {
        "css": CSSExporter,
        "shell": ShellExporter,
        "kitty": KittyExporter,
        "xfce": XFCEExporter,
    }

    try:
        exporter_class = exporters[fmt]
        exporter = exporter_class(registry)
        content = exporter.export()

        Path(output).parent.mkdir(parents=True, exist_ok=True)
        Path(output).write_text(content)

        print(f"✓ Exported to {output}")
        return 0
    except Exception as e:  # noqa: BLE001 - CLI boundary: report any failure as a clean error
        print(f"✗ Export failed: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
