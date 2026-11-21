# Quick Reference

Commands and calls you will use most. Full details: [API_REFERENCE.md](API_REFERENCE.md).

---

## Set up

```bash
git clone https://github.com/earnerbaymalay/palexusOS.git
cd palexusOS
pip install -e ".[dev]"        # Python 3.11+
pre-commit install             # optional: ruff + black on commit, tests on push
```

## Everyday commands

| Task | Command |
|---|---|
| Run all tests | `make test` or `python -m pytest tests/ -q` |
| Run one module's tests | `make test-design` / `make test-build` / `make test-desktop` |
| Run one test | `python -m pytest tests/test_build.py::TestGateRegistry::test_topological_sort -v` |
| Lint exactly as CI does | `ruff check palexus/ tests/ --extend-ignore=E501` |
| Format exactly as CI does | `black palexus/ tests/ --line-length=100` |
| Run every pre-commit hook | `pre-commit run --all-files` |
| Health check | `python scripts/health_check.py --quick` (or without `--quick` for everything) |
| Performance budgets | `python scripts/perf_baseline.py --check` |
| Build a wheel | `make build` |
| All `make` targets | `make help` |

## Command line

```bash
palexus design validate
palexus design list
palexus design export css out/tokens.css        # also: shell, kitty, xfce
palexus build list
palexus build run                               # exit 1 if any gate failed
palexus build run --gates package,iso
palexus --version
```

## TokenRegistry

```python
from pathlib import Path
from palexus.design.token_registry import TokenRegistry, CSSExporter

registry = TokenRegistry(Path("docs/design-system/tokens.json"))
registry.colors()                    # {"primary": {...}, "surface": {...}, ...}
registry.colors("primary")           # one group
registry.color("primary", "mauve")   # "#cba6f7"
registry.space("4")                  # "16px"
registry.radius(), registry.typography(), registry.shadows()

Path("tokens.css").write_text(CSSExporter(registry).export())
# ShellExporter, KittyExporter, XFCEExporter work the same way
```

## GateRegistry

```python
from pathlib import Path
from palexus.build.gate_registry import GateRegistry, GateStatus

results = GateRegistry().run(Path("."))            # dict[name, GateResult]
results = GateRegistry().run(Path("."), selected=["package"])
for name, result in results.items():
    print(name, result.status.value, result.message)
failed = [n for n, r in results.items() if r.status == GateStatus.FAILED]
```

A failed gate skips everything that depends on it.

## DesktopEnvironment

```python
from palexus.desktop.environment import DesktopEnvironment, BootPhase

env = DesktopEnvironment()
env.context.hud_enabled = False      # configure before booting
context = env.boot()                 # greeter -> HUD -> theme
context.phase == BootPhase.COMPLETE
context.selected_user                # "default" (set by the greeter adapter)
env.reset()                          # fresh context for the next session
```

## TestOrchestrator

Aggregates results you record; it does not run tests (use pytest for that).

```python
from palexus.test.orchestrator import TestOrchestrator, Suite, Result, Level

orch = TestOrchestrator()
orch.register_suite(Suite("smoke", Level.UNIT, test_count=1, passed=1,
                          tests=[Result("imports", Level.UNIT, passed=True)]))
orch.run_all()
print(orch.summary())                # "Tests: 1 | Passed: 1 | ..."
print(orch.report_failures())        # []
```

## Common problems

| Symptom | Fix |
|---|---|
| `ModuleNotFoundError: palexus` | `pip install -e .` from the repo root |
| `pip` refuses to install | Python older than 3.11; check `python --version` |
| `FileNotFoundError: Tokens file not found` | Pass an absolute path, or run from the repo root |
| CI lint fails but local passes | Local ruff/black differ from CI's pins (ruff 0.17.6, black 26.10.1); use `pre-commit run --all-files` |
| `palexus: command not found` | Re-run `pip install -e .` so the console scripts are installed |

## Where things are

```
palexus/            Python core modules (design, build, desktop, test) and the CLI
tests/              pytest suite, including tests/test_examples.py
examples/           One runnable script per module
scripts/            health_check.py, perf_baseline.py, ISO and token tooling
packages/           Arch PKGBUILDs
build/              archiso profile and build scripts
overlay/            Files installed into the live system (/etc, /usr/share, skel)
docs/               Guides; design/ holds ARCHITECTURE.md and design notes
```

## Documentation map

| Need | Read |
|---|---|
| Install | [INSTALL.md](../INSTALL.md) |
| First steps as a developer | [QUICKSTART.md](../QUICKSTART.md) |
| How the modules fit together | [design/ARCHITECTURE.md](design/ARCHITECTURE.md) |
| Exact signatures | [API_REFERENCE.md](API_REFERENCE.md) |
| Domain vocabulary | [CONTEXT.md](../CONTEXT.md), [GLOSSARY.md](GLOSSARY.md) |
| Contributing | [CONTRIBUTING.md](../CONTRIBUTING.md), [CONTRIBUTION_LADDER.md](CONTRIBUTION_LADDER.md) |
| Upgrading | [MIGRATION.md](MIGRATION.md) |
| Performance numbers | [PERFORMANCE_BASELINES.md](PERFORMANCE_BASELINES.md) |
| Something is broken | [TROUBLESHOOTING.md](TROUBLESHOOTING.md) |
| Design decisions | [adr/](adr/) |
