import bpy
import math
def build_concept_2(wordmark="PALEXUS"):
    # 1. Initialize Fresh Scene
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.frame_start = 1
    scene.frame_end = 120
    scene.render.fps = 30
    scene.render.resolution_x = 1920
    scene.render.resolution_y = 1080
    scene.render.engine = 'BLENDER_EEVEE'

    # 2. Material Helper
    def create_material(name, base_color, metallic=0.0, roughness=0.5, coat=0.0, emission=None, emission_str=1.0):
        mat = bpy.data.materials.new(name=name)
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes.get('Principled BSDF')
        bsdf.inputs['Base Color'].default_value = base_color
        bsdf.inputs['Metallic'].default_value = metallic
        bsdf.inputs['Roughness'].default_value = roughness
        if 'Coat Weight' in bsdf.inputs:
            bsdf.inputs['Coat Weight'].default_value = coat
        if emission and 'Emission Color' in bsdf.inputs:
            bsdf.inputs['Emission Color'].default_value = emission
            bsdf.inputs['Emission Strength'].default_value = emission_str
        return mat

    mat_tungsten = create_material("Billet_Tungsten", (0.04, 0.04, 0.06, 1.0), metallic=0.85, roughness=0.25)
    mat_chrome = create_material("Liquid_Chrome", (0.95, 0.96, 0.98, 1.0), metallic=1.0, roughness=0.02, coat=1.0)
    mat_plasma = create_material("Mauve_Plasma", (0.80, 0.65, 0.97, 1.0), emission=(0.80, 0.65, 0.97, 1.0), emission_str=30.0)

    # 3. Base Monolith Plate (Aerospace Billet)
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0, -0.2))
    plate = bpy.context.active_object
    plate.name = "Monolith_Plate"
    plate.scale = (5.6, 3.2, 0.35)
    plate.data.materials.append(mat_tungsten)
    mod_bevel = plate.modifiers.new(name="BilletBevel", type='BEVEL')
    mod_bevel.width = 0.06
    mod_bevel.segments = 4

    # 4. Animated Boolean Strata Slicer
    bpy.ops.mesh.primitive_cube_add(size=1.0, location=(-6.0, 0, 0.05))
    cutter = bpy.context.active_object
    cutter.name = "Strata_Cutter"
    cutter.scale = (4.8, 2.3, 0.3)
    cutter.display_type = 'WIRE'
    cutter.hide_render = True

    # Keyframe Cutter Sweep
    cutter.keyframe_insert(data_path="location", frame=25)
    cutter.location.x = 0.0
    cutter.keyframe_insert(data_path="location", frame=65)

    mod_bool = plate.modifiers.new(name="StrataExcavate", type='BOOLEAN')
    mod_bool.object = cutter
    mod_bool.operation = 'DIFFERENCE'

    # 5. Glowing Laser Kerf Trim
    bpy.ops.mesh.primitive_plane_add(size=1.0, location=(0, 0, -0.02))
    kerf = bpy.context.active_object
    kerf.name = "Laser_Kerf_Glow"
    kerf.scale = (4.85, 2.35, 1.0)
    kerf.data.materials.append(mat_plasma)

    # 6. Wordmark Typography
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

    # 7. Sovereign Tactical Shield Reticle
    bpy.ops.mesh.primitive_torus_add(major_radius=2.6, minor_radius=0.015, location=(0, 0, 0.08))
    reticle = bpy.context.active_object
    reticle.name = "Tactical_Reticle"
    reticle.data.materials.append(mat_plasma)
    reticle.rotation_euler.z = 0
    reticle.keyframe_insert(data_path="rotation_euler", frame=70)
    reticle.rotation_euler.z = math.radians(180)
    reticle.keyframe_insert(data_path="rotation_euler", frame=110)

    # 8. Cinematic Lighting
    bpy.ops.object.light_add(type='SPOT', location=(-3.5, -4.0, 4.5))
    key_light = bpy.context.active_object
    key_light.data.energy = 500
    key_light.data.color = (0.80, 0.65, 0.97)

    bpy.ops.object.light_add(type='AREA', location=(3.5, 3.0, 3.0))
    rim_light = bpy.context.active_object
    rim_light.data.energy = 300
    rim_light.data.color = (0.95, 0.95, 1.0)

    # 9. Camera Setup
    bpy.ops.object.camera_add(location=(0, -5.2, 3.4), rotation=(math.radians(56), 0, 0))
    cam = bpy.context.active_object
    cam.name = "Hero_Camera"
    scene.camera = cam

    print(f"[Concept 2] Scene generated successfully for '{wordmark}'!")

if __name__ == "__main__":
    build_concept_2("PALEXUS")
