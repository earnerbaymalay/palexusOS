"""Boot 2: the HUD and ask-qwen use the qwen2.5-coder model the user has, so no surprise download."""

import shutil
import stat
import subprocess
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
RESOLVER = REPO_ROOT / "packages" / "desktop" / "palexus-hud" / "palexus-code-model"
BASHRC = REPO_ROOT / "overlay" / "etc" / "skel" / ".bashrc"

pytestmark = pytest.mark.skipif(shutil.which("bash") is None, reason="needs bash")


def resolve(tmp_path, installed=None, chosen=None):
    bindir = tmp_path / "bin"
    bindir.mkdir(exist_ok=True)
    if installed is not None:
        lines = "NAME ID SIZE MODIFIED\n" + "".join(f"{m} abc 1GB now\n" for m in installed)
        p = bindir / "ollama"
        p.write_text(f'#!/bin/sh\n[ "$1" = list ] && printf "{lines}"\n')
        p.chmod(p.stat().st_mode | stat.S_IEXEC)
    cfg = tmp_path / "config"
    if chosen is not None:
        (cfg / "palexus").mkdir(parents=True, exist_ok=True)
        (cfg / "palexus" / "ai_models").write_text("\n".join(chosen) + "\n")
    env = {"PATH": f"{bindir}:/usr/bin:/bin", "HOME": str(tmp_path), "XDG_CONFIG_HOME": str(cfg)}
    proc = subprocess.run(
        ["bash", str(RESOLVER)], env=env, capture_output=True, text=True, check=False
    )
    assert proc.returncode == 0, proc.stderr
    return proc.stdout.strip()


def test_light_tier_uses_the_installed_1_5b(tmp_path):
    assert (
        resolve(tmp_path, installed=["llama3.2:latest", "qwen2.5-coder:1.5b"])
        == "qwen2.5-coder:1.5b"
    )


def test_larger_installed_model_wins(tmp_path):
    assert (
        resolve(tmp_path, installed=["qwen2.5-coder:1.5b", "qwen2.5-coder:latest"])
        == "qwen2.5-coder:latest"
    )


def test_wizard_choice_while_download_is_pending(tmp_path):
    chosen = ["nomic-embed-text:latest", "qwen2.5-coder:1.5b", "llama3.2:latest"]
    assert resolve(tmp_path, installed=[], chosen=chosen) == "qwen2.5-coder:1.5b"


def test_ollama_missing_falls_back_to_smallest(tmp_path):
    assert resolve(tmp_path) == "qwen2.5-coder:1.5b"


def test_malformed_choice_is_ignored(tmp_path):
    assert resolve(tmp_path, chosen=["qwen2.5-coder:$(reboot)"]) == "qwen2.5-coder:1.5b"


def test_bashrc_helpers_use_the_resolver():
    text = BASHRC.read_text(encoding="utf-8")
    assert "alias ask-qwen='ask-ollama'" in text
    assert 'model="$(_palexus_code_model)"' in text
    assert "qwen2.5-coder:latest" not in text
