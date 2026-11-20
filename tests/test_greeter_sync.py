"""L7: changing theme also updates the login screen, via one polkit prompt; cancelling is harmless."""

import os
import shutil
import stat
import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
THEMES = REPO_ROOT / "packages" / "desktop" / "palexus-themes"
THEME = THEMES / "palexus-theme"
HELPER = THEMES / "palexus-greeter-sync"

pytestmark = pytest.mark.skipif(shutil.which("bash") is None, reason="needs bash")


def make_stub(bindir, name, body):
    p = bindir / name
    p.write_text(f"#!/bin/sh\n{body}\n")
    p.chmod(p.stat().st_mode | stat.S_IEXEC)


def run_theme(tmp_path, *args, pkexec_exit=0, greeter_installed=True, current=None):
    bindir = tmp_path / "bin"
    bindir.mkdir(exist_ok=True)
    pk_log = tmp_path / "pkexec.log"
    notify_log = tmp_path / "notify.log"
    greeter_dir = tmp_path / "sddm" / "palexusos"
    if greeter_installed:
        greeter_dir.mkdir(parents=True, exist_ok=True)
    conf = greeter_dir / "theme.conf.user"
    if current:
        conf.write_text(f"[General]\nvariant={current}\n")
    # pkexec stand-in records the call, then succeeds (writing like the helper) or
    # exits 126 like a dismissed password dialog
    make_stub(bindir, "pkexec",
              f'echo "$@" >> "{pk_log}"\n'
              f'[ {pkexec_exit} -eq 0 ] || exit {pkexec_exit}\n'
              f'printf "[General]\nvariant=%s\n" "$2" > "{conf}"')
    make_stub(bindir, "notify-send", f'echo "$@" >> "{notify_log}"')
    make_stub(bindir, "pkill", "exit 1")
    helper = tmp_path / "palexus-greeter-sync"
    helper.write_text("#!/bin/sh\nexit 0\n")
    helper.chmod(0o755)
    env = {
        "PATH": f"{bindir}:/usr/bin:/bin",
        "HOME": str(tmp_path),
        "XDG_CONFIG_HOME": str(tmp_path / "config"),
        "PALEXUS_GREETER_CONF": str(conf),
        "PALEXUS_GREETER_SYNC": str(helper),
    }
    proc = subprocess.run(["bash", str(THEME), *args], env=env, capture_output=True, text=True)
    read = lambda p: p.read_text() if p.exists() else ""
    return proc, read(pk_log), read(notify_log), read(conf)


def test_theme_change_syncs_greeter_with_one_prompt(tmp_path):
    proc, pk, _, conf = run_theme(tmp_path, "tower-emerald")
    assert proc.returncode == 0, proc.stderr
    assert pk.splitlines() == [f"{tmp_path / 'palexus-greeter-sync'} tower-emerald"]
    assert "variant=tower-emerald" in conf


def test_cancelled_prompt_keeps_desktop_theme_and_explains(tmp_path):
    proc, pk, notes, conf = run_theme(tmp_path, "carbon-sapphire", pkexec_exit=126, current="monolith-mauve")
    assert proc.returncode == 0, proc.stderr
    assert pk.strip()
    # Desktop switched, login screen kept its old look, and the user is told how to retry
    assert (tmp_path / "config" / "palexus" / "theme").read_text().strip() == "carbon-sapphire"
    assert "variant=monolith-mauve" in conf
    assert "--sync-greeter" in notes


def test_no_prompt_when_greeter_already_matches(tmp_path):
    proc, pk, _, _ = run_theme(tmp_path, "tower-crimson", current="tower-crimson")
    assert proc.returncode == 0, proc.stderr
    assert pk == ""


def test_restore_at_login_never_prompts(tmp_path):
    proc, pk, _, _ = run_theme(tmp_path, "--restore", current="tower-crimson")
    assert proc.returncode == 0, proc.stderr
    assert pk == ""


def test_no_prompt_without_greeter_installed(tmp_path):
    proc, pk, _, _ = run_theme(tmp_path, "tower-sapphire", greeter_installed=False)
    assert proc.returncode == 0, proc.stderr
    assert pk == ""


def test_explicit_sync_reports_cancel(tmp_path):
    proc, _, _, _ = run_theme(tmp_path, "--sync-greeter", "tower-sapphire", pkexec_exit=126)
    assert proc.returncode != 0


as_user = pytest.mark.skipif(hasattr(os, "geteuid") and os.geteuid() == 0,
                             reason="the helper ignores PALEXUS_SYSROOT as root")


def run_helper(tmp_path, theme_id):
    root = tmp_path / "root"
    walls = root / "usr/share/backgrounds/palexusos"
    walls.mkdir(parents=True, exist_ok=True)
    for wp in THEMES.glob("palexus-*.jpg"):
        (walls / wp.name).write_bytes(b"")
    (root / "usr/share/sddm/themes/palexusos").mkdir(parents=True, exist_ok=True)
    proc = subprocess.run(["bash", str(HELPER), theme_id], env={"PATH": "/usr/bin:/bin", "PALEXUS_SYSROOT": str(root)},
                          capture_output=True, text=True)
    conf = root / "usr/share/sddm/themes/palexusos/theme.conf.user"
    return proc, conf


@as_user
def test_helper_writes_only_the_variant(tmp_path):
    proc, conf = run_helper(tmp_path, "carbon-emerald")
    assert proc.returncode == 0, proc.stderr
    assert conf.read_text() == "[General]\nvariant=carbon-emerald\n"
    assert oct(conf.stat().st_mode & 0o777) == "0o644"


@pytest.mark.parametrize("bad", ["monolith-crimson", "../../etc/passwd", "tower-mauve\nuser=root", ""])
@as_user
def test_helper_rejects_anything_but_a_real_theme(tmp_path, bad):
    proc, conf = run_helper(tmp_path, bad)
    assert proc.returncode != 0
    assert not conf.exists()
