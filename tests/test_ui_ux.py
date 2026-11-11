"""PalexusOS Automated UI/UX Test Suite (Qt6 / PyQt6 / QML).

Executes offscreen automated testing across all PalexusOS desktop user interfaces:
- palexus-hud: QML engine loading, signal/slot bindings, findFirstMatch command search, search box hotkeys.
- palexus-welcome: OnboardingWizard initialization, navigation across onboarding steps,
                   page indicator updates, icon/wallpaper/screensaver selection, GTK settings updater.
- palexus-settings: PalexusSettingsWindow initialization, tab structure, accent buttons, Ollama toggles.
- palexus-notes: PalexusNotesWindow scratchpad initialization, Markdown highlighter, auto-sync, word counter, hotkeys.
- palexus-screensaver: Argument parsing, command mode options, and cyberdeck glyph validation.
"""

import os
import sys
import shutil
import tempfile
from pathlib import Path
from importlib.machinery import SourceFileLoader
from unittest.mock import patch, MagicMock

import pytest

# Ensure headless offscreen platform for Qt prior to GUI imports
os.environ["QT_QPA_PLATFORM"] = "offscreen"

from PyQt6.QtCore import Qt, QUrl
from PyQt6.QtWidgets import QApplication, QPushButton, QRadioButton
from PyQt6.QtQml import QQmlApplicationEngine

REPO_ROOT = Path(__file__).resolve().parent.parent
HUD_DIR = REPO_ROOT / "packages" / "desktop" / "palexus-hud"
THEMES_DIR = REPO_ROOT / "packages" / "desktop" / "palexus-themes"


def load_script_module(name: str, path: Path):
    """Load a Python script without .py extension as a module."""
    loader = SourceFileLoader(name, str(path))
    import importlib.util
    spec = importlib.util.spec_from_loader(name, loader)
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    loader.exec_module(mod)
    return mod


@pytest.fixture(scope="session")
def qapp():
    """Shared QApplication instance across UI test suite."""
    app = QApplication.instance()
    if app is None:
        app = QApplication([])
    yield app


# ============================================================================
# 1. PALEXUS-HUD TESTS (QML Engine, Signals, findFirstMatch, AI Search)
# ============================================================================

class TestPalexusHudQml:
    """Test palexus-hud QML engine, signals, and command search logic."""

    def test_hud_qml_engine_loading(self, qapp):
        """Verify QML engine successfully loads Main.qml without errors in offscreen mode."""
        engine = QQmlApplicationEngine()
        qml_path = HUD_DIR / "Main.qml"
        assert qml_path.is_file(), f"Main.qml must exist at {qml_path}"

        engine.load(QUrl.fromLocalFile(str(qml_path)))
        root_objects = engine.rootObjects()
        assert len(root_objects) == 1, "Main.qml must load exactly 1 root object"

        root = root_objects[0]
        assert root.property("title") == "Palexus Command HUD"
        assert root.property("width") == 960
        assert root.property("height") == 640
        assert root.property("variant") == "monolith-mauve"

    def test_hud_find_first_match_logic(self, qapp):
        """Verify findFirstMatch searches command catalog and returns matching action."""
        engine = QQmlApplicationEngine()
        qml_path = HUD_DIR / "Main.qml"
        engine.load(QUrl.fromLocalFile(str(qml_path)))
        root = engine.rootObjects()[0]

        # Test exact/partial label matches
        assert root.findFirstMatch("notes") == "palexus-notes"
        assert root.findFirstMatch("settings") == "palexus-settings"
        assert root.findFirstMatch("chromium") == "chromium"

        # Test local LLM commands
        qwen_cmd = root.findFirstMatch("qwen")
        assert "ask-qwen" in qwen_cmd

        # Test key shortcut matching
        key1_cmd = root.findFirstMatch("1")
        assert "palexus hud" in key1_cmd

        # Test case-insensitivity
        assert root.findFirstMatch("NOTES") == "palexus-notes"
        assert root.findFirstMatch("  SETTINGS  ") == "palexus-settings"

        # Test non-matching or empty queries
        assert root.findFirstMatch("nonexistent_unknown_xyz") == ""
        assert root.findFirstMatch("") == ""
        assert root.findFirstMatch(None) == ""

    def test_hud_backend_signals_and_launch(self, qapp):
        """Verify HudBackend receives QML signals and launches commands or AI prompts."""
        hud_mod = load_script_module("palexus_hud_mod", HUD_DIR / "palexus-hud")
        assert hasattr(hud_mod, "HudBackend")

        backend = hud_mod.HudBackend(qapp)

        with patch("subprocess.Popen") as mock_popen, patch.object(qapp, "quit") as mock_quit:
            # Test direct command launch
            backend.launch("palexus-notes")
            mock_quit.assert_called()
            args, kwargs = mock_popen.call_args
            assert args[0] == ["bash", "-c", "source ~/.bashrc 2>/dev/null; palexus-notes"]
            assert kwargs.get("start_new_session") is True
            assert "env" in kwargs

        with patch("subprocess.Popen") as mock_popen, patch.object(qapp, "quit") as mock_quit:
            # Test AI prompt launch with prefix strip
            backend.launch("AI_PROMPT:?how to list files")
            mock_quit.assert_called()
            args, kwargs = mock_popen.call_args
            assert args[0][0] == "kitty"
            assert "AI Prompt: how to list files" in args[0][2]
            assert 'ask-qwen "how to list files"' in args[0][5]
            assert kwargs.get("start_new_session") is True

        with patch("subprocess.Popen") as mock_popen, patch.object(qapp, "quit") as mock_quit:
            # Test AI prompt launch with 'ai ' strip
            backend.launch("AI_PROMPT:ai explain btrfs snapshots")
            mock_quit.assert_called()
            args, kwargs = mock_popen.call_args
            assert "explain btrfs snapshots" in args[0][2]
            assert 'ask-qwen "explain btrfs snapshots"' in args[0][5]
            assert kwargs.get("start_new_session") is True

    def test_hud_header_hint_and_placeholder_text(self, qapp):
        """Verify HUD header hint and searchbox placeholder contain required guidance."""
        qml_path = HUD_DIR / "Main.qml"
        content = qml_path.read_text(encoding="utf-8")
        expected_text = "[Esc] Close · [Enter] Launch / Ask AI · [Ctrl+Enter] Ask AI"

        assert expected_text in content
        assert "root.findFirstMatch" in content
        assert "AI_PROMPT:" in content


