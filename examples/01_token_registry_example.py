#!/usr/bin/env python3
"""Example: Using TokenRegistry for design system management.

This example demonstrates how to use TokenRegistry to define, organize,
and export design tokens in multiple formats for use across PalexusOS.
"""

from palexus.design.token_registry import TokenRegistry


def example_color_tokens():
    """Define color tokens (primitives and semantics)."""
    registry = TokenRegistry()

    # Primitive colors (base palette)
    registry.register_token("color/primitive/mauve/50", "#f5f3ff")
    registry.register_token("color/primitive/mauve/500", "#cba6f7")
    registry.register_token("color/primitive/mauve/900", "#6a0dad")

    # Semantic colors (usage-based)
    registry.register_token("color/bg/primary", "#1e1e2e")  # Catppuccin Mocha
    registry.register_token("color/bg/secondary", "#313244")
    registry.register_token("color/text/primary", "#cdd6f4")
    registry.register_token("color/text/secondary", "#a6adc8")
    registry.register_token("color/accent/primary", "#cba6f7")  # Electric Mauve
    registry.register_token("color/accent/secondary", "#89b4fa")  # Sapphire

    return registry


def example_typography_tokens():
    """Define typography tokens."""
    registry = TokenRegistry()

    # Font families
    registry.register_token("typography/font/mono", "JetBrains Mono Nerd Font")
    registry.register_token("typography/font/sans", "Fira Sans")

    # Font sizes
    registry.register_token("typography/size/xs", "12px")
    registry.register_token("typography/size/sm", "14px")
    registry.register_token("typography/size/md", "16px")
    registry.register_token("typography/size/lg", "18px")
    registry.register_token("typography/size/xl", "20px")

    # Line heights
    registry.register_token("typography/line-height/tight", "1.2")
    registry.register_token("typography/line-height/normal", "1.5")
    registry.register_token("typography/line-height/loose", "1.8")

    return registry


def example_spacing_tokens():
    """Define spacing tokens."""
    registry = TokenRegistry()

    # Spacing scale (8px base)
    registry.register_token("spacing/xs", "4px")
    registry.register_token("spacing/sm", "8px")
    registry.register_token("spacing/md", "16px")
    registry.register_token("spacing/lg", "24px")
    registry.register_token("spacing/xl", "32px")
    registry.register_token("spacing/2xl", "48px")

    # Border radius
    registry.register_token("radius/none", "0px")
    registry.register_token("radius/sm", "4px")
    registry.register_token("radius/md", "8px")
    registry.register_token("radius/lg", "12px")
    registry.register_token("radius/full", "9999px")

    return registry


def example_export_formats():
    """Show exporting tokens to multiple formats."""
    registry = example_color_tokens()

    print("=" * 60)
    print("CSS Variables (for web UI)")
    print("=" * 60)
    css = registry.export_css()
    print(css[:500])  # First 500 chars
    print(f"... ({len(css)} total bytes)")

    print("\n" + "=" * 60)
    print("Shell Exports (for scripts)")
    print("=" * 60)
    shell = registry.export_shell()
    print(shell[:500])  # First 500 chars
    print(f"... ({len(shell)} total bytes)")

    print("\n" + "=" * 60)
    print("Kitty Terminal Config")
    print("=" * 60)
    kitty = registry.export_kitty()
    print(kitty[:500])  # First 500 chars
    print(f"... ({len(kitty)} total bytes)")

    print("\n" + "=" * 60)
    print("XFCE Theme")
    print("=" * 60)
    xfce = registry.export_xfce()
    print(xfce[:500])  # First 500 chars
    print(f"... ({len(xfce)} total bytes)")


def example_registry_operations():
    """Show common TokenRegistry operations."""
    registry = example_color_tokens()

    print("=" * 60)
    print("TokenRegistry Operations")
    print("=" * 60)

    # List all tokens
    print(f"\nTotal tokens registered: {len(registry.tokens)}")

    # Get a specific token
    primary_color = registry.get_token("color/bg/primary")
    print(f"Primary background color: {primary_color}")

    # Check token existence
    has_accent = "color/accent/primary" in registry.tokens
    print(f"Has accent color? {has_accent}")

    # Iterate over tokens
    print("\nAll registered tokens:")
    for name, value in registry.tokens.items():
        print(f"  {name:30} = {value}")


def example_complete_design_system():
    """Create a complete design system with all token types."""
    print("\n" + "=" * 60)
    print("Complete PalexusOS Design System")
    print("=" * 60)

    registry = TokenRegistry()

    # Colors (Catppuccin Mocha)
    colors = {
        "color/bg/primary": "#1e1e2e",
        "color/bg/secondary": "#313244",
        "color/text/primary": "#cdd6f4",
        "color/text/secondary": "#a6adc8",
        "color/accent/primary": "#cba6f7",  # Mauve
        "color/accent/secondary": "#89b4fa",  # Sapphire
        "color/border/default": "#45475a",
        "color/success": "#a6e3a1",
        "color/warning": "#f9e2af",
        "color/error": "#f38ba8",
    }

    # Typography
    typography = {
        "typography/font/mono": "JetBrains Mono Nerd Font",
        "typography/size/body": "16px",
        "typography/size/heading": "24px",
        "typography/line-height/normal": "1.5",
    }

    # Spacing
    spacing = {
        "spacing/xs": "4px",
        "spacing/sm": "8px",
        "spacing/md": "16px",
        "spacing/lg": "24px",
    }

    # Register all
    for name, value in {**colors, **typography, **spacing}.items():
        registry.register_token(name, value)

    print(f"\nDesign system contains:")
    print(f"  - {len(colors)} color tokens")
    print(f"  - {len(typography)} typography tokens")
    print(f"  - {len(spacing)} spacing tokens")
    print(f"  - Total: {len(registry.tokens)} tokens")

    # Export for use
    print(f"\nExporting to formats:")
    print(f"  - CSS: {len(registry.export_css())} bytes")
    print(f"  - Shell: {len(registry.export_shell())} bytes")
    print(f"  - Kitty: {len(registry.export_kitty())} bytes")
    print(f"  - XFCE: {len(registry.export_xfce())} bytes")

    return registry


if __name__ == "__main__":
    print("PalexusOS TokenRegistry Examples\n")

    # Example 1: Color tokens
    print("1. Color Tokens")
    example_color_tokens()
    print("✓ Color tokens created\n")

    # Example 2: Typography
    print("2. Typography Tokens")
    example_typography_tokens()
    print("✓ Typography tokens created\n")

    # Example 3: Spacing
    print("3. Spacing Tokens")
    example_spacing_tokens()
    print("✓ Spacing tokens created\n")

    # Example 4: Operations
    print("4. Registry Operations")
    example_registry_operations()

    # Example 5: Export formats
    print("\n5. Export to Multiple Formats")
    example_export_formats()

    # Example 6: Complete system
    registry = example_complete_design_system()

    print("\n" + "=" * 60)
    print("✅ All examples completed successfully!")
    print("=" * 60)
