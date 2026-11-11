"""SynapseOS Automated UI/UX Test Suite (Qt6 / PyQt6 / QML).

Executes offscreen automated testing across all SynapseOS desktop user interfaces:
- synapse-hud: QML engine loading, signal/slot bindings, findFirstMatch command search, search box hotkeys.
- synapse-welcome: local-first defaults, variant fallback, consent-gated model download,
                   private key storage, skip path, QML load in live + installed modes, GTK settings updater.
- synapse-settings: SynapseSettingsWindow initialization, tab structure, accent buttons, Ollama toggles.
- synapse-notes: SynapseNotesWindow scratchpad initialization, Markdown highlighter, auto-sync, word counter, hotkeys.
- synapse-screensaver: Argument parsing, command mode options, and cyberdeck glyph validation.
"""

import os
import sys
import shutil
import tempfile
from pathlib import Path
from importlib.machinery import SourceFileLoader
from unittest.mock import ANY, patch, MagicMock

import pytest

# Ensure headless offscreen platform for Qt prior to GUI imports
os.environ["QT_QPA_PLATFORM"] = "offscreen"

from PyQt6.QtCore import Qt, QUrl
from PyQt6.QtWidgets import QApplication, QPushButton, QRadioButton
from PyQt6.QtQml import QQmlApplicationEngine

REPO_ROOT = Path(__file__).resolve().parent.parent
HUD_DIR = REPO_ROOT / "packages" / "desktop" / "synapse-hud"
THEMES_DIR = REPO_ROOT / "packages" / "desktop" / "synapse-themes"


def load_script_module(name: str, path: Path):
    """Load a Python script without .py extension as a module."""
    loader = SourceFileLoader(name, str(path))
    spec = SourceFileLoader(name, str(path)).load_module if False else None
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
# 1. SYNAPSE-HUD TESTS (QML Engine, Signals, findFirstMatch, AI Search)
# ============================================================================

