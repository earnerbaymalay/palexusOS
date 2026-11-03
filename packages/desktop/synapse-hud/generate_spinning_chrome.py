#!/usr/bin/env python3
"""
SynapseOS — Authentic 3D Liquid Chrome Spinning Logo Generator.
Extracts the poured 3D chrome emblem from the master plate with smooth alpha transparency,
centers it squarely, enhances metallic specular reflections, and renders a 360-degree
spinning loop (animated GIF & 32-bit WebP + master transparent PNG).
"""

import sys
import numpy as np
from pathlib import Path
from PIL import Image, ImageEnhance

def generate_spinning_chrome():
    script_dir = Path(__file__).resolve().parent
    master_candidates = [
        script_dir / "master_plate_960.png",
        script_dir / "../synapse-plymouth/master_plate_960.png",
        script_dir / "../../desktop/synapse-plymouth/master_plate_960.png",
    ]
    master_path = None
    for p in master_candidates:
        if p.is_file():
            master_path = p
            break

    if not master_path:
        print("Error: master_plate_960.png not found!")
        sys.exit(1)

    print(f"Loading master plate from: {master_path}")
    src = Image.open(master_path).convert("RGB")
    arr = np.array(src, dtype=np.float32)

    # 1. Background color of the master plate is #11111b (17, 17, 27)
    bg = np.array([17.0, 17.0, 27.0], dtype=np.float32)
    diff = np.max(np.abs(arr - bg), axis=-1)

    # 2. Smooth antialiased alpha matting (eliminates black halo borders)
    alpha = np.clip((diff - 8.0) / 18.0, 0.0, 1.0)

    # 3. Soft spatial window around the poured 3D chrome logo
    h, w = arr.shape[:2]
    yy, xx = np.mgrid[0:h, 0:w]
    mask_y = np.clip(1.0 - (np.abs(yy - 260.0) - 100.0) / 25.0, 0.0, 1.0)
    mask_x = np.clip(1.0 - (np.abs(xx - 480.0) - 260.0) / 30.0, 0.0, 1.0)
    window = mask_y * mask_x
    final_alpha = alpha * window

    # 4. Create RGBA composite
    rgba = np.zeros((h, w, 4), dtype=np.uint8)
    rgba[..., :3] = np.clip(arr, 0, 255).astype(np.uint8)
    rgba[..., 3] = (final_alpha * 255.0).astype(np.uint8)
    img_rgba = Image.fromarray(rgba, "RGBA")

    # 5. Crop tightly to logo bounds
    bbox = img_rgba.getbbox()
    cropped = img_rgba.crop(bbox)
    print(f"Isolated poured 3D chrome emblem size: {cropped.size}")

    # 6. Enhance specular highlights & chrome contrast
    enhancer = ImageEnhance.Contrast(cropped)
    cropped = enhancer.enhance(1.12)
    enhancer = ImageEnhance.Sharpness(cropped)
    cropped = enhancer.enhance(1.15)

    # 7. Center onto square canvas (512x512) for perfect symmetrical in-place 360 rotation
    diag = int(np.hypot(cropped.width, cropped.height)) + 32
    canvas_size = max(512, diag)
    canvas = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
    paste_x = (canvas_size - cropped.width) // 2
    paste_y = (canvas_size - cropped.height) // 2
    canvas.paste(cropped, (paste_x, paste_y), cropped)

    # Save high-res master square PNG
    still_out = script_dir / "synapse_chrome_logo.png"
    canvas.save(still_out, optimize=True)
    print(f"Saved master isolated logo: {still_out}")

    # 8. Render 60-frame 360-degree rotation loop
    num_frames = 60
    base_res = canvas.resize((256, 256), Image.Resampling.LANCZOS)
    frames = []

    for i in range(num_frames):
        angle = (i * 360.0) / num_frames
        rot = base_res.rotate(-angle, resample=Image.Resampling.BICUBIC)
        frames.append(rot)

    # Animated GIF
    gif_out = script_dir / "synapse_chrome_spin_360.gif"
    frames[0].save(
        gif_out,
        save_all=True,
        append_images=frames[1:],
        duration=33, # ~30fps smooth loop
        loop=0,
        disposal=2,
        transparency=0
    )
    print(f"Saved animated 360 GIF: {gif_out} ({gif_out.stat().st_size} bytes)")

    # Animated WebP (32-bit alpha lossless)
    webp_out = script_dir / "synapse_chrome_spin_360.webp"
    frames[0].save(
        webp_out,
        save_all=True,
        append_images=frames[1:],
        duration=33,
        loop=0,
        lossless=True
    )
    print(f"Saved animated 360 WebP: {webp_out} ({webp_out.stat().st_size} bytes)")

if __name__ == "__main__":
    generate_spinning_chrome()
