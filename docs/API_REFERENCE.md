# API Reference

The public Python API of the four core modules, as implemented on `main`.
Every signature here was taken from the source; the runnable examples in
[`examples/`](../examples/) exercise all of it and are tested in CI.

```python
from palexus.design.token_registry import TokenRegistry, CSSExporter, ShellExporter, KittyExporter, XFCEExporter
from palexus.build.gate_registry import GateRegistry, GateResult, GateStatus, Gate
from palexus.desktop.environment import DesktopEnvironment, BootContext, BootPhase
from palexus.test.orchestrator import TestOrchestrator, Suite, Result, Level
```

Requires Python 3.11+.

---

## palexus.design — TokenRegistry

### `TokenRegistry(tokens_file: Path)`

Loads and validates a `tokens.json` file at construction.

| Raises | When |
|---|---|
| `FileNotFoundError` | `tokens_file` does not exist |
| `ValueError` | any of `colors`, `typography`, `spacing`, `radius` is missing |
| `json.JSONDecodeError` | the file is not valid JSON |

- `colors(category=None)`
  - Returns: `dict`
  - Notes: All colour groups, or one group (`{}` if the group is unknown)
- `color(category, name)`
  - Returns: `str`
  - Notes: One hex value; `KeyError` if either key is missing
- `typography()`
  - Returns: `dict`
  - Notes: `{"families": ..., "scales": ...}` in the shipped file
- `spacing()`
  - Returns: `dict[str, str]`
  - Notes: Keyed by step: `"1"` → `"4px"` … `"8"` → `"48px"`
- `space(size)`
  - Returns: `str`
  - Notes: One spacing value; `KeyError` if missing
- `radius()`
  - Returns: `dict[str, str]`
  - Notes: `sm`, `md`, `lg`, `xl`
- `shadows()`
  - Returns: `dict[str, str]`
  - Notes: `{}` if the file has none
- `all()`
  - Returns: `dict`
  - Notes: The whole parsed file
- `load()`
  - Returns: `None`
  - Notes: Re-read the file (called by the constructor)
- `validate()`
  - Returns: `None`
  - Notes: Re-check required sections; raises `ValueError`

```python
registry = TokenRegistry(Path("docs/design-system/tokens.json"))
registry.color("primary", "mauve")   # "#cba6f7"
registry.space("4")                  # "16px"
```

### Exporters

Each takes a registry and has one method, `export() -> str`.

| Class | Output |
|---|---|
| `CSSExporter` | `:root { --color-primary-mauve: #cba6f7; ... }` |
| `ShellExporter` | `#!/bin/bash` followed by `export` lines |
| `KittyExporter` | Kitty terminal colour config |
| `XFCEExporter` | XFCE theme colour config |

```python
Path("tokens.css").write_text(CSSExporter(registry).export())
```

---

## palexus.build — GateRegistry

### `GateRegistry()`

Holds the five built-in gates in `registry.gates: dict[str, Gate]`.

- `run(repo_root, selected=None)`
  - Returns: `dict[str, GateResult]`
  - Notes: Runs gates in dependency order. `selected` limits the run to those names; their dependencies are **not** added automatically. Also stored in `registry.results`
- `test(gate_name)`
  - Returns: `bool`
  - Notes: The gate's self-test (checks its definition, not the repo)

When a gate returns `FAILED`, every gate that depends on it, directly or
transitively, is not run and gets `SKIPPED` with the message
`Skipped (dependency failed: <name>)`. A gate that is `SKIPPED` because its
files are pending does not block its dependents.

### `GateResult` (dataclass)

| Field | Type |
|---|---|
| `name` | `str` |
| `status` | `GateStatus`: `PENDING`, `PASSED`, `FAILED`, `SKIPPED` |
| `message` | `str` |
| `duration_ms` | `float` (not populated by the built-in gates) |

### Built-in gates

What each gate checks today. None of them builds or executes anything yet.

- `package`
  - Check: `packages/core/palexus-core/PKGBUILD`, `packages/desktop/llm-quickfire-panel/PKGBUILD` and `packages/desktop/palexus-themes/PKGBUILD` exist
  - Result if missing: `SKIPPED`
- `iso`
  - Depends on: package
  - Check: `build/build-iso.sh` exists
  - Result if missing: `SKIPPED`
- `graphics`
  - Depends on: package
  - Check: `docs/design-system/tokens.json` exists
  - Result if missing: `FAILED`
- `boot`
  - Depends on: iso, graphics
  - Check: `overlay/etc/sysctl.d/99-palexusos.conf` exists
  - Result if missing: `SKIPPED`
- `perf`
  - Depends on: boot
  - Check: nothing: always `PASSED`

