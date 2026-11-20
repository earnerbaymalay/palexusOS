# Migration Guide

What changes between PalexusOS releases, and what you need to do.

Sections for released versions describe changes that have shipped. Sections
for unreleased versions describe what the [v0.2.0 plan](V0.2.0_IMPLEMENTATION.md)
intends; treat them as subject to change until the release is tagged.

---

## Stability policy

- **v0.x**: a public API may change in a minor release (0.1 → 0.2). It is
  deprecated for at least one minor release first, with a `DeprecationWarning`
  naming the replacement.
- **Patch releases** (0.1.0 → 0.1.1) never change public APIs.
- **v1.0 onward**: semantic versioning; breaking changes only in a major release.

"Public API" means names importable from `palexus.design`, `palexus.build`,
`palexus.desktop` and `palexus.test` that do not start with `_`.

---

## Unreleased (current `main`) — from v0.1.1

### Python 3.11 or newer is required

`pyproject.toml` now sets `requires-python = ">=3.11"`, and CI tests 3.11
through 3.14. Python 3.9 and 3.10 are no longer supported.

**What to do**

```bash
python --version          # must print 3.11 or higher
pip install -e .          # pip refuses to install on older interpreters
```

Arch Linux and current Fedora/Ubuntu ship 3.11+ already. On older systems,
install a newer interpreter (for example with `pyenv`) before upgrading.

### Type hints use built-in generics

Signatures changed from `Optional[Path]` / `Dict[str, Any]` to
`Path | None` / `dict[str, Any]`. Runtime behaviour is identical; only code
that introspects annotations as strings will see a difference.

**What to do:** nothing, unless you parse annotations.

---

## v0.1.0 → v0.1.1

Documentation-only release. No code or API changes.

**What to do:** nothing.

---

## v0.1.x → v0.2.0 (planned)

v0.2.0 is planned as additive: new modules and new optional methods, with
the existing calls below unchanged.

### Stays the same

```python
TokenRegistry(tokens_file)                 # same constructor
registry.colors() / .typography() / .spacing() / .radius() / .shadows()
GateRegistry().run(repo_root, selected=None)   # returns dict[str, GateResult]
DesktopEnvironment().boot()                # returns BootContext
TestOrchestrator(repo_root).run_all()      # returns dict[str, Suite]
```

### New (opt-in)

| Addition | Where | Notes |
|---|---|---|
| `ThemeManager` | `palexus.design.theme_manager` | Multiple token sets with priority merging |
| `VariableRegistry` | `palexus.core.variable_registry` | New `palexus.core` package |
| Token references `{"ref": "blue/500"}` | `tokens.json` | Plain values keep working |
| Localised copy and RTL metadata | `tokens.json` | Optional new sections |
| Gate plugins | entry point group `palexus.gates` | Built-in gates unchanged |
| `palexus` command | console script | Thin wrapper over the modules |

### Possible breaking change: token references

If a token value in your `tokens.json` is already an object containing a
`ref` key, v0.2.0 would treat it as a reference. Check now:

```bash
python - <<'PY'
import json
def walk(node, path=""):
    if isinstance(node, dict):
        if "ref" in node:
            print("would become a reference:", path)
        for key, value in node.items():
            walk(value, f"{path}/{key}")
walk(json.load(open("docs/design-system/tokens.json")))
PY
```

No output means you are unaffected.

---

## Checking an upgrade

After any upgrade:

```bash
pip install -e .
python -m pytest tests/ -q
python scripts/health_check.py --quick
python scripts/perf_baseline.py --check
```

All four should succeed. If a test you wrote against the old API fails, look
for a `DeprecationWarning` in the output: it names the replacement.
