"""First-boot setup and live-session behaviour (synapse-welcome, synapse-oobe-*)."""

import importlib.util
import sys
from importlib.machinery import SourceFileLoader
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
HUD_DIR = REPO_ROOT / "packages" / "desktop" / "synapse-hud"


def load(name, path):
    loader = SourceFileLoader(name, str(path))
    spec = importlib.util.spec_from_loader(name, loader)
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    loader.exec_module(mod)
    return mod


@pytest.fixture(scope="module")
def welcome():
    pytest.importorskip("PyQt6")
    return load("synapse_welcome_firstboot", HUD_DIR / "synapse-welcome")


@pytest.fixture
def oobe_apply(tmp_path, monkeypatch):
    mod = load("synapse_oobe_apply_firstboot", HUD_DIR / "synapse-oobe-apply")
    marker = tmp_path / "oobe-pending"
    marker.touch()
    monkeypatch.setattr(mod, "MARKER", str(marker))
    return mod


def _run_apply(mod, monkeypatch, capsys, request):
    import io
    import json
    monkeypatch.setattr(mod.sys, "stdin", io.StringIO(json.dumps(request)))
    with pytest.raises(SystemExit):
        mod.apply()
    return json.loads(capsys.readouterr().out.strip().splitlines()[-1])


REQUEST = {"username": "ada", "password": "secret1", "hostname": "synapse", "full_name": ""}


def test_failed_setup_removes_the_half_made_account(oobe_apply, monkeypatch, capsys):
    import subprocess
    accounts = set()
    removed = []

    def fake_getpwnam(name):
        if name in accounts:
            return type("pw", (), {"pw_uid": 1000, "pw_gid": 1000, "pw_dir": "/home/" + name})()
        raise KeyError(name)

    def fake_run(*cmd, stdin=None):
        if cmd[0] == "useradd":
            accounts.add(cmd[-1])
        if cmd[0] == "chpasswd":
            raise subprocess.CalledProcessError(1, list(cmd), stderr="chpasswd: PAM failure")

    def fake_subprocess_run(cmd, **kw):
        if cmd[:3] == ["userdel", "-r", "-f"]:
            removed.append(cmd[3])
            accounts.discard(cmd[3])
        return subprocess.CompletedProcess(cmd, 0)

    monkeypatch.setattr(oobe_apply.pwd, "getpwnam", fake_getpwnam)
    monkeypatch.setattr(oobe_apply, "run", fake_run)
    monkeypatch.setattr(oobe_apply, "group_exists", lambda g: False)
    monkeypatch.setattr(oobe_apply.subprocess, "run", fake_subprocess_run)

    result = _run_apply(oobe_apply, monkeypatch, capsys, REQUEST)
    assert result["ok"] is False and "chpasswd" in result["error"]
    assert removed == ["ada"]
    # The same name is free again, so the retry is not rejected as "already taken"
    assert "ada" not in accounts


def test_validation_failure_touches_no_account(oobe_apply, monkeypatch, capsys):
    called = []
    monkeypatch.setattr(oobe_apply.subprocess, "run", lambda cmd, **kw: called.append(cmd))
    result = _run_apply(oobe_apply, monkeypatch, capsys, {**REQUEST, "username": "Root!"})
    assert result["ok"] is False
    assert not any(c[0] == "userdel" for c in called)


def _fake(tmp_path, name, body):
    path = tmp_path / name
    path.write_text(f"#!/bin/sh\n{body}\n")
    path.chmod(0o755)
    return str(path)


def _run_wizard(tmp_path, welcome_body):
    import os
    import subprocess
    marker = tmp_path / "oobe-pending"
    marker.touch()
    log = tmp_path / "log"
    env = dict(os.environ,
               SYNAPSE_OOBE_MARKER=str(marker),
               SYNAPSE_WELCOME=_fake(tmp_path, "welcome", f'echo welcome >> "{log}"; {welcome_body}'),
               SWAYNAG=_fake(tmp_path, "swaynag", f'echo "nag $*" >> "{log}"'),
               SWAYMSG=_fake(tmp_path, "swaymsg", f'echo "msg $*" >> "{log}"'))
    subprocess.run(["bash", str(HUD_DIR / "synapse-oobe-wizard")], env=env, check=True, timeout=20)
    return log.read_text().splitlines()


def test_crashing_wizard_is_retried_then_points_to_text_setup(tmp_path):
    lines = _run_wizard(tmp_path, "exit 1")
    assert lines.count("welcome") == 3
    nag = [line for line in lines if line.startswith("nag ")]
    assert nag and "Ctrl+Alt+F2" in nag[0]
    assert lines[-1] == "msg exit"


def test_finished_setup_runs_the_wizard_once_and_shows_no_warning(tmp_path):
    lines = _run_wizard(tmp_path, f'rm -f "{tmp_path / "oobe-pending"}"')
    assert lines == ["welcome", "msg exit"]


def test_setup_compositor_uses_the_retrying_runner():
    conf = (HUD_DIR / "oobe-sway.conf").read_text()
    assert "exec /usr/lib/synapse/synapse-oobe-wizard" in conf
    assert "/usr/lib/synapse/synapse-oobe-wizard" in (HUD_DIR / "PKGBUILD").read_text()


def test_live_marker_is_readable_by_the_live_user(welcome):
    # /etc/sudoers.d is 0750 root:root in Arch's sudo package, so a file inside it
    # can never be seen by the unprivileged live user.
    assert not welcome.LIVE_MARKER.startswith("/etc/sudoers.d")
    assert welcome.LIVE_MARKER == "/run/archiso"
