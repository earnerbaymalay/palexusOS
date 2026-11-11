#!/usr/bin/env python3
"""
PalexusOS — Authentic 4D Liquid Chrome Plate & 360° Right-to-Left Spatial Engine.
Architected for military-grade cyberdeck hardware aesthetics:
1. Floating Chamfered Obsidian Glass / Chrome Metallic Plate
2. Extruded Physical Rim / Depth with CNC Milled Chamfers & Gunmetal Titanium Edges
3. Front Face: Authentically Embossed Liquid Chrome Emblem with Specular Highlights & Shimmer
4. Reverse Face: Symmetrical Classified Cyberdeck Neural Motherboard & Silicon NPU Die
5. 4D Hyper-Dimensional Tesseract Wireframe Aura rotating across the 4th spatial dimension
6. Continuous 360-degree rotation from RIGHT TO LEFT with 50mm perspective projection
7. Outputs studio-grade 512x512 / 1024x1024 assets without jagged or cropped artifacts.
"""

import sys
import math
import numpy as np
from pathlib import Path
from PIL import Image, ImageDraw, ImageEnhance, ImageFilter

def create_chamfered_mask(w, h, c):
    """Generate high-precision antialiased chamfered mask."""
    # Render at 4x resolution and downscale for perfect supersampled antialiasing
    scale = 4
    sw, sh, sc = w * scale, h * scale, c * scale
    mask = Image.new("L", (sw, sh), 0)
    draw = ImageDraw.Draw(mask)
    points = [
        (sc, 0),
        (sw - sc, 0),
        (sw, sc),
        (sw, sh - sc),
        (sw - sc, sh),
        (sc, sh),
        (0, sh - sc),
        (0, sc)
    ]
    draw.polygon(points, fill=255)
    return mask.resize((w, h), Image.Resampling.LANCZOS)

