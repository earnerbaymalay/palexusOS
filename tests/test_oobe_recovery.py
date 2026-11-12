"""Text-mode first-boot fallback (palexus-oobe-recovery) and its wiring."""

import importlib.util
import json
import os
import stat
import sys
from importlib.machinery import SourceFileLoader
from pathlib import Path
from unittest.mock import patch

REPO_ROOT = Path(__file__).resolve().parent.parent
HUD_DIR = REPO_ROOT / "packages" / "desktop" / "palexus-hud"


def load(name, path):
    loader = SourceFileLoader(name, str(path))
    spec = importlib.util.spec_from_loader(name, loader)
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    loader.exec_module(mod)
    return mod


recovery = load("palexus_oobe_recovery_mod", HUD_DIR / "palexus-oobe-recovery")
apply_mod = load("palexus_oobe_apply_for_recovery", HUD_DIR / "palexus-oobe-apply")


def test_request_passes_the_helpers_own_validation():
    req = recovery.build_request("ada", "Ada Lovelace", "secret1", "palexusos")
    with patch.object(apply_mod.pwd, "getpwnam", side_effect=KeyError):
        r = apply_mod.validate(req)
    assert r["username"] == "ada" and r["hostname"] == "palexusos"
    assert r["variant"] == "monolith-mauve" and r["ai_models"] == []


def _fake_helper(tmp_path, body):
    script = tmp_path / "fake-apply"
    script.write_text(f"#!/bin/sh\n{body}\n")
    script.chmod(script.stat().st_mode | stat.S_IEXEC)
    return str(script)


def test_password_goes_over_stdin_not_argv(tmp_path):
    seen = tmp_path / "seen"
    helper = _fake_helper(tmp_path, f'echo "$@" > "{seen}.argv"; cat > "{seen}.stdin"; echo \'{{"ok": true}}\'')
    result = recovery.submit(recovery.build_request("ada", "", "secret1", "box"), apply_cmd=helper)
    assert result == {"ok": True}
    assert "secret1" not in Path(f"{seen}.argv").read_text()
    assert json.loads(Path(f"{seen}.stdin").read_text())["password"] == "secret1"


def test_helper_errors_are_reported(tmp_path):
    helper = _fake_helper(tmp_path, 'echo \'{"ok": false, "error": "The username is already taken."}\'')
    assert recovery.submit({}, apply_cmd=helper)["error"] == "The username is already taken."


def test_silent_helper_failure_still_explains(tmp_path):
    helper = _fake_helper(tmp_path, "echo boom >&2; exit 1")
    assert recovery.submit({}, apply_cmd=helper) == {"ok": False, "error": "boom"}


def test_does_nothing_once_setup_is_finished(tmp_path):
    with patch.object(recovery, "MARKER", str(tmp_path / "absent")), \
         patch.object(recovery, "submit") as submit:
        assert recovery.main() == 0
    submit.assert_not_called()


def test_retries_after_an_error_then_finishes(tmp_path, capsys):
    marker = tmp_path / "oobe-pending"
    marker.touch()
    answers = iter(["Root", "", "", "ada", "", ""])
    results = iter([{"ok": False, "error": "Choose a different username."}, {"ok": True}])
    with patch.object(recovery, "MARKER", str(marker)), \
         patch("builtins.input", lambda _p: next(answers)), \
         patch.object(recovery.getpass, "getpass", lambda _p: "secret1"), \
         patch.object(recovery, "submit", lambda _r: next(results)):
        assert recovery.main() == 0
    out = capsys.readouterr().out
    assert "Choose a different username." in out and "Account created." in out


def test_service_and_package_wiring():
    unit = (HUD_DIR / "palexus-oobe-recovery.service").read_text()
    assert "ConditionPathExists=/var/lib/palexus/oobe-pending" in unit
    assert "TTYPath=/dev/tty2" in unit
    pkgbuild = (HUD_DIR / "PKGBUILD").read_text()
    assert "/usr/lib/palexus/palexus-oobe-recovery" in pkgbuild
    assert "/usr/lib/systemd/system/palexus-oobe-recovery.service" in pkgbuild
    assert "systemctl enable palexus-oobe-recovery.service" in (HUD_DIR / "palexus-oobe-arm").read_text()
    assert '"disable", "--now", "palexus-oobe-recovery.service"' in (HUD_DIR / "palexus-oobe-apply").read_text()
