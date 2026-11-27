# Performance Baselines

Measured performance of the PalexusOS Python modules, and the budgets that
`scripts/perf_baseline.py --check` enforces.

Every number on this page comes from running that script. Re-measure before
quoting a figure; do not edit numbers by hand.

---

## How to measure

```bash
python scripts/perf_baseline.py               # print medians against budgets
python scripts/perf_baseline.py --with-tests  # also time the full pytest suite
python scripts/perf_baseline.py --check       # exit 1 if any budget is exceeded
python scripts/perf_baseline.py --record      # append to .perf/history.jsonl (git-ignored)
python scripts/perf_baseline.py --json        # machine-readable output
```

Each operation runs once to warm up, then 20 times (`--runs N` to change);
the median is reported. The test suite runs once.

---

## Baseline (2026-11-20, v0.1.1)

Environment: Python 3.13.18, Linux x86_64, 4 vCPU, 16 GB RAM (cloud container).

- `token_load`
  - What it times: `TokenRegistry(tokens.json)` — read, parse, validate
  - Median: 0.02 ms
  - Budget: 50 ms
- `token_access`
  - What it times: `registry.colors()`
  - Median: < 0.01 ms
  - Budget: 1 ms
- `gate_run_all`
  - What it times: `GateRegistry().run(repo_root)`, all 5 gates
  - Median: 0.03 ms
  - Budget: 500 ms
- `desktop_boot`
  - What it times: `DesktopEnvironment().boot()`
  - Median: 0.01 ms
  - Budget: 50 ms
- `test_suite`
  - What it times: `pytest tests/` (166 passed, 8 skipped)
  - Median: ~8 s
  - Budget: 60 s

### Reading these numbers

- **They measure the Python orchestration layer, not the OS.** Boot time,
  ISO build time and desktop latency are not covered here.
- **The gates are fast because they only check that files exist.** All five
  pass in 0.03 ms. When a gate starts doing real work (running `makepkg`,
  building an ISO), its budget must be revisited.
- **`tokens.json` is 2.8 KB.** Token timings say nothing yet about large
  token sets. Measure with a synthetic large file before relying on them for
  v0.3.0 scaling claims.
- **Budgets are generous on purpose.** They catch order-of-magnitude
  regressions (an accidental network call, a quadratic loop), not small drift.
  Tighten them once there is more history.

---

## Budgets

Budgets live in `BUDGETS_MS` at the top of `scripts/perf_baseline.py`. That
dictionary is the single source of truth; this table mirrors it.

| Operation      | Budget  | Why this value                                  |
|----------------|---------|-------------------------------------------------|
| `token_load`   | 50 ms   | Loaded at desktop start; should be imperceptible |
| `token_access` | 1 ms    | Called repeatedly by exporters                  |
| `gate_run_all` | 500 ms  | Runs on every CI job                            |
| `desktop_boot` | 50 ms   | Orchestration only; adapters do the slow work   |
| `test_suite`   | 60 s    | Keeps the pre-push loop short                   |

To change a budget, edit `BUDGETS_MS`, re-run `--check`, and update this
table in the same commit.

---

## Tracking over time

`--record` appends one JSON line per run to `.perf/history.jsonl`:

```json
{"timestamp": "2026-11-20T22:10:04+00:00", "python": "3.13.18", "machine": "x86_64",
 "results_ms": {"token_load": 0.021, "token_access": 0.001, "gate_run_all": 0.03, "desktop_boot": 0.011}}
```

The file is git-ignored: timings depend on the machine, so a shared history
would mix incomparable numbers. Compare runs from the same machine only.

---

## Not measured yet

These matter more than anything above and need their own tooling:

- Cold boot to greeter on real hardware
- ISO build time (`build/`)
- Memory use of the running desktop session
- Local LLM first-token latency in the HUD

---

## See also

- [MAINTENANCE_PLAYBOOK.md](MAINTENANCE_PLAYBOOK.md) — when to run performance checks
- [V0.2.0_IMPLEMENTATION.md](V0.2.0_IMPLEMENTATION.md) — budgets for new modules
- [ROADMAP.md](ROADMAP.md) — v0.3.0 scaling work
