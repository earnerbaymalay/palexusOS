#!/usr/bin/env python3
"""
PalexusOS Monolithic Cyberdeck Boot Video Suite (Blender 4.0+ Automation)
Generates and renders procedural 3D boot sequence concepts:
- Concept 2: 'The Sovereign Cipher' (Aerospace Billet Excavation & Liquid Chrome PALEXUS)
- Concept 3: 'Cortical Convolutions' (Undulating Neural Strata, Angled Slicer & PALEXUS OS)
- Concept 4: 'The Monolithic Prism' (Octagonal Smoked Obsidian Monocrystal & Photonic Slicer)

Aesthetic Palette: Catppuccin Mocha Mauve (#cba6f7) + Liquid Silver Chrome (#cdd6f4) + Obsidian (#11111b)
"""

import os
import sys
import math
import argparse

try:
    import bpy
    IN_BLENDER = True
except ImportError:
    IN_BLENDER = False


def create_material(name, base_color, metallic=0.0, roughness=0.5, coat=0.0, trans=0.0, emission=None, emission_str=1.0):
    mat = bpy.data.materials.new(name=name)
    mat.use_nodes = True
    nodes = mat.node_tree.nodes
    bsdf = nodes.get("Principled BSDF")

    if bsdf:
        if "Base Color" in bsdf.inputs:
            bsdf.inputs["Base Color"].default_value = base_color
        if "Metallic" in bsdf.inputs:
            bsdf.inputs["Metallic"].default_value = metallic
        if "Roughness" in bsdf.inputs:
            bsdf.inputs["Roughness"].default_value = roughness
        if "Coat Weight" in bsdf.inputs:
            bsdf.inputs["Coat Weight"].default_value = coat
        elif "Clearcoat" in bsdf.inputs:
            bsdf.inputs["Clearcoat"].default_value = coat
        if "Transmission Weight" in bsdf.inputs:
            bsdf.inputs["Transmission Weight"].default_value = trans
        elif "Transmission" in bsdf.inputs:
            bsdf.inputs["Transmission"].default_value = trans
        if emission:
            if "Emission Color" in bsdf.inputs:
                bsdf.inputs["Emission Color"].default_value = emission
            elif "Emission" in bsdf.inputs:
                bsdf.inputs["Emission"].default_value = emission
            if "Emission Strength" in bsdf.inputs:
                bsdf.inputs["Emission Strength"].default_value = emission_str
    return mat


def build_concept_2(wordmark="PALEXUS"):
    """Concept 2: The Sovereign Cipher (Titanium Vault Plate Excavation & Liquid Chrome Wordmark)"""
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.frame_start = 1
    scene.frame_end = 120
    scene.render.fps = 30
    scene.render.resolution_x = 1920
    scene.render.resolution_y = 1080
    scene.render.engine = 'BLENDER_EEVEE'

    mat_tungsten = create_material("Billet_Tungsten", (0.04, 0.04, 0.06, 1.0), metallic=0.88, roughness=0.22)
    mat_chrome = create_material("Liquid_Chrome", (0.95, 0.96, 0.98, 1.0), metallic=1.0, roughness=0.02, coat=1.0)
    mat_plasma = create_material("Mauve_Plasma", (0.80, 0.65, 0.97, 1.0), emission=(0.80, 0.65, 0.97, 1.0), emission_str=28.0)

    # 1. Base Monolith Plate (Aerospace Billet)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, -0.2))
    plate = bpy.context.active_object
    plate.name = "Monolith_Plate"
    plate.scale = (5.6, 3.2, 0.35)
    plate.data.materials.append(mat_tungsten)
    mod_bevel = plate.modifiers.new(name="BilletBevel", type='BEVEL')
    mod_bevel.width = 0.06
    mod_bevel.segments = 4

    # 2. Animated Boolean Strata Slicer
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-6.0, 0, 0.05))
    cutter = bpy.context.active_object
    cutter.name = "Strata_Cutter"
    cutter.scale = (4.8, 2.3, 0.3)
    cutter.display_type = 'WIRE'
    cutter.hide_render = True

    cutter.keyframe_insert(data_path="location", frame=25)
    cutter.location.x = 0.0
    cutter.keyframe_insert(data_path="location", frame=65)

    mod_bool = plate.modifiers.new(name="StrataExcavate", type='BOOLEAN')
    mod_bool.object = cutter
    mod_bool.operation = 'DIFFERENCE'

    # 3. Glowing Laser Kerf Trim
    bpy.ops.mesh.primitive_plane_add(size=1.0, location=(0, 0, -0.02))
    kerf = bpy.context.active_object
    kerf.name = "Laser_Kerf_Glow"
    kerf.scale = (4.85, 2.35, 1.0)
    kerf.data.materials.append(mat_plasma)

    # 4. Wordmark Typography
    bpy.ops.object.text_add(location=(-2.1, -0.45, -0.25))
    txt = bpy.context.active_object
    txt.name = f"Wordmark_{wordmark}"
    txt.data.body = wordmark
    txt.data.extrude = 0.14
    txt.data.bevel_depth = 0.02
    txt.data.bevel_resolution = 3
    txt.data.materials.append(mat_chrome)

    # Keyframe Vertical Extrusion
    txt.keyframe_insert(data_path="location", frame=45)
    txt.location.z = 0.12
    txt.keyframe_insert(data_path="location", frame=85)

    # 5. Sovereign Tactical Shield Reticle
    bpy.ops.mesh.primitive_torus_add(major_radius=2.6, minor_radius=0.015, location=(0, 0, 0.08))
    reticle = bpy.context.active_object
    reticle.name = "Tactical_Reticle"
    reticle.data.materials.append(mat_plasma)
    reticle.rotation_euler.z = 0
    reticle.keyframe_insert(data_path="rotation_euler", frame=70)
    reticle.rotation_euler.z = math.radians(180)
    reticle.keyframe_insert(data_path="rotation_euler", frame=110)

    # 6. Cinematic Lighting
    bpy.ops.object.light_add(type='SPOT', location=(-3.5, -4.0, 4.5))
    key_light = bpy.context.active_object
    key_light.data.energy = 500
    key_light.data.color = (0.80, 0.65, 0.97)

    bpy.ops.object.light_add(type='AREA', location=(3.5, 3.0, 3.0))
    rim_light = bpy.context.active_object
    rim_light.data.energy = 300
    rim_light.data.color = (0.95, 0.95, 1.0)

    # 7. Camera Setup
    bpy.ops.object.camera_add(location=(0, -5.2, 3.4), rotation=(math.radians(56), 0, 0))
    cam = bpy.context.active_object
    cam.name = "Hero_Camera"
    scene.camera = cam

    print(f"[Concept 2] Built scene successfully for '{wordmark}'!")


