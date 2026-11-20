# Integration Guide

Recipes for using the PalexusOS modules from another project or pipeline.
Each recipe was run against the current `main`. Signatures:
[API_REFERENCE.md](API_REFERENCE.md).

---

## Install

`palexus` is not on PyPI. Install from GitHub, pinned to a commit on `main`:

```bash
pip install "palexus @ git+https://github.com/earnerbaymalay/palexusOS@<commit-sha>"
```

Do not pin to `v0.1.1` or earlier tags: they predate the packaging fix and do
not build from git. Pin to a commit until the next release is tagged.

```bash
python -c "import palexus.design.token_registry, palexus.build.gate_registry; print('ok')"
palexus --version
```

Requires Python 3.11+. The package has no runtime dependencies.

---

## Recipe 1: Generate CSS variables for a web app

Keep the app's CSS in step with the PalexusOS palette by generating it at
build time instead of copying hex values.

```bash
palexus design --tokens path/to/tokens.json export css src/styles/tokens.css
```

```css
/* src/styles/app.css */
@import "tokens.css";

.button {
  background: var(--color-primary-mauve);
  color: var(--color-surface-900);
}
```

CSS names follow `--color-<group>-<name>`, so `colors.primary.mauve` becomes
`--color-primary-mauve`. Wire the command into the app's build (a `prebuild`
npm script, a Makefile rule) so the file is regenerated, not edited.

From Python instead:

```python
from pathlib import Path
from palexus.design.token_registry import CSSExporter, TokenRegistry

registry = TokenRegistry(Path("path/to/tokens.json"))
Path("src/styles/tokens.css").write_text(CSSExporter(registry).export())
```

---

## Recipe 2: Theme shell scripts and terminals

```bash
palexus design export shell ~/.config/palexus/colors.sh
palexus design export kitty ~/.config/kitty/palexus.conf
```

```bash
# in a script
source ~/.config/palexus/colors.sh
printf 'accent is %s\n' "$COLOR_MAUVE"
```

```conf
# ~/.config/kitty/kitty.conf
include palexus.conf
```

The shell export includes every colour as `COLOR_<NAME>`. The Kitty and XFCE
exports use a fixed set of names (`mauve`, `chrome`, ...); a new colour only
reaches them if the exporter maps it.

---

## Recipe 3: Run the gates in CI

`palexus build run` exits 1 when a gate fails, so it can be a CI step as is:

```yaml
# .github/workflows/gates.yml
name: Gates
on: [push, pull_request]
jobs:
  gates:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
      - run: pip install -e .
      - run: palexus build run
```

Run a subset with `palexus build run --gates package,graphics`. Only the named
gates run; their dependencies are not added automatically.

The built-in gates check that the expected PalexusOS files exist, so they are
meaningful in this repository or a fork of it. For another project, write
your own gates (next recipe).

---

## Recipe 4: Your own gates

A gate is a `Gate` subclass with dependencies and a `run(repo_root)` method.
The registry orders gates and skips everything downstream of a failure.

```python
from pathlib import Path

from palexus.build.gate_registry import Gate, GateRegistry, GateResult, GateStatus


class ReadmeGate(Gate):
    """README exists."""

    def __init__(self):
        super().__init__("readme")

    def run(self, repo_root: Path) -> GateResult:
        if (repo_root / "README.md").exists():
            return GateResult(self.name, GateStatus.PASSED)
        return GateResult(self.name, GateStatus.FAILED, "README.md missing")

    def test(self) -> bool:
        return self.name == "readme"


class ChangelogGate(Gate):
    """CHANGELOG exists; only worth checking once the README does."""

    def __init__(self):
        super().__init__("changelog", dependencies={"readme"})

    def run(self, repo_root: Path) -> GateResult:
        ok = (repo_root / "CHANGELOG.md").exists()
        return GateResult(self.name, GateStatus.PASSED if ok else GateStatus.FAILED)

    def test(self) -> bool:
        return self.name == "changelog"


registry = GateRegistry()
registry.gates = {"readme": ReadmeGate(), "changelog": ChangelogGate()}  # replace the built-ins
results = registry.run(Path("."))
failed = [name for name, r in results.items() if r.status == GateStatus.FAILED]
raise SystemExit(1 if failed else 0)
```

To add to the built-in gates instead of replacing them, assign a single key:
`registry.gates["readme"] = ReadmeGate()`.

---

## Recipe 5: Report results from your own checks

`TestOrchestrator` does not run tests; it aggregates results into suites and
produces a summary and a failure list. Use it when you have several kinds of
checks and want one report.

```python
from palexus.test.orchestrator import Level, Result, Suite, TestOrchestrator


def suite(name: str, level: Level, checks: dict[str, bool]) -> Suite:
    tests = [Result(n, level, ok, error=None if ok else "failed") for n, ok in checks.items()]
    passed = sum(t.passed for t in tests)
    return Suite(name, level, len(tests), passed, len(tests) - passed, tests=tests)


orchestrator = TestOrchestrator()
orchestrator.register_suite(suite("lint", Level.UNIT, {"ruff": True, "black": True}))
orchestrator.register_suite(suite("gates", Level.GATE, {"readme": True, "changelog": False}))
orchestrator.run_all()
print(orchestrator.summary())          # Tests: 4 | Passed: 3 | Failed: 1 | ...
print(orchestrator.report_failures())  # ['gates/changelog: failed']
```

---

## Recipe 6: Drive the boot sequence from an installer

`DesktopEnvironment` holds the boot state in a `BootContext` dataclass. Set
fields before `boot()`; read them after.

```python
from palexus.desktop.environment import BootPhase, DesktopEnvironment

env = DesktopEnvironment()
env.context.hud_enabled = ask_user("Enable the AI HUD?")   # your prompt
env.set_design_tokens(Path("/usr/share/palexus/tokens.json"))
context = env.boot()
assert context.phase == BootPhase.COMPLETE
```

Today the adapters only move the context through its phases (the greeter
sets the user to `"default"`); they do not launch the greeter or HUD
binaries. Treat this as the place to hang that logic, not as a working
greeter.

---

## Pitfalls

| Problem | Cause and fix |
|---|---|
| `FileNotFoundError: Tokens file not found` | Paths are relative to the current directory. Pass an absolute path or `--tokens`. |
| A gate you selected ran without its dependency | `selected` runs only the named gates. Include the dependencies in the list. |
| `ValueError: Circular dependency detected` | Two gates depend on each other; break the cycle. |
| `palexus: command not found` after install | The console scripts install into the environment's `bin/`; activate that environment. |
| Colour missing from the Kitty or XFCE export | Those exporters map fixed names; see Recipe 2. |
