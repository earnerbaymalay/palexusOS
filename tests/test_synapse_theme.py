"""synapse-theme applies the chosen accent beyond the wallpaper: Kitty, Rofi, Waybar and Sway."""

import os
import shutil
import stat
import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
THEME = REPO_ROOT / "packages" / "desktop" / "synapse-themes" / "synapse-theme"
SKEL = REPO_ROOT / "overlay" / "etc" / "skel" / ".config"

pytestmark = pytest.mark.skipif(shutil.which("bash") is None, reason="needs bash")


def run_theme(tmp_path, *args, sway=False):
    bindir = tmp_path / "bin"
    bindir.mkdir(exist_ok=True)
    log = tmp_path / "swaymsg.log"
    # Stand-ins so the test never touches a real session
    for name, body in {"swaymsg": f'echo "$@" >> "{log}"', "pkill": "exit 1", "notify-send": "exit 0"}.items():
        p = bindir / name
        p.write_text(f"#!/bin/sh\n{body}\n")
        p.chmod(p.stat().st_mode | stat.S_IEXEC)
    env = {
        "PATH": f"{bindir}:/usr/bin:/bin",
        "HOME": str(tmp_path),
        "XDG_CONFIG_HOME": str(tmp_path / "config"),
    }
    if sway:
        env["SWAYSOCK"] = str(tmp_path / "sway.sock")
    proc = subprocess.run(["bash", str(THEME), *args], env=env, capture_output=True, text=True)
    return proc, log


def test_theme_writes_waybar_accent(tmp_path):
    proc, _ = run_theme(tmp_path, "tower-sapphire")
    assert proc.returncode == 0, proc.stderr
    css = (tmp_path / "config" / "waybar" / "theme-colors.css").read_text()
    assert "@define-color accent #74c7ec;" in css
    assert "#74c7ec" in (tmp_path / "config" / "kitty" / "quickfire-colors.conf").read_text()


def test_theme_recolours_sway_borders_in_a_sway_session(tmp_path):
    proc, log = run_theme(tmp_path, "carbon-emerald", sway=True)
    assert proc.returncode == 0, proc.stderr
    calls = log.read_text()
    assert "client.focused #a6e3a1" in calls
    assert "client.urgent #a6e3a1" in calls


def test_restore_falls_back_to_default_theme(tmp_path):
    proc, _ = run_theme(tmp_path, "--restore")
    assert proc.returncode == 0, proc.stderr
    assert (tmp_path / "config" / "synapse" / "theme").read_text().strip() == "monolith-mauve"
    assert "#cba6f7" in (tmp_path / "config" / "waybar" / "theme-colors.css").read_text()


def test_unknown_theme_is_rejected(tmp_path):
    proc, _ = run_theme(tmp_path, "monolith-crimson")
    assert proc.returncode != 0 and "unknown theme" in proc.stderr


def test_waybar_style_uses_the_theme_accent():
    style = (SKEL / "waybar" / "style.css").read_text()
    assert '@import "theme-colors.css";' in style
    assert "@accent" in style
    # Mauve may stay in the header comment, but no rule hard-codes it any more
    rules = "\n".join(line for line in style.splitlines() if not line.lstrip().startswith("*"))
    assert "#cba6f7" not in rules
    # The default shipped to new users must define the colour the stylesheet imports
    assert "@define-color accent #cba6f7;" in (SKEL / "waybar" / "theme-colors.css").read_text()