def build_concept_3(wordmark="PALEXUS OS"):
    """Concept 3: Cortical Convolutions (Neural Topography & Angled Laser Slicing)"""
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.frame_start = 1
    scene.frame_end = 120
    scene.render.fps = 30
    scene.render.resolution_x = 1920
    scene.render.resolution_y = 1080
    scene.render.engine = 'BLENDER_EEVEE'

    mat_carbon = create_material("Carbon_Wafer", (0.02, 0.02, 0.03, 1.0), metallic=0.75, roughness=0.3)
    mat_chrome = create_material("Liquid_Chrome", (0.95, 0.96, 0.98, 1.0), metallic=1.0, roughness=0.02, coat=1.0)
    mat_fiber = create_material("Fiber_Neon_Mauve", (0.80, 0.65, 0.97, 1.0), emission=(0.80, 0.65, 0.97, 1.0), emission_str=25.0)

    # 1. High-Density Cortical Substrate Grid
    bpy.ops.mesh.primitive_grid_add(x_subdivisions=80, y_subdivisions=80, size=6.5, location=(0, 0, 0))
    grid = bpy.context.active_object
    grid.name = "Cortical_Substrate"
    grid.data.materials.append(mat_carbon)

    # 2. Animated Cortical Gyri Displace Modifier
    tex = bpy.data.textures.new("Gyri_Musgrave_Noise", type='CLOUDS')
    tex.noise_scale = 0.85
    tex.noise_depth = 2

    mod_disp = grid.modifiers.new(name="Gyri_Displacement", type='DISPLACE')
    mod_disp.texture = tex
    mod_disp.strength = 0.4
    mod_disp.keyframe_insert(data_path="strength", frame=1)
    mod_disp.strength = 0.75
    mod_disp.keyframe_insert(data_path="strength", frame=40)
    mod_disp.strength = 0.02
    mod_disp.keyframe_insert(data_path="strength", frame=90)

    # 3. Angled Laser Slicing Plane Cutter
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-6.0, 0, 0.4), rotation=(0, math.radians(28), math.radians(18)))
    cutter = bpy.context.active_object
    cutter.name = "Laser_Slicing_Cutter"
    cutter.scale = (0.25, 9.0, 5.0)
    cutter.display_type = 'WIRE'
    cutter.hide_render = True

    cutter.keyframe_insert(data_path="location", frame=30)
    cutter.location.x = 6.0
    cutter.keyframe_insert(data_path="location", frame=80)

    mod_bool = grid.modifiers.new(name="AngledLaserSlice", type='BOOLEAN')
    mod_bool.object = cutter
    mod_bool.operation = 'DIFFERENCE'

    # 4. Wordmark Typography
    bpy.ops.object.text_add(location=(-2.4, -0.4, 0.15))
    txt = bpy.context.active_object
    txt.name = f"Wordmark_{wordmark}"
    txt.data.body = wordmark
    txt.data.extrude = 0.15
    txt.data.bevel_depth = 0.025
    txt.data.bevel_resolution = 3
    txt.data.materials.append(mat_chrome)

    txt.scale = (0.001, 0.001, 0.001)
    txt.keyframe_insert(data_path="scale", frame=65)
    txt.scale = (1.0, 1.0, 1.0)
    txt.keyframe_insert(data_path="scale", frame=95)

    # 5. Emissive HUD Floor Grid
    bpy.ops.mesh.primitive_grid_add(x_subdivisions=20, y_subdivisions=20, size=8.0, location=(0, 0, -0.05))
    hud = bpy.context.active_object
    hud.name = "HUD_Deck_Grid"
    hud.data.materials.append(mat_fiber)
    mod_wire = hud.modifiers.new(name="HUD_Wireframe", type='WIREFRAME')
    mod_wire.thickness = 0.008

    # 6. Lighting & Camera
    bpy.ops.object.light_add(type='SPOT', location=(0, -4.5, 4.0))
    spot = bpy.context.active_object
    spot.data.energy = 600
    spot.data.color = (0.80, 0.65, 0.97)

    bpy.ops.object.camera_add(location=(0, -5.5, 3.6), rotation=(math.radians(57), 0, 0))
    cam = bpy.context.active_object
    cam.name = "Hero_Camera"
    scene.camera = cam

    print(f"[Concept 3] Built scene successfully for '{wordmark}'!")