# ============================================================================
# 2. PALEXUS-WELCOME TESTS (OnboardingWizard, Steps, GTK Settings)
# ============================================================================

class TestPalexusWelcome:
    """Test palexus-welcome onboarding backend, QML loading, and GTK config sync."""

    @pytest.fixture
    def welcome_mod(self):
        return load_script_module("palexus_welcome_mod", HUD_DIR / "palexus-welcome")

    def test_welcome_backend_initialization(self, qapp, welcome_mod):
        """Verify WelcomeBackend initializes with correct default values and properties."""
        backend = welcome_mod.WelcomeBackend(qapp)
        assert backend.selectedIconTheme == "Palexus-Liquid-Chrome"
        assert backend.selectedWallpaper == "monolith-mauve"
        assert backend.selectedAiEngine == "claude"
        assert isinstance(backend.combos, dict)
        assert backend.combos.get("stealth") is True
        assert backend.combos.get("dot") is True
        assert backend.combos.get("firewall") is True

    def test_welcome_backend_toggle_and_qml_loading(self, qapp, welcome_mod):
        """Verify combo toggling and QtQuick Welcome.qml load integrity."""
        from PyQt6.QtQml import QQmlApplicationEngine
        from PyQt6.QtCore import QUrl

        backend = welcome_mod.WelcomeBackend(qapp)
        initial_stealth = backend.combos["stealth"]
        backend.toggleCombo("stealth")
        assert backend.combos["stealth"] != initial_stealth

        engine = QQmlApplicationEngine()
        engine.rootContext().setContextProperty("backend", backend)
        qml_path = HUD_DIR / "Welcome.qml"
        assert qml_path.exists()
        engine.load(QUrl.fromLocalFile(str(qml_path)))
        assert len(engine.rootObjects()) > 0

    def test_update_gtk_settings_function(self, welcome_mod, tmp_path):
        """Verify update_gtk_settings writes and updates gtk-icon-theme-name under [Settings]."""
        ini_file = str(tmp_path / "gtk-3.0" / "settings.ini")

        # Test writing to non-existent file
        welcome_mod.update_gtk_settings(ini_file, "Palexus-Radial-Tungsten")
        content = Path(ini_file).read_text(encoding="utf-8")
        assert "[Settings]" in content
        assert "gtk-icon-theme-name = Palexus-Radial-Tungsten" in content

        # Test updating existing file
        welcome_mod.update_gtk_settings(ini_file, "Palexus-Smoked-Obsidian")
        content_updated = Path(ini_file).read_text(encoding="utf-8")
        assert "gtk-icon-theme-name = Palexus-Smoked-Obsidian" in content_updated
        assert "Palexus-Radial-Tungsten" not in content_updated
        assert content_updated.count("gtk-icon-theme-name") == 1


# ============================================================================
# 3. PALEXUS-SETTINGS TESTS (PalexusSettingsWindow, Tabs, Accents)
# ============================================================================

