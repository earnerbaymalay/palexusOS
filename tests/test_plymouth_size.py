"""Boot 3: the boot animation that lands in every initramfs stays under 8 MB and paces evenly."""

import re
import shutil
import subprocess
from pathlib import Path

import pytest

PLY = Path(__file__).resolve().parent.parent / "packages" / "desktop" / "palexus-plymouth"
PKGBUILD = PLY / "PKGBUILD"
BUDGET = 8 * 1024 * 1024
PLYMOUTH_HZ = 50


def pkgvar(name):
    return re.search(rf"^{name}=(\S+)$", PKGBUILD.read_text(encoding="utf-8"), re.MULTILINE).group(
        1
    )


def test_frame_pacing_is_even_and_smooth():
    ticks = int(pkgvar("_ticks"))
    # A whole number of 50 Hz ticks per frame, and at least 12.5 fps
    assert PLYMOUTH_HZ / ticks >= 12.5
    assert "fps=50/${_ticks}" in PKGBUILD.read_text(encoding="utf-8")


def test_static_budget():
    # Up to 10 s of video (the clip is 8 s today); pal8 PNG of this footage measured at ~0.45 bytes/pixel
    w, h, ticks = int(pkgvar("_width")), int(pkgvar("_height")), int(pkgvar("_ticks"))
    frames = 10 * PLYMOUTH_HZ // ticks
    assert w * h * frames * 0.45 < BUDGET


@pytest.mark.skipif(
    shutil.which("ffmpeg") is None
    or shutil.which("ffprobe") is None
    or shutil.which("bash") is None,
    reason="needs ffmpeg",
)
def test_built_frames_fit_the_budget(tmp_path):
    shutil.copy(PLY / "palexus-boot.mp4", tmp_path)
    # Run the PKGBUILD's own build() so the test measures exactly what ships
    script = f'set -e; source "{PKGBUILD}"; cd "{tmp_path}"; build'
    proc = subprocess.run(
        ["bash", "-c", script], capture_output=True, text=True, timeout=900, check=False
    )
    assert proc.returncode == 0, proc.stderr
    pngs = list((tmp_path / "frames").glob("*.png"))
    frames = [p for p in pngs if p.name.startswith("frame-")]
    total = sum(p.stat().st_size for p in pngs)
    # One frame per tick group for the whole clip, whatever its length
    seconds = float(
        subprocess.run(
            [
                "ffprobe",
                "-v",
                "error",
                "-show_entries",
                "format=duration",
                "-of",
                "csv=p=0",
                str(PLY / "palexus-boot.mp4"),
            ],
            capture_output=True,
            text=True,
            check=True,
        ).stdout
    )
    expected = seconds * PLYMOUTH_HZ / int(pkgvar("_ticks"))
    assert abs(len(frames) - expected) <= 1, (len(frames), expected)
    assert (tmp_path / "frames" / "final.png").exists()
    assert total < BUDGET, f"{total / 1048576:.1f} MB"