def build_concept_4(wordmark="PALEXUS OS"):
    """Concept 4: The Monolithic Prism & Photonic Slicer (Obsidian Monocrystal & Photonic Laser)"""
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.frame_start = 1
    scene.frame_end = 120
    scene.render.fps = 30
    scene.render.resolution_x = 1920
    scene.render.resolution_y = 1080
    scene.render.engine = 'BLENDER_EEVEE'

    mat_obsidian = create_material("Smoked_Obsidian_Glass", (0.015, 0.015, 0.025, 1.0), metallic=0.2, roughness=0.08, coat=0.8, trans=0.85)
    mat_chrome = create_material("Liquid_Chrome", (0.95, 0.96, 0.98, 1.0), metallic=1.0, roughness=0.015, coat=1.0)
    mat_photon = create_material("Photonic_Laser", (0.80, 0.65, 0.97, 1.0), emission=(0.80, 0.65, 0.97, 1.0), emission_str=35.0)

    # 1. Octagonal Obsidian Monocrystal Prism
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=1.9, depth=3.4, location=(0, 0, 0))
    prism = bpy.context.active_object
    prism.name = "Monocrystal_Prism"
    prism.rotation_euler.z = math.radians(22.5)
    prism.data.materials.append(mat_obsidian)

    mod_bev = prism.modifiers.new(name="PrismBevel", type='BEVEL')
    mod_bev.width = 0.08
    mod_bev.segments = 4

    prism.keyframe_insert(data_path="rotation_euler", frame=1)
    prism.rotation_euler.z += math.radians(45)
    prism.keyframe_insert(data_path="rotation_euler", frame=120)

    # 2. Twin Diagonal Cross Cutters
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-5.0, 0, 0), rotation=(math.radians(35), 0, math.radians(45)))
    cutter_a = bpy.context.active_object
    cutter_a.name = "Cross_Cutter_A"
    cutter_a.scale = (0.18, 7.0, 7.0)
    cutter_a.display_type = 'WIRE'
    cutter_a.hide_render = True

    cutter_a.keyframe_insert(data_path="location", frame=25)
    cutter_a.location.x = 5.0
    cutter_a.keyframe_insert(data_path="location", frame=70)

    mod_bool_a = prism.modifiers.new(name="CrossCutA", type='BOOLEAN')
    mod_bool_a.object = cutter_a
    mod_bool_a.operation = 'DIFFERENCE'

    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(5.0, 0, 0), rotation=(math.radians(-35), 0, math.radians(-45)))
    cutter_b = bpy.context.active_object
    cutter_b.name = "Cross_Cutter_B"
    cutter_b.scale = (0.18, 7.0, 7.0)
    cutter_b.display_type = 'WIRE'
    cutter_b.hide_render = True

    cutter_b.keyframe_insert(data_path="location", frame=25)
    cutter_b.location.x = -5.0
    cutter_b.keyframe_insert(data_path="location", frame=70)

    mod_bool_b = prism.modifiers.new(name="CrossCutB", type='BOOLEAN')
    mod_bool_b.object = cutter_b
    mod_bool_b.operation = 'DIFFERENCE'

    # 3. Core Photonic Laser Cylinder
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.1, depth=10.0, location=(0, 0, 0), rotation=(math.radians(90), 0, 0))
    laser = bpy.context.active_object
    laser.name = "Core_Photonic_Laser"
    laser.data.materials.append(mat_photon)
    laser.scale = (0.01, 0.01, 0.01)
    laser.keyframe_insert(data_path="scale", frame=55)
    laser.scale = (1.0, 1.0, 1.0)
    laser.keyframe_insert(data_path="scale", frame=75)

    # 4. Wordmark Typography
    bpy.ops.object.text_add(location=(-2.4, -0.4, 0))
    txt = bpy.context.active_object
    txt.name = f"Wordmark_{wordmark}"
    txt.data.body = wordmark
    txt.data.extrude = 0.16
    txt.data.bevel_depth = 0.025
    txt.data.bevel_resolution = 3
    txt.data.materials.append(mat_chrome)

    txt.scale = (0.001, 0.001, 0.001)
    txt.keyframe_insert(data_path="scale", frame=65)
    txt.scale = (1.0, 1.0, 1.0)
    txt.keyframe_insert(data_path="scale", frame=90)

    # 5. Lighting & Camera
    bpy.ops.object.light_add(type='SPOT', location=(-3.0, -5.0, 3.5))
    spot1 = bpy.context.active_object
    spot1.data.energy = 500
    spot1.data.color = (0.80, 0.65, 0.97)

    bpy.ops.object.light_add(type='POINT', location=(0, 0, 0))
    core_point = bpy.context.active_object
    core_point.data.energy = 250
    core_point.data.color = (0.95, 0.90, 1.0)

    bpy.ops.object.camera_add(location=(0, -6.8, 2.2), rotation=(math.radians(73), 0, 0))
    cam = bpy.context.active_object
    cam.name = "Hero_Camera"
    scene.camera = cam

    print(f"[Concept 4] Built scene successfully for '{wordmark}'!")


