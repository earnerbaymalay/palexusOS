"""Every script in examples/ must run to completion.

The examples are documentation that executes; this keeps them in step with
the real module APIs.
"""

import os
import subprocess
import sys
from pathlib import Path

import pytest

REPO_ROOT = Path(__file__).resolve().parent.parent
EXAMPLES = sorted((REPO_ROOT / "examples").glob("[0-9]*.py"))


def test_examples_exist():
    assert EXAMPLES


@pytest.mark.parametrize("example", EXAMPLES, ids=lambda p: p.name)
def test_example_runs(example, tmp_path):
    # Run from an unrelated directory: examples must not depend on the cwd. Put the repo on
    # PYTHONPATH so they import palexus even where it isn't pip-installed (the ISO gate job
    # runs pytest from pipx).
    env = dict(os.environ)
    env["PYTHONPATH"] = os.pathsep.join(filter(None, [str(REPO_ROOT), env.get("PYTHONPATH")]))
    result = subprocess.run(
        [sys.executable, str(example)],
        cwd=tmp_path,
        env=env,
        capture_output=True,
        text=True,
        timeout=60,
        check=False,
    )
    assert result.returncode == 0, result.stderr[-2000:]
    assert result.stdout.strip()
