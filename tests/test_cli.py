"""Tests for the palexus command-line entry points."""

from pathlib import Path

import pytest

from palexus import cli
from palexus.build import cli as build_cli
from palexus.design import cli as design_cli

REPO_ROOT = Path(__file__).resolve().parent.parent
TOKENS = REPO_ROOT / "docs" / "design-system" / "tokens.json"


class TestDesignCLI:
    def test_validate(self, capsys):
        assert design_cli.main(["--tokens", str(TOKENS), "validate"]) == 0
        assert "valid" in capsys.readouterr().out

    @pytest.mark.parametrize("fmt", ["css", "shell", "kitty", "xfce"])
    def test_export_writes_file(self, tmp_path, fmt):
        out = tmp_path / f"tokens.{fmt}"
        assert design_cli.main(["--tokens", str(TOKENS), "export", fmt, str(out)]) == 0
        assert out.read_text().strip()

    def test_export_css_contains_accent(self, tmp_path):
        out = tmp_path / "tokens.css"
        design_cli.main(["--tokens", str(TOKENS), "export", "css", str(out)])
        assert "#cba6f7" in out.read_text()

    def test_list_shows_color_values(self, capsys):
        assert design_cli.main(["--tokens", str(TOKENS), "list"]) == 0
        out = capsys.readouterr().out
        assert "primary.mauve" in out
        assert "#cba6f7" in out

    def test_missing_tokens_file(self, tmp_path, capsys):
        assert design_cli.main(["--tokens", str(tmp_path / "none.json"), "validate"]) == 1
        assert "not found" in capsys.readouterr().err


class TestBuildCLI:
    def test_list_shows_all_gates(self, capsys):
        assert build_cli.main(["list"]) == 0
        out = capsys.readouterr().out
        for gate in ("package", "iso", "graphics", "boot", "perf"):
            assert gate in out

    def test_run_all(self, capsys):
        assert build_cli.main(["--repo-root", str(REPO_ROOT), "run"]) == 0
        assert "5/5" in capsys.readouterr().out

    def test_run_selected(self, capsys):
        assert build_cli.main(["--repo-root", str(REPO_ROOT), "run", "--gates", "package"]) == 0
        out = capsys.readouterr().out
        assert "package" in out
        assert "1/1" in out

    def test_run_unknown_gate(self, capsys):
        assert build_cli.main(["--repo-root", str(REPO_ROOT), "run", "--gates", "nope"]) == 1
        assert "unknown gate" in capsys.readouterr().err

    def test_run_fails_when_a_gate_fails(self, tmp_path, capsys):
        # An empty repo root makes the graphics gate fail.
        assert build_cli.main(["--repo-root", str(tmp_path), "run"]) == 1
        assert "gate(s) failed" in capsys.readouterr().out

    def test_status(self, capsys):
        assert build_cli.main(["--repo-root", str(REPO_ROOT), "status"]) == 0
        assert "package" in capsys.readouterr().out


class TestUnifiedCLI:
    def test_no_args_prints_help(self, capsys):
        assert cli.main([]) == 0
        assert "design" in capsys.readouterr().out

    def test_dispatches_to_design(self, capsys):
        assert cli.main(["design", "--tokens", str(TOKENS), "validate"]) == 0
        assert "valid" in capsys.readouterr().out

    def test_dispatches_to_build(self, capsys):
        assert cli.main(["build", "list"]) == 0
        assert "package" in capsys.readouterr().out

    def test_version(self, capsys):
        assert cli.main(["--version"]) == 0
        assert capsys.readouterr().out.strip()

    def test_unknown_command(self, capsys):
        assert cli.main(["nope"]) == 2
