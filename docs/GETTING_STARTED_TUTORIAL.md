# Getting Started: Your First Change

A walk through one complete contribution: adding a colour to the design
system, checking it with the tools, testing it, and getting it past the same
checks CI runs. About 30 minutes.

Every command below was run on the current `main` and produces the output
shown.

---

## 1. Set up (5 min)

```bash
git clone https://github.com/earnerbaymalay/palexusOS.git
cd palexusOS
pip install -e ".[dev]"      # Python 3.11+
pre-commit install           # ruff + black on commit, tests on push
git checkout -b feat/lavender-accent
```

Check everything is green before you change anything:

```bash
python -m pytest tests/ -q
python scripts/health_check.py --quick
```

## 2. See the four modules work (5 min)

Each example runs on its own and prints what the module really does:

```bash
python examples/01_token_registry_example.py      # read tokens, export them
python examples/02_gate_registry_example.py       # quality gates and dependencies
python examples/03_desktop_environment_example.py # boot sequence and context
python examples/04_test_orchestrator_example.py   # aggregate and report results
```

| Module | Job |
|---|---|
| `palexus.design` (`TokenRegistry`) | One source of truth for colours, spacing, type; exporters for CSS, shell, Kitty, XFCE |
| `palexus.build` (`GateRegistry`) | Quality gates run in dependency order |
| `palexus.desktop` (`DesktopEnvironment`) | Greeter → HUD → theme boot sequence |
| `palexus.test` (`TestOrchestrator`) | Collects results into suites and reports on them |

Exact signatures: [API_REFERENCE.md](API_REFERENCE.md).

## 3. Make the change (5 min)

The design tokens live in `docs/design-system/tokens.json`. Add a
`lavender` accent to the `primary` group:

```json
"primary": {
  "mauve": "#cba6f7",
  ...
  "obsidian": "#11111b",
  "lavender": "#b4befe"
}
```

Validate it and look at it:

```bash
$ palexus design validate
✓ Token schema valid

$ palexus design list | grep lavender
  primary.lavender               #b4befe
```

## 4. See where it reaches (5 min)

Export to each target and check for the new colour:

```bash
$ palexus design export css /tmp/tokens.css && grep lavender /tmp/tokens.css
  --color-primary-lavender: #b4befe;

$ palexus design export shell /tmp/tokens.sh && grep -i lavender /tmp/tokens.sh
export COLOR_LAVENDER='#b4befe'

$ palexus design export kitty /tmp/kitty.conf && grep -ci lavender /tmp/kitty.conf
0
```

CSS and shell exports include every colour automatically. The Kitty and XFCE
exporters map specific names (`mauve`, `chrome`, ...) to terminal and window
slots, so a new colour only reaches them if you add it to
`KittyExporter.export()` or `XFCEExporter.export()` in
`palexus/design/token_registry.py`. That is a design decision for the PR
description, not a bug.

## 5. Test it (5 min)

Add a test to `tests/test_design.py` that pins the new token in the real
file:

```python
REPO_TOKENS = Path(__file__).resolve().parent.parent / "docs" / "design-system" / "tokens.json"


def test_lavender_accent_is_exported_to_css():
    registry = TokenRegistry(REPO_TOKENS)
    assert registry.color("primary", "lavender") == "#b4befe"
    assert "--color-primary-lavender: #b4befe;" in CSSExporter(registry).export()
```

(`CSSExporter` is imported from `palexus.design.token_registry`.)

Run it, then the whole suite:

```bash
python -m pytest tests/test_design.py -q
python -m pytest tests/ -q
```

## 6. Run the gates (2 min)

```bash
$ palexus build run
...
Results: 5/5 gates passed
```

The `graphics` gate needs `tokens.json` to exist. The gates check that the
expected files are present; they do not render anything yet.

## 7. Commit and push (3 min)

```bash
git add docs/design-system/tokens.json tests/test_design.py
git commit -m "feat(design): add lavender accent token"
git push -u origin feat/lavender-accent
```

`pre-commit` runs ruff and black on the commit, and the full test suite plus
the performance budgets on the push: the same checks as CI. If a hook fails,
fix what it reports and commit again.

Open a pull request and say in the description whether Kitty and XFCE
should get the colour too.

---

## Where next

- [CONTRIBUTION_LADDER.md](CONTRIBUTION_LADDER.md): pick a task at your level
- [DEVELOPER_HANDBOOK.md](DEVELOPER_HANDBOOK.md): add a gate, a boot phase or a token type
- [design/ARCHITECTURE.md](design/ARCHITECTURE.md): how the modules fit together
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md): when something fails
