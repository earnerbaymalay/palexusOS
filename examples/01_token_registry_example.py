#!/usr/bin/env python3
"""TokenRegistry: read the design tokens and export them for each target.

Run from anywhere:  python examples/01_token_registry_example.py
"""

import tempfile
from pathlib import Path

from palexus.design.token_registry import (
    CSSExporter,
    KittyExporter,
    ShellExporter,
    TokenRegistry,
    XFCEExporter,
)

TOKENS = Path(__file__).resolve().parent.parent / "docs" / "design-system" / "tokens.json"


def read_tokens(registry: TokenRegistry) -> None:
    print("== Reading tokens ==")
    # Colours are grouped by category: primary, surface, text, functional, ...
    for category, colors in registry.colors().items():
        print(f"{category:12} {', '.join(colors)}")

    # One value, by category and name (KeyError if missing).
    print("accent:", registry.color("primary", "mauve"))

    # Spacing is a scale keyed by step.
    print("spacing:", registry.spacing())
    print("space('4'):", registry.space("4"))

    print("radius:", registry.radius())
    print("typography keys:", sorted(registry.typography()))


def export_all(registry: TokenRegistry, out_dir: Path) -> None:
    print("\n== Exporting ==")
    targets = {
        "tokens.css": CSSExporter,  # CSS custom properties for web UIs
        "tokens.sh": ShellExporter,  # environment variables for scripts
        "kitty.conf": KittyExporter,  # terminal colours
        "xfce.rc": XFCEExporter,  # XFCE theme colours
    }
    for filename, exporter in targets.items():
        content = exporter(registry).export()
        (out_dir / filename).write_text(content)
        first = content.strip().splitlines()[0]
        print(f"{filename:11} {len(content):5} bytes  first line: {first}")


def handle_bad_input(out_dir: Path) -> None:
    print("\n== Errors ==")
    try:
        TokenRegistry(out_dir / "missing.json")
    except FileNotFoundError as e:
        print("missing file ->", e)

    incomplete = out_dir / "incomplete.json"
    incomplete.write_text('{"colors": {}}')
    try:
        TokenRegistry(incomplete)
    except ValueError as e:
        # validate() requires colors, typography, spacing and radius.
        print("invalid schema ->", e)


def main() -> None:
    registry = TokenRegistry(TOKENS)
    read_tokens(registry)
    with tempfile.TemporaryDirectory() as tmp:
        export_all(registry, Path(tmp))
        handle_bad_input(Path(tmp))


if __name__ == "__main__":
    main()