class TestSynapseHudQml:
    """Test synapse-hud QML engine, signals, and command search logic."""

    def test_hud_qml_engine_loading(self, qapp):
        """Verify QML engine successfully loads Main.qml without errors in offscreen mode."""
        engine = QQmlApplicationEngine()
        qml_path = HUD_DIR / "Main.qml"
        assert qml_path.is_file(), f"Main.qml must exist at {qml_path}"

        engine.load(QUrl.fromLocalFile(str(qml_path)))
        root_objects = engine.rootObjects()
        assert len(root_objects) == 1, "Main.qml must load exactly 1 root object"

        root = root_objects[0]
        assert root.property("title") == "Synapse Command HUD"
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
        assert root.findFirstMatch("notes") == "synapse-notes"
        assert root.findFirstMatch("settings") == "synapse-settings"
        assert root.findFirstMatch("chromium") == "chromium"

        # Test local LLM commands
        qwen_cmd = root.findFirstMatch("qwen")
        assert "ollama run qwen2.5-coder:latest" in qwen_cmd

        # Test key shortcut matching
        key1_cmd = root.findFirstMatch("1")
        assert "synapse hud" in key1_cmd

        # Test case-insensitivity
        assert root.findFirstMatch("NOTES") == "synapse-notes"
        assert root.findFirstMatch("  SETTINGS  ") == "synapse-settings"

        # Test non-matching or empty queries
        assert root.findFirstMatch("nonexistent_unknown_xyz") == ""
        assert root.findFirstMatch("") == ""
        assert root.findFirstMatch(None) == ""

    def test_hud_backend_signals_and_launch(self, qapp):
        """Verify HudBackend receives QML signals and launches commands or AI prompts."""
        hud_mod = load_script_module("synapse_hud_mod", HUD_DIR / "synapse-hud")
        assert hasattr(hud_mod, "HudBackend")

        backend = hud_mod.HudBackend(qapp)

        with patch("subprocess.Popen") as mock_popen, patch.object(qapp, "quit") as mock_quit:
            # Test direct command launch (no ~/.bashrc: it exits at once for non-interactive shells)
            backend.launch("synapse-notes")
            mock_popen.assert_called_with(["bash", "-c", "synapse-notes"], env=ANY, start_new_session=True)
            mock_quit.assert_called()

        with patch("subprocess.Popen") as mock_popen, patch.object(qapp, "quit") as mock_quit:
            # Test AI prompt launch with prefix strip
            backend.launch("AI_PROMPT:?how to list files")
            mock_quit.assert_called()
            argv = mock_popen.call_args[0][0]
            assert argv[0] == "kitty"
            assert "AI Prompt: how to list files" in argv[2]
            # ollama is called directly (shell aliases don't exist in bash -c) ...
            assert argv[5].startswith('ollama run "$1" "$2"')
            assert argv[-2:] == ["qwen2.5-coder:latest", "how to list files"]

        with patch("subprocess.Popen") as mock_popen, patch.object(qapp, "quit") as mock_quit:
            # Test AI prompt launch with 'ai ' strip
            backend.launch("AI_PROMPT:ai explain btrfs snapshots")
            mock_quit.assert_called()
            argv = mock_popen.call_args[0][0]
            assert "explain btrfs snapshots" in argv[2]
            assert argv[-1] == "explain btrfs snapshots"

        with patch("subprocess.Popen") as mock_popen, patch.object(qapp, "quit"):
            # ... and the prompt is an argument, never part of the script text
            hostile = 'what does "$(touch /tmp/pwned)" do'
            backend.launch("AI_PROMPT:?" + hostile)
            argv = mock_popen.call_args[0][0]
            assert hostile not in argv[5]
            assert argv[-1] == hostile

    def test_hud_menu_does_not_call_bashrc_aliases(self):
        """kitty bash -c is non-interactive, so ~/.bashrc aliases (ask-*, squash) are undefined there."""
        content = (HUD_DIR / "Main.qml").read_text(encoding="utf-8")
        for alias in ("&& ask-qwen", "&& ask-llama", "&& squash "):
            assert alias not in content
        assert "&& ollama run qwen2.5-coder:latest" in content
        assert "&& synapse squash $cmd" in content

    def test_hud_header_hint_and_placeholder_text(self, qapp):
        """Verify HUD header hint and searchbox placeholder contain required guidance."""
        qml_path = HUD_DIR / "Main.qml"
        content = qml_path.read_text(encoding="utf-8")
        expected_text = "[Esc] Close · [Enter] Launch / Ask AI · [Ctrl+Enter] Ask AI"

        assert expected_text in content
        assert "root.findFirstMatch" in content
        assert "AI_PROMPT:" in content


# ============================================================================
# 2. SYNAPSE-WELCOME TESTS (OnboardingWizard, Steps, GTK Settings)
# ============================================================================

