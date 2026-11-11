import bpy
import math
def build_concept_4(wordmark="PALEXUS"):
    # 1. Initialize Scene
    bpy.ops.wm.read_factory_settings(use_empty=True)
    scene = bpy.context.scene
    scene.frame_start = 1
    scene.frame_end = 120
    scene.render.fps = 30
    scene.render.resolution_x = 1920
    scene.render.resolution_y = 1080
    scene.render.engine = 'BLENDER_EEVEE'

    # 2. Materials
    def create_material(name, base_color, metallic=0.0, roughness=0.5, coat=0.0, trans=0.0, emission=None, emission_str=1.0):
        mat = bpy.data.materials.new(name=name)
        mat.use_nodes = True
        bsdf = mat.node_tree.nodes.get('Principled BSDF')
        bsdf.inputs['Base Color'].default_value = base_color
        bsdf.inputs['Metallic'].default_value = metallic
        bsdf.inputs['Roughness'].default_value = roughness
        if 'Coat Weight' in bsdf.inputs:
            bsdf.inputs['Coat Weight'].default_value = coat
        if 'Transmission Weight' in bsdf.inputs:
            bsdf.inputs['Transmission Weight'].default_value = trans
        if emission and 'Emission Color' in bsdf.inputs:
            bsdf.inputs['Emission Color'].default_value = emission
            bsdf.inputs['Emission Strength'].default_value = emission_str
        return mat

    mat_obsidian = create_material("Smoked_Obsidian_Glass", (0.015, 0.015, 0.025, 1.0), metallic=0.2, roughness=0.08, coat=0.8, trans=0.85)
    mat_chrome = create_material("Liquid_Chrome", (0.95, 0.96, 0.98, 1.0), metallic=1.0, roughness=0.015, coat=1.0)
    mat_photon = create_material("Photonic_Laser", (0.80, 0.65, 0.97, 1.0), emission=(0.80, 0.65, 0.97, 1.0), emission_str=35.0)

    # 3. Octagonal Obsidian Monocrystal Prism
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=1.9, depth=3.4, location=(0, 0, 0))
    prism = bpy.context.active_object
    prism.name = "Monocrystal_Prism"
    prism.rotation_euler.z = math.radians(22.5)
    prism.data.materials.append(mat_obsidian)

    # Bevel on Prism
    mod_bev = prism.modifiers.new(name="PrismBevel", type='BEVEL')
    mod_bev.width = 0.08
    mod_bev.segments = 4

    # Slow Cinematic Prism Rotation
    prism.keyframe_insert(data_path="rotation_euler", frame=1)
    prism.rotation_euler.z += math.radians(45)
    prism.keyframe_insert(data_path="rotation_euler", frame=120)

    # 4. Twin Diagonal Cross Cutters
    # Cutter A
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

    # Cutter B (Counter-angle)
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

    # 5. Core Photonic Laser Cylinder
    bpy.ops.mesh.primitive_cylinder_add(vertices=16, radius=0.1, depth=10.0, location=(0, 0, 0), rotation=(math.radians(90), 0, 0))
    laser = bpy.context.active_object
    laser.name = "Core_Photonic_Laser"
    laser.data.materials.append(mat_photon)
    laser.scale = (0.01, 0.01, 0.01)
    laser.keyframe_insert(data_path="scale", frame=55)
    laser.scale = (1.0, 1.0, 1.0)
    laser.keyframe_insert(data_path="scale", frame=75)

    # 6. Wordmark Typography
    bpy.ops.object.text_add(location=(-2.4, -0.4, 0))
    txt = bpy.context.active_object
    txt.name = f"Wordmark_{wordmark}"
    txt.data.body = wordmark
    txt.data.extrude = 0.16
    txt.data.bevel_depth = 0.025
    txt.data.bevel_resolution = 3
    txt.data.materials.append(mat_chrome)

    # Flash-Freeze Scale
    txt.scale = (0.001, 0.001, 0.001)
    txt.keyframe_insert(data_path="scale", frame=65)
    txt.scale = (1.0, 1.0, 1.0)
    txt.keyframe_insert(data_path="scale", frame=90)

    # 7. Lighting & Camera
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

    print(f"[Concept 4] Scene generated successfully for '{wordmark}'!")

if __name__ == "__main__":
    build_concept_4("PALEXUS")
