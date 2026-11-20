# PalexusOS Examples

One runnable script per core module. Each one uses only the real public API,
and `tests/test_examples.py` runs all of them in CI, so they cannot drift.

```bash
pip install -e .
python examples/01_token_registry_example.py   # works from any directory
```

| Script | Module | Shows |
|---|---|---|
| `01_token_registry_example.py` | `palexus.design` | Reading colours, spacing, radius and typography; exporting to CSS, shell, Kitty and XFCE; the errors for a missing or incomplete `tokens.json` |
| `02_gate_registry_example.py` | `palexus.build` | Gate dependencies; running all or selected gates; how one failure skips everything that depends on it; gate self-tests |
| `03_desktop_environment_example.py` | `palexus.desktop` | The boot sequence and `BootContext`; booting with the HUD off; pointing the theme loader at a token file; resetting between sessions |
| `04_test_orchestrator_example.py` | `palexus.test` | Recording results in suites, then `run_all`, `run_level`, `summary` and `report_failures` |

## What the modules do today

The examples print what the code really does, including its current limits:

- **Gates** check that the expected files exist; they do not build packages
  or ISOs yet.
- **Boot adapters** advance the phase and fill in the context without
  launching the greeter or HUD binaries. The greeter sets the user to
  `"default"` and skips the `USER_SELECT` phase; no adapter sets a theme.
- **TestOrchestrator** aggregates results you give it; it does not discover
  or run tests. Use `pytest` to run the suite.

## Adding an example

1. Name it `NN_topic_example.py` so the test picks it up.
2. Resolve paths from `Path(__file__)`, not the current directory: the test
   runs each example from a temporary directory.
3. Exit with status 0 and print something. That is all the test checks, so
   make the output show the behaviour you are explaining.