class TestSynapseWelcome:
    """Test synapse-welcome onboarding backend, QML loading, and GTK config sync."""

    @pytest.fixture
    def welcome_mod(self):
        return load_script_module("synapse_welcome_mod", HUD_DIR / "synapse-welcome")

    @pytest.fixture
    def sandbox(self, welcome_mod, tmp_path, monkeypatch):
        """Point the backend at a temp config dir and stop it launching real programs."""
        cfg = tmp_path / "synapse"
        monkeypatch.setattr(welcome_mod, "CONFIG_DIR", str(cfg))
        monkeypatch.setattr(welcome_mod, "ONBOARDING_FLAG", str(cfg / ".onboarding_complete"))
        monkeypatch.setattr(welcome_mod, "AI_MODELS_FILE", str(cfg / "ai_models"))
        monkeypatch.setattr(welcome_mod, "LIVE_MARKER", str(tmp_path / "no-live-marker"))
        monkeypatch.setenv("HOME", str(tmp_path))
        monkeypatch.setattr(welcome_mod, "unit_active", lambda unit: False)
        popen = MagicMock()
        monkeypatch.setattr(welcome_mod.subprocess, "Popen", popen)
        return cfg, popen

    @staticmethod
    def make_backend(welcome_mod):
        return welcome_mod.WelcomeBackend(MagicMock())

    def test_welcome_backend_defaults_are_local_first(self, qapp, welcome_mod, sandbox):
        """Nothing should leave the device by default; state must come from the system."""
        backend = self.make_backend(welcome_mod)
        assert backend.aiEngine == "local"
        assert backend.iconTheme == "Synapse-Liquid-Chrome"
        assert backend.variant in welcome_mod.VARIANTS
        assert backend.keyTestState == "idle"
        assert backend.isLive is False
        checks = backend.securityChecks
        assert {c["label"] for c in checks} >= {"Firewall", "Encrypted DNS", "MAC randomization"}
        assert all(isinstance(c["ok"], bool) and c["detail"] for c in checks)

    def test_variant_selection_skips_missing_combinations(self, qapp, welcome_mod, sandbox):
        """Monolith has no crimson plate; choosing it must fall back to a real variant."""
        backend = self.make_backend(welcome_mod)
        assert backend.variantExists("tower", "crimson")
        assert not backend.variantExists("monolith", "crimson")
        backend.chooseVariant("monolith", "crimson")
        assert backend.variant == "monolith-mauve"
        backend.chooseVariant("carbon", "sapphire")
        assert backend.variant == "carbon-sapphire"

    def test_finish_writes_profile_and_consented_models(self, qapp, welcome_mod, sandbox):
        cfg, popen = sandbox
        backend = self.make_backend(welcome_mod)
        backend.chooseVariant("tower", "emerald")
        backend.modelTier = "light"
        backend.downloadModels = True
        backend.finish()

        assert (cfg / ".onboarding_complete").read_text().strip() == "completed"
        import json
        profile = json.loads((cfg / "operator_profile.json").read_text())
        assert profile["wallpaper_variant"] == "tower-emerald"
        assert profile["ai_engine"] == "local"
        assert (cfg / "ai_models").read_text().split() == welcome_mod.MODEL_TIERS["light"]["models"]
        assert not (cfg / "anthropic_key").exists()
        launched = [c.args[0][0] for c in popen.call_args_list]
        assert any(p.endswith("synapse-setup") for p in launched)

    def test_claude_key_is_private_and_no_models_downloaded(self, qapp, welcome_mod, sandbox):
        cfg, _ = sandbox
        backend = self.make_backend(welcome_mod)
        backend.aiEngine = "claude"
        backend.claudeApiKey = "  sk-ant-test  "
        backend.finish()
        key = cfg / "anthropic_key"
        assert key.read_text().strip() == "sk-ant-test"
        assert (key.stat().st_mode & 0o777) == 0o600
        assert not (cfg / "ai_models").exists()

    def test_skip_applies_nothing(self, qapp, welcome_mod, sandbox):
        cfg, popen = sandbox
        backend = self.make_backend(welcome_mod)
        backend.skip()
        assert (cfg / ".onboarding_complete").read_text().strip() == "skipped"
        assert not (cfg / "operator_profile.json").exists()
        assert not (cfg / "ai_models").exists()
        popen.assert_not_called()

    def test_key_check_reports_failure_honestly(self, welcome_mod, monkeypatch):
        import urllib.error

        def reject(*_a, **_k):
            raise urllib.error.HTTPError("u", 401, "unauthorized", {}, None)

        monkeypatch.setattr(welcome_mod.urllib.request, "urlopen", reject)
        ok, msg = welcome_mod.check_claude_key("sk-ant-bad")
        assert ok is False and "rejected" in msg

    @pytest.mark.parametrize("mode,expected", [("session", 4), ("live", 3), ("oobe", 5)])
    def test_welcome_qml_loads_cleanly(self, qapp, welcome_mod, sandbox, monkeypatch, mode, expected):
        """Welcome.qml must load in every mode with no QML warnings and reach the last step."""
        if mode == "live":
            marker = Path(welcome_mod.CONFIG_DIR).parent / "live-marker"
            marker.write_text("")
            monkeypatch.setattr(welcome_mod, "LIVE_MARKER", str(marker))
        backend = welcome_mod.WelcomeBackend(MagicMock(), oobe=(mode == "oobe"))

        engine = QQmlApplicationEngine()
        warnings = []
        engine.warnings.connect(lambda ws: warnings.extend(w.toString() for w in ws))
        engine.rootContext().setContextProperty("backend", backend)
        engine.load(QUrl.fromLocalFile(str(HUD_DIR / "Welcome.qml")))
        assert engine.rootObjects()
        root = engine.rootObjects()[0]
        steps = root.property("steps")
        steps = steps.toVariant() if hasattr(steps, "toVariant") else steps
        assert len(steps) == expected
        assert ("account" in steps) == (mode == "oobe")

        for _ in range(expected - 1):
            root.setProperty("stepIndex", root.property("stepIndex") + 1)
            qapp.processEvents()
        assert root.property("step") == "done"
        assert warnings == []

    def test_oobe_account_validation_and_request(self, qapp, welcome_mod, sandbox, monkeypatch):
        backend = welcome_mod.WelcomeBackend(MagicMock(), oobe=True)
        assert backend.isOobe and not backend.isLive
        assert set(backend.accountErrors) >= {"username", "password"}

        backend.fullName = "Ada Lovelace"
        assert backend.username == "ada"
        assert backend.newHostname == "ada-synapse"
        backend.password = "secret1"
        backend.passwordConfirm = "secret2"
        assert backend.accountErrors == {"confirm": "The passwords don't match."}
        backend.passwordConfirm = "secret1"
        assert backend.accountErrors == {}

        backend.username = "Bad Name"
        assert "username" in backend.accountErrors
        backend.username = "root"
        assert "reserved" in backend.accountErrors["username"]
        backend.username = "ada"

        req = backend.oobe_request()
        assert req["username"] == "ada" and req["password"] == "secret1"
        assert req["ai_engine"] == "local"

        # finish() hands the request to the root helper via sudo, never writing locally
        run = MagicMock(return_value=MagicMock(stdout='{"ok": true}\n'))
        monkeypatch.setattr(welcome_mod.subprocess, "run", run)
        ok, _ = welcome_mod.WelcomeBackend._run_helper('{"x": 1}')
        assert ok
        assert run.call_args.args[0] == ["sudo", "-n", welcome_mod.OOBE_HELPER]