### Writing a gate

Subclass `Gate(name, dependencies)` and implement `run(repo_root) -> GateResult`
and `test() -> bool`, then add it to `registry.gates`:

```python
class DocsGate(Gate):
    def __init__(self):
        super().__init__("docs", dependencies={"package"})

    def run(self, repo_root: Path) -> GateResult:
        ok = (repo_root / "README.md").exists()
        return GateResult(self.name, GateStatus.PASSED if ok else GateStatus.FAILED)

    def test(self) -> bool:
        return self.name == "docs"

registry = GateRegistry()
registry.gates["docs"] = DocsGate()
```

---

## palexus.desktop — DesktopEnvironment

### `DesktopEnvironment()`

Owns three adapters (`greeter`, `hud`, `theme`) and a `context: BootContext`.

- `boot()`
  - Returns: `BootContext`
  - Notes: Runs greeter → HUD → theme; returns `self.context`
- `hud_interface()`
  - Returns: `str | None`
  - Notes: `"HUD enabled (phase: …)"`, or `None` if the HUD is disabled
- `theme_loader()`
  - Returns: `Path`
  - Notes: Token file the theme adapter uses
- `set_design_tokens(path)`
  - Returns: `None`
  - Notes: Change that path
- `test_adapters()`
  - Returns: `bool`
  - Notes: All three adapter self-tests
- `reset()`
  - Returns: `None`
  - Notes: Replace the context with a fresh `BootContext()`

### `BootContext` (dataclass)

| Field | Default |
|---|---|
| `selected_user` | `None` |
| `selected_theme` | `None` |
| `hud_enabled` | `True` |
| `phase` | `BootPhase.GREETER` |

Set fields directly before calling `boot()`, for example
`env.context.hud_enabled = False`.

### Boot sequence, as implemented

| Adapter | Acts when phase is | Effect |
|---|---|---|
| Greeter | `GREETER` | `selected_user = "default"`, phase → `HUD` |
| HUD | `HUD` | phase → `THEME`, or → `COMPLETE` if `hud_enabled` is `False` |
| Theme | `THEME` | phase → `COMPLETE` |

The adapters launch no binaries. `BootPhase.USER_SELECT` exists but no
adapter uses it, and no adapter sets `selected_theme`. The theme adapter's
default token path, `docs/design-system/tokens.json`, is relative to the
current directory.

---

## palexus.test — TestOrchestrator

### `TestOrchestrator(repo_root: Path | None = None)`

Aggregates test results into suites and reports on them. **It does not
discover or execute tests**: the `run_*` methods return copies of registered
suites with the results they were registered with. Run tests with `pytest`.

- `register_suite(suite)`
  - Returns: `None`
  - Notes: Keyed by `suite.name`
- `run_all()`
  - Returns: `dict[str, Suite]`
  - Notes: Every registered suite
- `run_level(level)`
  - Returns: `dict[str, Suite]`
  - Notes: Suites with that `Level`; `Level.ALL` matches all
- `run_gate(name)`
  - Returns: `Suite | None`
  - Notes: The suite named `gate_<name>`
- `run_integration()`
  - Returns: `Suite | None`
  - Notes: The suite named `integration`
- `test_specific(suite, test)`
  - Returns: `Result | None`
  - Notes: Look up one recorded result
- `summary()`
  - Returns: `str`
  - Notes: `"Tests: 7 | Passed: 6 | Failed: 1 | Pass rate: 85.7% | Time: 0ms"`, or `"No tests executed"`
- `report_failures()`
  - Returns: `list[str]`
  - Notes: `"<suite>/<test>: <error>"` for each failed result

`summary()` and `report_failures()` cover the most recent `run_*` call.

### `Suite` and `Result` (dataclasses)

```python
Result(name: str, level: Level, passed: bool, duration_ms: float = 0.0, error: str | None = None)
Suite(name: str, level: Level, test_count=0, passed=0, failed=0, duration_ms=0.0, tests: list[Result] = [])
Suite.pass_rate  # property, percentage
```

`Level`: `UNIT`, `GATE`, `INTEGRATION`, `ALL`.

---

## Command line

Installed by `pip install -e .`:

```bash
palexus design [--tokens PATH] list [--format table|json]
palexus design [--tokens PATH] validate
palexus design [--tokens PATH] export {css,shell,kitty,xfce} OUTPUT
palexus build  [--repo-root PATH] list
palexus build  [--repo-root PATH] run [--gates a,b]     # exit 1 if a gate failed
palexus build  [--repo-root PATH] status
palexus test   list | run ...                           # see the TestOrchestrator note
palexus --version
```

`palexus-design`, `palexus-build` and `palexus-test` are aliases for the
three subcommands.