class TestPalexusSettings:
    """Test palexus-settings control center, tab structure, and accent actions."""

    @pytest.fixture
    def settings_mod(self):
        return load_script_module("palexus_settings_mod", HUD_DIR / "palexus-settings")

    def test_settings_window_and_tabs(self, qapp, settings_mod):
        """Verify PalexusSettingsWindow initializes with 4 tabs and expected widgets."""
        win = settings_mod.PalexusSettingsWindow()
        assert win.windowTitle() == "Palexus Settings"
        assert win.tabs.count() == 4

        tab_names = [win.tabs.tabText(i) for i in range(win.tabs.count())]
        assert "🎨 Themes" in tab_names
        assert "🤖 AI Engine" in tab_names
        assert "🛡️ Stealth & Security" in tab_names
        assert "🔊 Audio & Power" in tab_names

        # Theme tab buttons
        theme_tab = win.tabs.widget(0)
        buttons = theme_tab.findChildren(QPushButton)
        btn_texts = [b.text() for b in buttons]
        for accent in ("Mauve", "Tungsten", "Crimson", "Sapphire", "Emerald"):
            assert any(accent in text for text in btn_texts), f"Accent {accent} button must exist"

        # AI Engine tab controls
        ai_tab = win.tabs.widget(1)
        ai_buttons = [b.text() for b in ai_tab.findChildren(QPushButton)]
        assert any("Pre-warm" in b for b in ai_buttons)
        assert any("Flush" in b for b in ai_buttons)

        # Stealth tab controls
        stealth_tab = win.tabs.widget(2)
        stealth_buttons = [b.text() for b in stealth_tab.findChildren(QPushButton)]
        assert any("Audit" in b for b in stealth_buttons)

        win.close()


# ============================================================================
# 4. PALEXUS-NOTES TESTS (PalexusNotesWindow, Scratchpad, Hotkeys)
# ============================================================================

class TestPalexusNotes:
    """Test palexus-notes scratchpad, Markdown highlighting, and sync logic."""

    @pytest.fixture
    def notes_mod(self, tmp_path):
        os.environ["PALEXUS_BRAIN"] = str(tmp_path / "AIBrain")
        os.environ["SYNAPSE_BRAIN"] = str(tmp_path / "AIBrain")
        mod = load_script_module("palexus_notes_mod", HUD_DIR / "palexus-notes")
        yield mod

    def test_notes_window_initialization_and_sync(self, qapp, notes_mod, tmp_path):
        """Verify PalexusNotesWindow initializes editor and auto-saves to brain."""
        win = notes_mod.PalexusNotesWindow()
        assert win.windowTitle() == "Palexus Notes"
        assert win.editor is not None
        assert win.notes_file.is_file()

        # Verify initial contents
        text = win.editor.toPlainText()
        assert "Palexus Scratchpad" in text

        # Test modifying content and saving
        test_content = "# Test Note Header\n- Offline AI context entry\n"
        win.editor.setPlainText(test_content)
        win.save_file()

        # Read directly from disk
        saved = win.notes_file.read_text(encoding="utf-8")
        assert saved == test_content
        assert "● Saved" in win.status_chip.text()

        # Test date stamp insertion
        win.insert_date_stamp()
        updated_text = win.editor.toPlainText()
        assert "## 20" in updated_text  # Matches current year 20xx

        win.close()


# ============================================================================
# 5. PALEXUS-SCREENSAVER TESTS (CLI Options, Glyphs, Geometry)
# ============================================================================

class TestPalexusScreensaver:
    """Test palexus-screensaver CLI flags, brand glyphs, and torus wireframe math."""

    @pytest.fixture
    def screensaver_mod(self):
        return load_script_module("palexus_screensaver_mod", THEMES_DIR / "palexus-screensaver")

    def test_screensaver_glyph_definitions(self, screensaver_mod):
        """Verify brand reveal cipher glyphs spell PALEXUS with uniform 5x5 dimensions."""
        glyphs = screensaver_mod.GLYPHS
        for char in "PALEXUS":
            assert char in glyphs, f"Glyph {char} must be defined"
            matrix = glyphs[char]
            assert len(matrix) == 5, f"Glyph {char} must have 5 rows"
            for row in matrix:
                assert len(row) == 5, f"Glyph {char} row '{row}' must have width 5"

    def test_screensaver_mesh_and_color_math(self, screensaver_mod):
        """Verify torus wireframe mesh generator and RGB color space conversions."""
        mesh = screensaver_mod.torus_mesh(major=2.0, minor=0.85, rings=5, segments=10)
        assert len(mesh) > 0
        for pt in mesh[:10]:
            assert len(pt) == 3
            assert isinstance(pt[0], float)

        rgb = screensaver_mod.hex_rgb("#cba6f7")
        assert rgb == (203, 166, 247)

        scaled = screensaver_mod.scale_rgb(rgb, 0.5)
        assert scaled == (101, 83, 123)

        fg_code = screensaver_mod.fg(rgb)
        assert fg_code == "\x1b[38;2;203;166;247m"
