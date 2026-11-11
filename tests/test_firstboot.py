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


def test_live_marker_is_readable_by_the_live_user(welcome):
    # /etc/sudoers.d is 0750 root:root in Arch's sudo package, so a file inside it
    # can never be seen by the unprivileged live user.
    assert not welcome.LIVE_MARKER.startswith("/etc/sudoers.d")
    assert welcome.LIVE_MARKER == "/run/archiso"
