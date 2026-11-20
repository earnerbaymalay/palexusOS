"""Tests for desktop environment."""

from pathlib import Path

import pytest

from palexus.desktop.environment import (
    DesktopEnvironment,
    BootPhase,
    GreeterAdapter,
    HUDAdapter,
    ThemeAdapter,
)


class TestGreeterAdapter:
    """Test greeter adapter."""

    def test_adapter_name(self):
        """GreeterAdapter has correct name."""
        adapter = GreeterAdapter()
        assert adapter.name == "palexus-greeter"

    def test_adapter_test(self):
        """GreeterAdapter passes test."""
        adapter = GreeterAdapter()
        assert adapter.test()


class TestHUDAdapter:
    """Test HUD adapter."""

    def test_adapter_name(self):
        """HUDAdapter has correct name."""
        adapter = HUDAdapter()
        assert adapter.name == "llm-quickfire-panel"

    def test_adapter_test(self):
        """HUDAdapter passes test."""
        adapter = HUDAdapter()
        assert adapter.test()


class TestThemeAdapter:
    """Test theme adapter."""

    def test_adapter_name(self):
        """ThemeAdapter has correct name."""
        adapter = ThemeAdapter()
        assert adapter.name == "theme-loader"

    def test_adapter_test(self):
        """ThemeAdapter passes test."""
        adapter = ThemeAdapter()
        assert adapter.test()

    def test_set_design_tokens(self, tmp_path):
        """ThemeAdapter can set design tokens path."""
        adapter = ThemeAdapter()
        tokens_path = tmp_path / "tokens.json"
        adapter.set_design_tokens(tokens_path)
        assert adapter.design_tokens_path == tokens_path


class TestBootPhase:
    """Test boot phase enum."""

    def test_phases_defined(self):
        """All boot phases are defined."""
        assert BootPhase.GREETER
        assert BootPhase.USER_SELECT
        assert BootPhase.HUD
        assert BootPhase.THEME
        assert BootPhase.COMPLETE


class TestBootContext:
    """Test boot context."""

    def test_initial_state(self):
        """BootContext starts at GREETER phase."""
        from palexus.desktop.environment import BootContext

        ctx = BootContext()
        assert ctx.phase == BootPhase.GREETER
        assert ctx.selected_user is None
        assert ctx.hud_enabled is True


class TestDesktopEnvironment:
    """Test desktop environment."""

    def test_initialization(self):
        """DesktopEnvironment initializes all adapters."""
        env = DesktopEnvironment()
        assert env.greeter is not None
        assert env.hud is not None
        assert env.theme is not None

    def test_boot_sequence(self):
        """DesktopEnvironment runs boot sequence."""
        env = DesktopEnvironment()
        context = env.boot()

        # Context should progress through phases
        assert context.phase == BootPhase.COMPLETE

    def test_hud_interface_enabled(self, tmp_path):
        """HUD interface returns status when enabled."""
        # Create mock HUD config to prevent disabling
        env = DesktopEnvironment()
        hud_conf = tmp_path / "hud.conf"
        hud_conf.write_text("[hud]\nenabled=true\n")
        env.hud.config_path = hud_conf

        env.boot()

        status = env.hud_interface()
        assert status is not None
        assert "HUD" in status

    def test_hud_interface_disabled(self):
        """HUD interface returns None when disabled."""
        env = DesktopEnvironment()
        env.context.hud_enabled = False
        env.boot()

        status = env.hud_interface()
        assert status is None

    def test_theme_loader_path(self):
        """Theme loader provides configuration path."""
        env = DesktopEnvironment()
        path = env.theme_loader()

        assert path == Path("docs/design-system/tokens.json")

    def test_set_design_tokens(self, tmp_path):
        """DesktopEnvironment can set design tokens."""
        env = DesktopEnvironment()
        tokens_path = tmp_path / "tokens.json"
        env.set_design_tokens(tokens_path)

        assert env.theme_loader() == tokens_path

    def test_adapters_pass_tests(self):
        """All adapters pass tests."""
        env = DesktopEnvironment()
        assert env.test_adapters()

    def test_reset_context(self):
        """DesktopEnvironment can reset boot context."""
        env = DesktopEnvironment()
        env.boot()

        # Context should be at COMPLETE
        assert env.context.phase == BootPhase.COMPLETE

        # Reset
        env.reset()

        # Context should be back at GREETER
        assert env.context.phase == BootPhase.GREETER
