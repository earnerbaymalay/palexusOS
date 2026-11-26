"""TokenRegistry: Unified design token management and export.

Single source of truth for all design tokens (colors, typography, spacing, etc.).
Provides typed access and format-specific exporters.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from pathlib import Path
from typing import Any


@dataclass
class TokenSchema:
    """Design token schema definition."""

    version: str
    name: str
    colors: dict[str, dict[str, Any]]
    typography: dict[str, Any]
    spacing: dict[str, str]
    radius: dict[str, str]
    shadows: dict[str, str]


class TokenRegistry:
    """Unified registry for all design tokens."""

    def __init__(self, tokens_file: Path):
        """Load tokens from JSON file.

        Args:
            tokens_file: Path to tokens.json

        Raises:
            FileNotFoundError: If tokens file not found
            ValueError: If tokens JSON invalid or schema violated
        """
        self.tokens_file = Path(tokens_file)
        self._data: dict[str, Any] = {}
        self.load()

    def load(self) -> None:
        """Load and validate tokens from file."""
        if not self.tokens_file.exists():
            raise FileNotFoundError(f"Tokens file not found: {self.tokens_file}")

        with open(self.tokens_file) as f:
            self._data = json.load(f)

        self.validate()

    def validate(self) -> None:
        """Validate token schema.

        Raises:
            ValueError: If required fields missing or invalid
        """
        required = {"colors", "typography", "spacing", "radius"}
        missing = required - set(self._data.keys())
        if missing:
            raise ValueError(f"Missing required token sections: {missing}")
        for key in ("colors", "typography", "spacing", "radius"):
            if not isinstance(self._data.get(key), dict):
                raise ValueError(f"Token section '{key}' must be an object")
        if "shadows" in self._data and not isinstance(self._data["shadows"], dict):
            raise ValueError("Token section 'shadows' must be an object")

    def colors(self, category: str | None = None) -> dict[str, Any]:
        """Get color tokens.

        Args:
            category: Optional color category (primary, surface, text, functional)

        Returns:
            All colors or specific category
        """
        colors = self._data.get("colors", {})
        if category:
            return colors.get(category, {})
        return colors

    def color(self, category: str, name: str) -> str:
        """Get specific color value.

        Args:
            category: Color category
            name: Color name

        Returns:
            Hex color value

        Raises:
            KeyError: If color not found
        """
        return self.colors(category)[name]

    def typography(self) -> dict[str, Any]:
        """Get typography tokens."""
        return self._data.get("typography", {})

    def spacing(self) -> dict[str, str]:
        """Get spacing tokens."""
        return self._data.get("spacing", {})

    def space(self, size: str) -> str:
        """Get specific spacing value.

        Args:
            size: Spacing size (xs, sm, md, lg, xl)

        Returns:
            Spacing value (e.g., "8px")

        Raises:
            KeyError: If size not found
        """
        return self.spacing()[size]

    def radius(self) -> dict[str, str]:
        """Get border radius tokens."""
        return self._data.get("radius", {})

    def shadows(self) -> dict[str, str]:
        """Get shadow tokens."""
        return self._data.get("shadows", {})

    def all(self) -> dict[str, Any]:
        """Get all tokens."""
        return self._data.copy()


class Exporter:
    """Base class for token exporters."""

    def __init__(self, registry: TokenRegistry):
        self.registry = registry

    def export(self) -> str:
        raise NotImplementedError


class CSSExporter(Exporter):
    """Export tokens as CSS custom properties."""

    def export(self) -> str:
        """Generate CSS custom properties.

        Returns:
            CSS string with :root variables
        """
        lines = [":root {"]

        # Colors
        for category, palette in self.registry.colors().items():
            for name, value in palette.items():
                if isinstance(value, dict):
                    for subname, subvalue in value.items():
                        var_name = f"--color-{category}-{name}-{subname}"
                        lines.append(f"  {var_name}: {subvalue};")
                else:
                    var_name = f"--color-{category}-{name}"
                    lines.append(f"  {var_name}: {value};")

        # Spacing
        for size, value in self.registry.spacing().items():
            lines.append(f"  --space-{size}: {value};")

        # Radius
        for size, value in self.registry.radius().items():
            lines.append(f"  --radius-{size}: {value};")

        # Shadows
        for name, value in self.registry.shadows().items():
            lines.append(f"  --shadow-{name}: {value};")

        lines.append("}")
        return "\n".join(lines)


class ShellExporter(Exporter):
    """Export tokens as shell environment variables."""

    def export(self) -> str:
        """Generate shell exports.

        Returns:
            Shell script with export statements
        """
        lines = ["#!/bin/bash", "# PalexusOS Design System Colors"]

        # Primary colors
        primary = self.registry.colors("primary")
        for name, value in primary.items():
            var_name = f"COLOR_{name.upper()}"
            lines.append(f"export {var_name}='{value}'")

        # Surface
        surface = self.registry.colors("surface")
        for level, value in surface.items():
            var_name = f"COLOR_SURFACE_{level}"
            lines.append(f"export {var_name}='{value}'")

        # Functional
        functional = self.registry.colors("functional")
        for status, value in functional.items():
            var_name = f"COLOR_{status.upper()}"
            lines.append(f"export {var_name}='{value}'")

        return "\n".join(lines) + "\n"


class KittyExporter(Exporter):
    """Export tokens as Kitty terminal configuration."""

    def export(self) -> str:
        """Generate Kitty color configuration.

        Returns:
            Kitty .conf format
        """
        lines = [
            "# PalexusOS Design System Colors for Kitty Terminal",
            "# Generated from docs/design-system/tokens.json",
            "",
        ]

        primary = self.registry.colors("primary")
        surface = self.registry.colors("surface")

        lines.extend(
            [
                f"foreground {primary.get('chrome', '#cdd6f4')}",
                f"background {surface.get('900', '#11111b')}",
                f"cursor {primary.get('mauve', '#cba6f7')}",
                f"selection_background {primary.get('mauve', '#cba6f7')}",
            ]
        )

        return "\n".join(lines) + "\n"


class XFCEExporter(Exporter):
    """Export tokens as XFCE theme configuration."""

    def __init__(self, registry: TokenRegistry):
        self.registry = registry

    def export(self) -> str:
        """Generate XFCE theme colors.

        Returns:
            XFCE theme .colors format
        """
        lines = [
            "# PalexusOS Design System for XFCE",
            "# Generated from docs/design-system/tokens.json",
            "",
            "[Palexus]",
        ]

        primary = self.registry.colors("primary")
        surface = self.registry.colors("surface")

        lines.extend(
            [
                f"title_font_color={primary.get('chrome', '#cdd6f4')}",
                f"title_font_color_active={primary.get('mauve', '#cba6f7')}",
                f"bg_color={surface.get('800', '#1e1e2e')}",
                f"border_color_active={primary.get('mauve', '#cba6f7')}",
            ]
        )

        return "\n".join(lines) + "\n"