def build_front_plate(plate_w, plate_h, emblem_img):
    """Build luxury front obsidian plate with embossed liquid chrome emblem."""
    # Obsidian glass gradient base
    front = Image.new("RGBA", (plate_w, plate_h), (0, 0, 0, 0))
    base = Image.new("RGBA", (plate_w, plate_h), (13, 13, 21, 255))
    
    # Subtle dark brushed sheen & gradient
    draw = ImageDraw.Draw(base)
    for y in range(plate_h):
        fac = y / float(plate_h)
        r = int(12 + fac * 12)
        g = int(12 + fac * 14)
        b = int(18 + fac * 22)
        draw.line([(0, y), (plate_w, y)], fill=(r, g, b, 255))
    
    # 45-degree corner chamfer mask (c = 22)
    chamfer = create_chamfered_mask(plate_w, plate_h, 22)
    base.putalpha(chamfer)
    
    # Milled inner perimeter border & corner brackets
    border_layer = Image.new("RGBA", (plate_w, plate_h), (0, 0, 0, 0))
    bdraw = ImageDraw.Draw(border_layer)
    # Double precision chamfer line
    c = 22
    pts_outer = [
        (c, 2), (plate_w - c, 2), (plate_w - 2, c),
        (plate_w - 2, plate_h - c), (plate_w - c, plate_h - 2),
        (c, plate_h - 2), (2, plate_h - c), (2, c)
    ]
    bdraw.polygon(pts_outer, outline=(203, 166, 247, 180), width=1) # Catppuccin Mauve hairline
    
    c_in = 18
    inset = 8
    pts_inner = [
        (inset + c_in, inset), (plate_w - inset - c_in, inset), (plate_w - inset, inset + c_in),
        (plate_w - inset, plate_h - inset - c_in), (plate_w - inset - c_in, plate_h - inset),
        (inset + c_in, plate_h - inset), (inset, plate_h - inset - c_in), (inset, inset + c_in)
    ]
    bdraw.polygon(pts_inner, outline=(116, 199, 236, 120), width=1) # Sapphire inner hairline
    
    # Technical markings & optical registration ticks
    bdraw.text((inset + 12, inset + 4), "PALEXUS // OB-4D PLATE", fill=(147, 153, 178, 190))
    bdraw.text((plate_w - inset - 88, inset + 4), "SYS-CORE 01", fill=(203, 166, 247, 210))
    bdraw.text((inset + 12, plate_h - inset - 14), "SPECULAR LIQUID CHROME", fill=(108, 112, 134, 160))
    bdraw.text((plate_w - inset - 72, plate_h - inset - 14), "[VERIFIED]", fill=(166, 227, 161, 200))
    
    # Optical corner crosshair registration ticks
    for cx, cy in [(14, 14), (plate_w - 14, 14), (14, plate_h - 14), (plate_w - 14, plate_h - 14)]:
        bdraw.line([(cx - 4, cy), (cx + 4, cy)], fill=(205, 214, 244, 220), width=1)
        bdraw.line([(cx, cy - 4), (cx, cy + 4)], fill=(205, 214, 244, 220), width=1)
    
    # Composite layers
    front = Image.alpha_composite(base, border_layer)
    
    # Emboss authentic liquid chrome emblem
    ew, eh = emblem_img.size
    target_w = int(plate_w * 0.76)
    target_h = int(target_w * (eh / float(ew)))
    scaled_emblem = emblem_img.resize((target_w, target_h), Image.Resampling.LANCZOS)
    
    # Drop soft metallic ambient occlusion under the emblem
    ao_layer = Image.new("RGBA", (plate_w, plate_h), (0, 0, 0, 0))
    ao_mask = scaled_emblem.split()[3].filter(ImageFilter.GaussianBlur(8))
    ao_color = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 180))
    ao_layer.paste(ao_color, ((plate_w - target_w) // 2 + 2, (plate_h - target_h) // 2 + 4), ao_mask)
    front = Image.alpha_composite(front, ao_layer)
    
    # Stamp chrome emblem
    front.paste(scaled_emblem, ((plate_w - target_w) // 2, (plate_h - target_h) // 2), scaled_emblem)
    
    return front

def build_reverse_plate(plate_w, plate_h):
    """Build luxury reverse face: authentic classified cyberdeck neural motherboard & NPU."""
    rev = Image.new("RGBA", (plate_w, plate_h), (11, 11, 17, 255))
    draw = ImageDraw.Draw(rev)
    
    # Chamfer mask
    chamfer = create_chamfered_mask(plate_w, plate_h, 22)
    rev.putalpha(chamfer)
    
    # Dark carbon / ceramic background grid
    for x in range(0, plate_w, 16):
        draw.line([(x, 0), (x, plate_h)], fill=(18, 18, 28, 255), width=1)
    for y in range(0, plate_h, 16):
        draw.line([(0, y), (plate_w, y)], fill=(18, 18, 28, 255), width=1)
        
    # High-density gold and cyan printed circuit bus traces
    cx, cy = plate_w // 2, plate_h // 2
    
    # Symmetrical bus lines
    gold = (250, 179, 135, 230)      # Catppuccin Tungsten / Gold trace
    cyan = (116, 199, 236, 210)      # Sapphire signal trace
    mauve = (203, 166, 247, 220)     # Mauve power trace
    silver = (205, 214, 244, 200)    # Silver data trace
    
    # Bus traces radiating outward from central NPU die
    die_w, die_h = 130, 90
    
    # Draw horizontal differential pairs
    for offset_y in [-32, -24, -16, 16, 24, 32]:
        y_pos = cy + offset_y
        col = gold if offset_y < 0 else cyan
        # Left traces
        draw.line([(24, y_pos), (cx - die_w//2 - 16, y_pos)], fill=col, width=1)
        draw.line([(cx - die_w//2 - 16, y_pos), (cx - die_w//2, cy + offset_y * 0.7)], fill=col, width=1)
        # Right traces
        draw.line([(cx + die_w//2, cy + offset_y * 0.7), (cx + die_w//2 + 16, y_pos)], fill=col, width=1)
        draw.line([(cx + die_w//2 + 16, y_pos), (plate_w - 24, y_pos)], fill=col, width=1)
        
        # Micro via pads
        draw.ellipse([20, y_pos - 2, 24, y_pos + 2], fill=silver)
        draw.ellipse([plate_w - 24, y_pos - 2, plate_w - 20, y_pos + 2], fill=silver)
        
    # Vertical memory bus traces
    for offset_x in [-44, -30, -16, 16, 30, 44]:
        x_pos = cx + offset_x
        draw.line([(x_pos, 20), (x_pos, cy - die_h//2 - 10)], fill=mauve, width=1)
        draw.line([(x_pos, cy + die_h//2 + 10), (x_pos, plate_h - 20)], fill=silver, width=1)
        draw.ellipse([x_pos - 2, 18, x_pos + 2, 22], fill=gold)
        draw.ellipse([x_pos - 2, plate_h - 22, x_pos + 2, plate_h - 18], fill=cyan)
        
    # Micro SMD capacitor arrays
    for bx in [cx - die_w//2 - 28, cx + die_w//2 + 22]:
        for by in range(cy - 36, cy + 36, 12):
            draw.rectangle([bx, by, bx + 6, by + 4], fill=(147, 153, 178, 240), outline=(205, 214, 244, 255))
            
    # Central Neural Processing Unit (NPU Die)
    die_rect = [cx - die_w//2, cy - die_h//2, cx + die_w//2, cy + die_h//2]
    # Gold ground ring
    draw.rectangle([die_rect[0] - 4, die_rect[1] - 4, die_rect[2] + 4, die_rect[3] + 4],
                   outline=gold, width=2)
    # Silicon die body
    draw.rectangle(die_rect, fill=(24, 24, 37, 255), outline=silver, width=1)
    
    # Internal silicon neural core markings
    draw.text((cx - 48, cy - 28), "PALEXUS NPU", fill=mauve)
    draw.text((cx - 52, cy - 14), "1024-TFLOPS BORE", fill=cyan)
    draw.text((cx - 56, cy + 2), "TENSOR MATRIX ACCEL", fill=gold)
    draw.text((cx - 42, cy + 18), "SEC-LEVEL 0", fill=(166, 227, 161, 240))
    
    # Corner hex mounting sockets & military hardware stamp
    for hx, hy in [(24, 24), (plate_w - 24, 24), (24, plate_h - 24), (plate_w - 24, plate_h - 24)]:
        draw.ellipse([hx - 6, hy - 6, hx + 6, hy + 6], fill=(18, 18, 28), outline=silver, width=1)
        draw.ellipse([hx - 3, hy - 3, hx + 3, hy + 3], fill=(49, 50, 68))
        
    draw.text((28, plate_h - 16), "CLASSIFIED HARDWARE // MIL-SPEC CYBERDECK MOTHERBOARD", fill=(108, 112, 134, 200))
    
    return rev

def project_point(x, y, z, theta, pitch, d_cam, cx, cy):
    """Rotate point in 3D (Y-axis right-to-left + pitch forward) and perspective project."""
    # 1. Horizontal Y-axis rotation (right to left):
    # A point at +X moves toward camera (+Z) and sweeps left (-X)
    xr = x * math.cos(theta) - z * math.sin(theta)
    zr = x * math.sin(theta) + z * math.cos(theta)
    yr = y
    
    # 2. Camera pitch (tilt down slightly ~9.5 deg so top chamfer and depth are always visible)
    yp = yr * math.cos(pitch) - zr * math.sin(pitch)
    zp = yr * math.sin(pitch) + zr * math.cos(pitch)
    xp = xr
    
    # 3. Perspective projection
    factor = d_cam / (d_cam + zp)
    sx = cx + xp * factor
    sy = cy + yp * factor
    return sx, sy, zp

def render_4d_tesseract_aura(draw, theta, pitch, d_cam, cx, cy):
    """
    Render 4D hypercube (tesseract) wireframe rotating across 4D spatial dimensions.
    16 vertices (±1, ±1, ±1, ±1) rotating in X-W and Y-W 4D planes.
    """
    scale_4d = 185.0
    phi_xw = theta
    psi_yw = theta * 0.5
    
    v4 = []
    for x in (-1, 1):
        for y in (-0.75, 0.75):
            for z in (-0.45, 0.45):
                for w in (-0.8, 0.8):
                    # 4D rotation in X-W plane
                    x4 = x * math.cos(phi_xw) - w * math.sin(phi_xw)
                    w4 = x * math.sin(phi_xw) + w * math.cos(phi_xw)
                    # 4D rotation in Y-W plane
                    y4 = y * math.cos(psi_yw) - w4 * math.sin(psi_yw)
                    w4 = y * math.sin(psi_yw) + w4 * math.cos(psi_yw)
                    z4 = z
                    
                    # 4D to 3D perspective projection
                    denom = 2.4 - (w4 / 1.5)
                    s = scale_4d / denom
                    v4.append((x4 * s, y4 * s, z4 * s))
                    
    # Project 16 3D points to 2D screen
    pts_2d = []
    for x3, y3, z3 in v4:
        sx, sy, zp = project_point(x3, y3, z3, theta, pitch, d_cam, cx, cy)
        pts_2d.append((sx, sy, zp))
        
    # 32 edges of the 4D tesseract
    edges = []
    num_v = len(v4)
    for i in range(num_v):
        for j in range(i + 1, num_v):
            diff = sum(1 for a, b in zip(
                (i & 1, (i >> 1) & 1, (i >> 2) & 1, (i >> 3) & 1),
                (j & 1, (j >> 1) & 1, (j >> 2) & 1, (j >> 3) & 1)
            ) if a != b)
            if diff == 1:
                edges.append((i, j))
                
    # Draw laser vector lines
    for i, j in edges:
        p1, p2 = pts_2d[i], pts_2d[j]
        avg_z = (p1[2] + p2[2]) * 0.5
        # Depth fading: closer is brighter
        alpha = int(np.clip(130 - avg_z * 0.35, 25, 170))
        color = (203, 166, 247, alpha) if (i % 2 == 0) else (116, 199, 236, alpha)
        draw.line([(p1[0], p1[1]), (p2[0], p2[1])], fill=color, width=1)
        
    # Draw glowing hyper-vertex nodes
    for p in pts_2d:
        alpha = int(np.clip(160 - p[2] * 0.4, 40, 220))
        draw.ellipse([p[0] - 2, p[1] - 2, p[0] + 2, p[1] + 2], fill=(255, 255, 255, alpha))

def extract_master_emblem(master_path):
    """Extract uncropped, pristine 3D liquid chrome emblem without jagged cuts."""
    src = Image.open(master_path).convert("RGB")
    arr = np.array(src, dtype=np.float32)
    bg = np.array([17.0, 17.0, 27.0], dtype=np.float32)
    diff = np.max(np.abs(arr - bg), axis=-1)
    
    # Precision antialiased alpha matting
    alpha = np.clip((diff - 6.0) / 16.0, 0.0, 1.0)
    
    # Exclude top nozzle gracefully (smooth ramp between Y=110 and Y=125)
    alpha[:110, :] = 0.0
    alpha[110:125, :] *= np.linspace(0.0, 1.0, 15)[:, None]
    
    # Soft horizontal bounds around the liquid chrome typography (X from 190 to 765)
    h, w = arr.shape[:2]
    xx = np.arange(w, dtype=np.float32)[None, :]
    wx = np.clip(1.0 - (np.abs(xx - 480.0) - 275.0) / 25.0, 0.0, 1.0)
    alpha *= wx
    
    rgba = np.zeros((h, w, 4), dtype=np.uint8)
    rgba[..., :3] = np.clip(arr, 0, 255).astype(np.uint8)
    rgba[..., 3] = (alpha * 255.0).astype(np.uint8)
    emblem_raw = Image.fromarray(rgba, "RGBA")
    
    # Tight bounding box of the whole emblem
    bbox = emblem_raw.getbbox()
    cropped = emblem_raw.crop(bbox)
    print(f"Pristine extracted chrome emblem bounds: {bbox}, size: {cropped.size}")
    
    # Studio lighting enhancement: chrome specular contrast & clarity
    enhancer = ImageEnhance.Contrast(cropped)
    cropped = enhancer.enhance(1.15)
    enhancer = ImageEnhance.Sharpness(cropped)
    cropped = enhancer.enhance(1.18)
    
    return cropped

def warp_face(face_img, p_tl, p_tr, p_br, p_bl, out_size):
    """Warp textured face quad onto perspective polygon."""
    fw, fh = face_img.size
    # Map (p_tl, p_tr, p_br, p_bl) to source rectangle
    # PIL transform QUAD takes (x0, y0, x1, y1, x2, y2, x3, y3) as destination corners
    # in order: top-left, bottom-left, bottom-right, top-right
    try:
        quad = (
            p_tl[0], p_tl[1],
            p_bl[0], p_bl[1],
            p_br[0], p_br[1],
            p_tr[0], p_tr[1]
        )
        return face_img.transform(
            out_size,
            Image.Transform.QUAD,
            quad,
            resample=Image.Resampling.BILINEAR
        )
    except Exception as e:
        return Image.new("RGBA", out_size, (0, 0, 0, 0))

def main():
    script_dir = Path(__file__).resolve().parent
    master_candidates = [
        script_dir / "master_plate_960.png",
        script_dir / "../palexus-plymouth/master_plate_960.png",
        script_dir / "../../desktop/palexus-plymouth/master_plate_960.png",
        Path("/usr/share/palexusos/branding/master_plate_960.png"),
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
    emblem = extract_master_emblem(master_path)
    
    # Save standalone master emblem on high-res 512x512 canvas
    logo_canvas = Image.new("RGBA", (512, 512), (0, 0, 0, 0))
    paste_x = (512 - emblem.width) // 2
    paste_y = (512 - emblem.height) // 2
    logo_canvas.paste(emblem, (paste_x, paste_y), emblem)
    logo_out = script_dir / "palexus_chrome_logo.png"
    logo_canvas.save(logo_out, optimize=True)
    print(f"Saved master uncropped emblem: {logo_out}")
    
    # Build 3D Plate Faces: Front (Obsidian + Chrome) and Reverse (Cyberdeck Motherboard)
    plate_w, plate_h = 440, 310
    half_w, half_h = plate_w / 2.0, plate_h / 2.0
    half_t = 12.0 # Extruded physical depth / thickness
    
    front_face = build_front_plate(plate_w, plate_h, emblem)
    reverse_face = build_reverse_plate(plate_w, plate_h)
    
    # Setup 3D Canvas & Camera
    canvas_size = 512
    cx, cy = canvas_size / 2.0, canvas_size / 2.0
    d_cam = 720.0
    pitch = math.radians(11.0) # Forward tilt reveals top chamfer & physical plate depth
    
    num_frames = 60 # 60 frames = perfectly smooth 30fps / 2.0s loop
    frames = []
    
    print(f"Rendering {num_frames} frames of the 4D Chamfered Plate (Right-to-Left 360° rotation)...")
    
    for i in range(num_frames):
        # theta rotates through 0 -> 2pi
        theta = (i * 2.0 * math.pi) / num_frames
        
        frame = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
        draw = ImageDraw.Draw(frame)
        
        # 1. 4D Tesseract Wireframe Aura (Background layer)
        aura_layer = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
        adraw = ImageDraw.Draw(aura_layer)
        render_4d_tesseract_aura(adraw, theta, pitch, d_cam, cx, cy)
        frame = Image.alpha_composite(frame, aura_layer)
        
        # 2. Compute 8 3D vertices of the extruded chamfered plate
        # Front face at z = +half_t, Back face at z = -half_t
        f_tl = project_point(-half_w, -half_h, half_t, theta, pitch, d_cam, cx, cy)
        f_tr = project_point(half_w, -half_h, half_t, theta, pitch, d_cam, cx, cy)
        f_br = project_point(half_w, half_h, half_t, theta, pitch, d_cam, cx, cy)
        f_bl = project_point(-half_w, half_h, half_t, theta, pitch, d_cam, cx, cy)
        
        b_tl = project_point(-half_w, -half_h, -half_t, theta, pitch, d_cam, cx, cy)
        b_tr = project_point(half_w, -half_h, -half_t, theta, pitch, d_cam, cx, cy)
        b_br = project_point(half_w, half_h, -half_t, theta, pitch, d_cam, cx, cy)
        b_bl = project_point(-half_w, half_h, -half_t, theta, pitch, d_cam, cx, cy)
        
        # Determine visibility via face normal Z component
        # Front face normal in camera space
        cos_t = math.cos(theta)
        sin_t = math.sin(theta)
        front_facing = cos_t > 0
        
        # Rim colors (Gunmetal titanium with chamfer edge highlights)
        rim_base = (30, 30, 46, 255)
        rim_high = (147, 153, 178, 255)
        
        # Draw physical plate elements in depth-sorted painter's order:
        if front_facing:
            # When front is visible, draw back face first if visible (culled), then rim, then front
            # Top rim (always visible due to pitch)
            draw.polygon([(f_tl[0], f_tl[1]), (f_tr[0], f_tr[1]), (b_tr[0], b_tr[1]), (b_tl[0], b_tl[1])],
                         fill=rim_high, outline=(203, 166, 247, 200))
            # Bottom rim
            draw.polygon([(f_bl[0], f_bl[1]), (f_br[0], f_br[1]), (b_br[0], b_br[1]), (b_bl[0], b_bl[1])],
                         fill=rim_base)
            
            # Left or Right side rim
            if sin_t > 0:
                # Left rim visible
                draw.polygon([(f_tl[0], f_tl[1]), (b_tl[0], b_tl[1]), (b_bl[0], b_bl[1]), (f_bl[0], f_bl[1])],
                             fill=rim_base, outline=rim_high)
            else:
                # Right rim visible
                draw.polygon([(f_tr[0], f_tr[1]), (b_tr[0], b_tr[1]), (b_br[0], b_br[1]), (f_br[0], f_br[1])],
                             fill=rim_base, outline=rim_high)
                
            # Warp Front Face
            warped_front = warp_face(front_face, f_tl, f_tr, f_br, f_bl, (canvas_size, canvas_size))
            frame = Image.alpha_composite(frame, warped_front)
            
            # Dynamic specular shimmer flare (when facing camera)
            if cos_t > 0.82:
                glint_fac = (cos_t - 0.82) / 0.18
                flare_layer = Image.new("RGBA", (canvas_size, canvas_size), (0, 0, 0, 0))
                fdraw = ImageDraw.Draw(flare_layer)
                gx = (f_tl[0] + f_tr[0]) * 0.5 + 30.0 * (1.0 - glint_fac)
                gy = (f_tl[1] + f_bl[1]) * 0.5
                f_rad = int(35 * glint_fac)
                fdraw.ellipse([gx - f_rad, gy - f_rad, gx + f_rad, gy + f_rad], fill=(255, 255, 255, int(180 * glint_fac)))
                fdraw.line([(gx - f_rad * 2.2, gy), (gx + f_rad * 2.2, gy)], fill=(203, 166, 247, int(220 * glint_fac)), width=2)
                flare_layer = flare_layer.filter(ImageFilter.GaussianBlur(3))
                frame = Image.alpha_composite(frame, flare_layer)
        else:
            # Reverse face is visible
            # Top rim
            draw.polygon([(b_tl[0], b_tl[1]), (b_tr[0], b_tr[1]), (f_tr[0], f_tr[1]), (f_tl[0], f_tl[1])],
                         fill=rim_high, outline=(116, 199, 236, 200))
            # Bottom rim
            draw.polygon([(b_bl[0], b_bl[1]), (b_br[0], b_br[1]), (f_br[0], f_br[1]), (f_bl[0], f_bl[1])],
                         fill=rim_base)
            
            # Side rims
            if sin_t > 0:
                draw.polygon([(b_tl[0], b_tl[1]), (f_tl[0], f_tl[1]), (f_bl[0], f_bl[1]), (b_bl[0], b_bl[1])],
                             fill=rim_base, outline=rim_high)
            else:
                draw.polygon([(b_tr[0], b_tr[1]), (f_tr[0], f_tr[1]), (f_br[0], f_br[1]), (b_br[0], b_br[1])],
                             fill=rim_base, outline=rim_high)
                
            # Warp Reverse Face (mirrored X coords so text and motherboard read correctly from back)
            warped_back = warp_face(reverse_face, b_tr, b_tl, b_bl, b_br, (canvas_size, canvas_size))
            frame = Image.alpha_composite(frame, warped_back)
            
        frames.append(frame)
        
    print(f"Generated {len(frames)} 3D frames successfully.")
    
    # Save Hero Still at 28 degrees angle (Frame 5)
    hero_frame = frames[5]
    hero_out = script_dir / "palexus_chrome_plate_4d.png"
    hero_frame.save(hero_out, optimize=True)
    print(f"Saved 4D plate hero still: {hero_out}")
    
    # Save Animated 32-bit Lossless WebP
    webp_out = script_dir / "palexus_chrome_spin_360.webp"
    frames[0].save(
        webp_out,
        save_all=True,
        append_images=frames[1:],
        duration=33, # ~30fps smooth loop
        loop=0,
        lossless=True
    )
    print(f"Saved animated 360 4D plate WebP: {webp_out} ({webp_out.stat().st_size} bytes)")
    
    # Also save with explicit plate name
    webp_plate_out = script_dir / "palexus_chrome_plate_spin_360.webp"
    frames[0].save(
        webp_plate_out,
        save_all=True,
        append_images=frames[1:],
        duration=33,
        loop=0,
        lossless=True
    )
    print(f"Saved animated WebP alias: {webp_plate_out}")
    
    # Save Animated GIF (with transparent background)
    gif_out = script_dir / "palexus_chrome_spin_360.gif"
    frames[0].save(
        gif_out,
        save_all=True,
        append_images=frames[1:],
        duration=33,
        loop=0,
        disposal=2
    )
    print(f"Saved animated 360 4D plate GIF: {gif_out} ({gif_out.stat().st_size} bytes)")

if __name__ == "__main__":
    main()