if IN_BLENDER:
    argv = sys.argv
    if "--" in argv:
        args = argv[argv.index("--") + 1:]
    else:
        args = []

    parser = argparse.ArgumentParser(description="PalexusOS Blender Boot Video Generator")
    parser.add_argument("--concept", choices=["2", "3", "4", "all"], default="2", help="Concept to build")
    parser.add_argument("--wordmark", default="PALEXUS", help="Typography wordmark")
    parser.add_argument("--save-blend", default=None, help="Save .blend file to path")
    parser.add_argument("--render-frames", default=None, help="Output path prefix for rendered frames")
    parser.add_argument("--render-mp4", default=None, help="Output MP4 video file path")
    parsed = parser.parse_args(args)

    if parsed.concept == "2":
        build_concept_2(parsed.wordmark)
    elif parsed.concept == "3":
        build_concept_3(parsed.wordmark if parsed.wordmark != "PALEXUS" else "PALEXUS OS")
    elif parsed.concept == "4":
        build_concept_4(parsed.wordmark if parsed.wordmark != "PALEXUS" else "PALEXUS OS")

    if parsed.save_blend:
        os.makedirs(os.path.dirname(os.path.abspath(parsed.save_blend)), exist_ok=True)
        bpy.ops.wm.save_mainfile(filepath=parsed.save_blend)
        print(f"Saved .blend file to: {parsed.save_blend}")

    if parsed.render_frames:
        os.makedirs(parsed.render_frames, exist_ok=True)
        scene = bpy.context.scene
        scene.render.filepath = os.path.join(parsed.render_frames, "frame_####")
        bpy.ops.render.render(animation=True)
        print(f"Rendered frames to: {parsed.render_frames}")

    if parsed.render_mp4:
        os.makedirs(os.path.dirname(os.path.abspath(parsed.render_mp4)), exist_ok=True)
        scene = bpy.context.scene
        scene.render.image_settings.file_format = 'FFMPEG'
        scene.render.ffmpeg.format = 'MPEG4'
        scene.render.ffmpeg.codec = 'H264'
        scene.render.ffmpeg.constant_rate_factor = 'HIGH'
        scene.render.filepath = parsed.render_mp4
        bpy.ops.render.render(animation=True)
        print(f"Rendered MP4 to: {parsed.render_mp4}")