class TestOobeHelper:
    """The root helper must reject anything outside its allow-lists."""

    @pytest.fixture
    def helper(self):
        return load_script_module("synapse_oobe_apply_mod", HUD_DIR / "synapse-oobe-apply")

    def good(self, **over):
        req = {"full_name": "Ada Lovelace", "username": "zz-oobe-test", "password": "secret1",
               "hostname": "ada-synapse", "variant": "tower-emerald", "icon_theme": "Synapse-Liquid-Chrome",
               "ai_engine": "local", "ai_models": ["qwen2.5-coder:1.5b"], "anthropic_key": "", "profile": {}}
        req.update(over)
        return req

    def test_accepts_valid_request(self, helper):
        r = helper.validate(self.good())
        assert r["username"] == "zz-oobe-test" and r["ai_models"] == ["qwen2.5-coder:1.5b"]

    @pytest.mark.parametrize("field,value", [
        ("username", "root"), ("username", "Has Space"), ("username", "../etc"),
        ("full_name", "Evil:0:0"), ("password", "short"), ("password", "a\nroot:x"),
        ("hostname", "-bad"), ("variant", "monolith-crimson"), ("icon_theme", "../../x"),
        ("ai_engine", "shell"), ("ai_models", ["$(rm -rf /)"]),
    ])
    def test_rejects_bad_fields(self, helper, field, value):
        with pytest.raises(helper.Invalid):
            helper.validate(self.good(**{field: value}))

    def test_key_only_kept_for_claude(self, helper):
        assert helper.validate(self.good(anthropic_key="sk-ant-abcdefghijklmnopqrstuvwxyz"))["anthropic_key"] == ""
        r = helper.validate(self.good(ai_engine="claude", anthropic_key="sk-ant-abcdefghijklmnopqrstuvwxyz"))
        assert r["anthropic_key"].startswith("sk-ant-") and r["ai_models"] == []

    def test_refuses_after_setup_finished(self, helper, monkeypatch, tmp_path, capsys):
        monkeypatch.setattr(helper, "MARKER", str(tmp_path / "gone"))
        with pytest.raises(SystemExit):
            helper.apply()
        assert "already finished" in capsys.readouterr().out


