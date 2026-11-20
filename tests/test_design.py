"""Tests for design token registry."""

import json
import tempfile
from pathlib import Path

import pytest

from palexus.design.token_registry import (
    TokenRegistry,
    CSSExporter,
    ShellExporter,
    KittyExporter,
    XFCEExporter,
)


@pytest.fixture
def sample_tokens():
    """Create sample tokens for testing."""
    return {
        "version": "1.0.0",
        "name": "PalexusOS Design Tokens",
        "colors": {
            "primary": {
                "mauve": "#cba6f7",
                "gold": "#fab387",
                "chrome": "#cdd6f4",
            },
            "surface": {
                "900": "#11111b",
                "800": "#1e1e2e",
            },
            "text": {
                "primary": "#cdd6f4",
            },
            "functional": {
                "success": "#a6e3a1",
                "error": "#f38ba8",
            },
        },
        "typography": {
            "families": {"mono": "JetBrains Mono"},
            "scales": {"h1": {"size": "32px"}},
        },
        "spacing": {
            "xs": "4px",
            "sm": "8px",
            "md": "16px",
        },
        "radius": {
            "none": "0",
            "sm": "4px",
        },
        "shadows": {
            "sm": "0 1px 2px rgba(0,0,0,0.1)",
        },
    }


@pytest.fixture
def tokens_file(sample_tokens):
    """Create temporary tokens.json file."""
    with tempfile.NamedTemporaryFile(
        mode="w", suffix=".json", delete=False
    ) as f:
        json.dump(sample_tokens, f)
        path = Path(f.name)

    yield path

    path.unlink()


class TestTokenRegistry:
    """Test TokenRegistry functionality."""

    def test_load_valid_tokens(self, tokens_file):
        """TokenRegistry loads valid tokens file."""
        registry = TokenRegistry(tokens_file)
        assert registry._data["version"] == "1.0.0"

    def test_load_missing_file_raises(self):
        """TokenRegistry raises FileNotFoundError for missing file."""
        with pytest.raises(FileNotFoundError):
            TokenRegistry(Path("/nonexistent/tokens.json"))

    def test_validate_missing_sections(self, sample_tokens):
        """TokenRegistry validates required sections."""
        invalid = {"version": "1.0.0"}

        with tempfile.NamedTemporaryFile(mode="w", suffix=".json") as f:
            json.dump(invalid, f)
            f.flush()

            with pytest.raises(ValueError):
                TokenRegistry(Path(f.name))

    def test_colors_all_categories(self, tokens_file):
        """Registry returns all color categories."""
        registry = TokenRegistry(tokens_file)
        colors = registry.colors()
        assert "primary" in colors
        assert "surface" in colors

    def test_colors_specific_category(self, tokens_file):
        """Registry returns specific color category."""
        registry = TokenRegistry(tokens_file)
        primary = registry.colors("primary")
        assert primary["mauve"] == "#cba6f7"

    def test_color_specific_value(self, tokens_file):
        """Registry returns specific color value."""
        registry = TokenRegistry(tokens_file)
        assert registry.color("primary", "mauve") == "#cba6f7"

    def test_spacing_access(self, tokens_file):
        """Registry provides spacing access."""
        registry = TokenRegistry(tokens_file)
        assert registry.space("md") == "16px"

    def test_all_tokens(self, tokens_file, sample_tokens):
        """Registry returns all tokens."""
        registry = TokenRegistry(tokens_file)
        all_tokens = registry.all()
        assert all_tokens == sample_tokens


class TestCSSExporter:
    """Test CSS exporter."""

    def test_css_export_produces_root_vars(self, tokens_file):
        """CSSExporter produces :root { --vars } format."""
        registry = TokenRegistry(tokens_file)
        exporter = CSSExporter(registry)
        css = exporter.export()

        assert ":root {" in css
        assert "--color-primary-mauve: #cba6f7" in css
        assert "--space-md: 16px" in css
        assert "}" in css


class TestShellExporter:
    """Test shell environment exporter."""

    def test_shell_export_produces_exports(self, tokens_file):
        """ShellExporter produces export statements."""
        registry = TokenRegistry(tokens_file)
        exporter = ShellExporter(registry)
        shell = exporter.export()

        assert "#!/bin/bash" in shell
        assert "export COLOR_MAUVE='#cba6f7'" in shell


class TestKittyExporter:
    """Test Kitty terminal exporter."""

    def test_kitty_export_produces_config(self, tokens_file):
        """KittyExporter produces Kitty config format."""
        registry = TokenRegistry(tokens_file)
        exporter = KittyExporter(registry)
        kitty = exporter.export()

        assert "foreground" in kitty
        assert "background" in kitty


class TestXFCEExporter:
    """Test XFCE theme exporter."""

    def test_xfce_export_produces_config(self, tokens_file):
        """XFCEExporter produces XFCE theme format."""
        registry = TokenRegistry(tokens_file)
        exporter = XFCEExporter(registry)
        xfce = exporter.export()

        assert "[Palexus]" in xfce
        assert "title_font_color=" in xfce
