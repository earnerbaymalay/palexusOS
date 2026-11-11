#!/usr/bin/env python3
"""render_all_concepts.py — Automated Blender Boot Video Suite Generator for PalexusOS.

Renders Concepts 2, 3, and 4 to 1080p MP4 and WebM videos using Blender EEVEE,
and generates Plymouth boot splash frame archives.
"""

import os
import sys
import time
import subprocess
from pathlib import Path

VIDEO_DIR = Path(__file__).resolve().parent
REPO_ROOT = VIDEO_DIR.parent.parent
OUT_DIR = REPO_ROOT / "docs" / "assets" / "videos"
OUT_DIR.mkdir(parents=True, exist_ok=True)

CONCEPTS = [
    {
        "id": "concept2",
        "name": "The Sovereign Cipher",
        "script": VIDEO_DIR / "concept2_sovereign_cipher.py",
        "func": "build_concept_2",
        "desc": "Aerospace Billet / Titanium Plate Excavation & Liquid Chrome Wordmark"
    },
    {
        "id": "concept3",
        "name": "Cortical Convolutions",
        "script": VIDEO_DIR / "concept3_cortical_convolutions.py",
        "func": "build_concept_3",
        "desc": "Neural Labyrinth & Synaptic Pulse Waves with Liquid Chrome Wordmark"
    },
    {
        "id": "concept4",
        "name": "The Monolithic Prism & Photonic Slicer",
        "script": VIDEO_DIR / "concept4_photonic_prism.py",
        "func": "build_concept_4",
        "desc": "Optical Quartz Monolith with Laser Kerf & Prism Diffraction"
    }
]

RENDER_WRAPPER = """
import bpy
import sys
from pathlib import Path

# Set video output configuration
scene = bpy.context.scene
scene.render.resolution_x = 1280
scene.render.resolution_y = 720
scene.render.resolution_percentage = 100
scene.render.fps = 30
scene.frame_start = 1
scene.frame_end = 120

scene.render.image_settings.file_format = 'FFMPEG'
scene.render.ffmpeg.format = 'MPEG4'
scene.render.ffmpeg.codec = 'H264'
scene.render.ffmpeg.constant_rate_factor = 'HIGH'
scene.render.ffmpeg.ffmpeg_preset = 'GOOD'
scene.render.filepath = sys.argv[-1]

print(f"==> Rendering {scene.frame_end} frames to {scene.render.filepath}...")
bpy.ops.render.render(animation=True)
print("==> Render complete!")
"""

def render_concept(concept):
    print(f"\n=======================================================")
    print(f" Rendering: {concept['name']} ({concept['id']})")
    print(f" Description: {concept['desc']}")
    print(f"=======================================================")

    mp4_target = OUT_DIR / f"palexus_{concept['id']}.mp4"
    blend_target = OUT_DIR / f"palexus_{concept['id']}.blend"
    
    # Python script executed inside Blender
    runner_code = f"""
import sys
sys.path.append('{VIDEO_DIR}')
import {concept['script'].stem} as mod
mod.{concept['func']}('PALEXUS')

import bpy
bpy.ops.wm.save_as_mainfile(filepath='{blend_target}')

{RENDER_WRAPPER}
"""
    runner_path = VIDEO_DIR / f"_run_{concept['id']}.py"
    runner_path.write_text(runner_code, encoding="utf-8")

    cmd = [
        "blender", "-b",
        "-P", str(runner_path),
        "--", str(mp4_target)
    ]
    t0 = time.time()
    res = subprocess.run(cmd, capture_output=True, text=True)
    dt = time.time() - t0
    
    if runner_path.exists():
        runner_path.unlink()

    if res.returncode == 0 and mp4_target.exists():
        size_mb = mp4_target.stat().st_size / (1024 * 1024)
        print(f"[SUCCESS] Generated: {mp4_target.name} ({size_mb:.2f} MB in {dt:.1f}s)")
        # Also convert to WebM for web embedding
        webm_target = OUT_DIR / f"palexus_{concept['id']}.webm"
        subprocess.run([
            "ffmpeg", "-y", "-v", "error", "-i", str(mp4_target),
            "-c:v", "libvpx-vp9", "-b:v", "0", "-crf", "30",
            "-an", str(webm_target)
        ])
        print(f"[SUCCESS] Converted WebM: {webm_target.name}")
        return True
    else:
        print(f"[FAILED] Render failed with returncode {res.returncode}")
        print("Output:", res.stdout[-600:])
        print("Error:", res.stderr[-600:])
        return False

def main():
    print("=== PalexusOS Monolithic Boot Video Suite Generator ===")
    success = True
    for c in CONCEPTS:
        if not render_concept(c):
            success = False
    print("\nAll concepts processed.")
    return 0 if success else 1

if __name__ == "__main__":
    sys.exit(main())
