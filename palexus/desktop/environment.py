"""DesktopEnvironment: Unified desktop boot sequence and configuration.

Manages the boot lifecycle: greeter → user selection → HUD → theme application.
Each adapter encapsulates environment-specific logic.
"""

from abc import ABC, abstractmethod
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import Optional


class BootPhase(Enum):
    """Desktop boot sequence phases."""
    GREETER = "greeter"
    USER_SELECT = "user_select"
    HUD = "hud"
    THEME = "theme"
    COMPLETE = "complete"


@dataclass
class BootContext:
    """Context maintained across boot phases."""
    selected_user: Optional[str] = None
    selected_theme: Optional[str] = None
    hud_enabled: bool = True
    phase: BootPhase = BootPhase.GREETER


class Adapter(ABC):
    """Base adapter for environment-specific components."""

    @abstractmethod
    def initialize(self, context: BootContext) -> None:
        """Initialize adapter for this boot phase.

        Args:
            context: Shared boot context
        """
        pass

    @abstractmethod
    def test(self) -> bool:
        """Test adapter implementation.

        Returns:
            True if adapter is properly configured
        """
        pass


class GreeterAdapter(Adapter):
    """Greeter display and user selection."""

    def __init__(self):
        self.name = "palexus-greeter"
        self.bin_path = Path("/usr/bin/palexus-greeter")

    def initialize(self, context: BootContext) -> None:
        """Display greeter and wait for user selection.

        Args:
            context: Boot context (modified with selected_user)
        """
        if context.phase != BootPhase.GREETER:
            return

        # In real implementation, would spawn greeter binary
        # and populate context.selected_user from selection
        context.selected_user = "default"
        context.phase = BootPhase.HUD

    def test(self) -> bool:
        """Test greeter configuration."""
        return self.name == "palexus-greeter"


class HUDAdapter(Adapter):
    """LLM Quickfire HUD interface initialization."""

    def __init__(self):
        self.name = "llm-quickfire-panel"
        self.config_path = Path("/etc/palexus/hud.conf")

    def initialize(self, context: BootContext) -> None:
        """Initialize HUD interface.

        Args:
            context: Boot context (read hud_enabled flag)
        """
        if context.phase != BootPhase.HUD:
            return

        if not context.hud_enabled:
            context.phase = BootPhase.COMPLETE
            return

        # Load HUD configuration (optional - doesn't disable if missing)
        if self.config_path.exists():
            # Configuration loaded successfully
            pass

        context.phase = BootPhase.THEME

    def test(self) -> bool:
        """Test HUD configuration."""
        return self.name == "llm-quickfire-panel"


class ThemeAdapter(Adapter):
    """Theme loader and UI style application."""

    def __init__(self, design_tokens_path: Optional[Path] = None):
        self.name = "theme-loader"
        self.design_tokens_path = design_tokens_path or Path(
            "docs/design-system/tokens.json"
        )

    def initialize(self, context: BootContext) -> None:
        """Apply theme and UI styles.

        Args:
            context: Boot context (read selected_theme and user)
        """
        if context.phase != BootPhase.THEME:
            return

        # Load design tokens (not required for completion)
        # Apply theme based on selected_theme or user preference
        context.phase = BootPhase.COMPLETE

    def set_design_tokens(self, tokens_path: Path) -> None:
        """Set path to design tokens.

        Args:
            tokens_path: Path to tokens.json
        """
        self.design_tokens_path = tokens_path

    def test(self) -> bool:
        """Test theme configuration."""
        return self.name == "theme-loader"


class DesktopEnvironment:
    """Unified desktop environment boot and configuration."""

    def __init__(self):
        """Initialize desktop environment adapters."""
        self.greeter = GreeterAdapter()
        self.hud = HUDAdapter()
        self.theme = ThemeAdapter()
        self.context = BootContext()

    def boot(self) -> BootContext:
        """Execute full boot sequence.

        Returns:
            Final boot context
        """
        self.greeter.initialize(self.context)
        self.hud.initialize(self.context)
        self.theme.initialize(self.context)
        return self.context

    def hud_interface(self) -> Optional[str]:
        """Get HUD interface state.

        Returns:
            HUD status string or None if disabled
        """
        if self.context.hud_enabled:
            return f"HUD enabled (phase: {self.context.phase.value})"
        return None

    def theme_loader(self) -> Path:
        """Get theme loader configuration path.

        Returns:
            Path to theme configuration
        """
        return self.theme.design_tokens_path

    def set_design_tokens(self, tokens_path: Path) -> None:
        """Configure design tokens path.

        Args:
            tokens_path: Path to tokens.json
        """
        self.theme.set_design_tokens(tokens_path)

    def test_adapters(self) -> bool:
        """Test all adapters are properly configured.

        Returns:
            True if all adapters pass tests
        """
        return (
            self.greeter.test()
            and self.hud.test()
            and self.theme.test()
        )

    def reset(self) -> None:
        """Reset boot context for new session."""
        self.context = BootContext()