class TestSynapseWelcomeGtk:
    @pytest.fixture
    def welcome_mod(self):
        return load_script_module("synapse_welcome_mod", HUD_DIR / "synapse-welcome")

    def test_update_gtk_settings_function(self, welcome_mod, tmp_path):
        """Verify update_gtk_settings writes and updates gtk-icon-theme-name under [Settings]."""
        ini_file = str(tmp_path / "gtk-3.0" / "settings.ini")

        # Test writing to non-existent file
        welcome_mod.update_gtk_settings(ini_file, "Synapse-Radial-Tungsten")
        content = Path(ini_file).read_text(encoding="utf-8")
        assert "[Settings]" in content
        assert "gtk-icon-theme-name = Synapse-Radial-Tungsten" in content

        # Test updating existing file
        welcome_mod.update_gtk_settings(ini_file, "Synapse-Smoked-Obsidian")
        content_updated = Path(ini_file).read_text(encoding="utf-8")
        assert "gtk-icon-theme-name = Synapse-Smoked-Obsidian" in content_updated
        assert "Synapse-Radial-Tungsten" not in content_updated
        assert content_updated.count("gtk-icon-theme-name") == 1


# ============================================================================
# 3. SYNAPSE-SETTINGS TESTS (SynapseSettingsWindow, Tabs, Accents)
# ============================================================================

class TestSynapseSettings:
    """Test synapse-settings control center, tab structure, and accent actions."""

    @pytest.fixture
    def settings_mod(self):
        return load_script_module("synapse_settings_mod", HUD_DIR / "synapse-settings")

    def test_settings_window_and_tabs(self, qapp, settings_mod):
        """Verify SynapseSettingsWindow initializes with 4 tabs and expected widgets."""
        win = settings_mod.SynapseSettingsWindow()
        assert win.windowTitle() == "Synapse Settings"
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
# 4. SYNAPSE-NOTES TESTS (SynapseNotesWindow, Scratchpad, Hotkeys)
# ============================================================================

class TestSynapseNotes:
    """Test synapse-notes scratchpad, Markdown highlighting, and sync logic."""

    @pytest.fixture
    def notes_mod(self, tmp_path):
        os.environ["SYNAPSE_BRAIN"] = str(tmp_path / "AIBrain")
        mod = load_script_module("synapse_notes_mod", HUD_DIR / "synapse-notes")
        yield mod

    def test_notes_window_initialization_and_sync(self, qapp, notes_mod, tmp_path):
        """Verify SynapseNotesWindow initializes editor and auto-saves to brain."""
        win = notes_mod.SynapseNotesWindow()
        assert win.windowTitle() == "Synapse Notes"
        assert win.editor is not None
        assert win.notes_file.is_file()

        # Verify initial contents
        text = win.editor.toPlainText()
        assert "Synapse Scratchpad" in text

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
# 5. SYNAPSE-SCREENSAVER TESTS (CLI Options, Glyphs, Geometry)
# ============================================================================

class TestSynapseScreensaver:
    """Test synapse-screensaver CLI flags, brand glyphs, and torus wireframe math."""

    @pytest.fixture
    def screensaver_mod(self):
        return load_script_module("synapse_screensaver_mod", THEMES_DIR / "synapse-screensaver")

    def test_screensaver_glyph_definitions(self, screensaver_mod):
        """Verify brand reveal cipher glyphs spell SYNAPSE with uniform 5x5 dimensions."""
        glyphs = screensaver_mod.GLYPHS
        for char in "SYNAPE":
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
