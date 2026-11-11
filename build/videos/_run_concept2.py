
import os
import sys
from pathlib import Path

_THIS_DIR = Path(__file__).resolve().parent
_REPO_ROOT = _THIS_DIR.parent.parent
sys.path.append(str(_THIS_DIR))
import concept2_sovereign_cipher as mod
mod.build_concept_2('PALEXUS')

import bpy
_blend_out = _REPO_ROOT / "docs" / "assets" / "videos" / "palexus_concept2.blend"
_blend_out.parent.mkdir(parents=True, exist_ok=True)
bpy.ops.wm.save_as_mainfile(filepath=str(_blend_out))


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

