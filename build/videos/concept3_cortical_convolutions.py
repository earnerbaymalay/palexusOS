import bpy
import math
def build_concept_3(wordmark="PALEXUS"):
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

    mat_carbon = create_material("Carbon_Wafer", (0.02, 0.02, 0.03, 1.0), metallic=0.7, roughness=0.35)
    mat_chrome = create_material("Liquid_Chrome", (0.95, 0.96, 0.98, 1.0), metallic=1.0, roughness=0.02, coat=1.0)
    mat_fiber = create_material("Fiber_Neon_Mauve", (0.80, 0.65, 0.97, 1.0), emission=(0.80, 0.65, 0.97, 1.0), emission_str=25.0)

    # 3. High-Density Cortical Substrate Grid
    bpy.ops.mesh.primitive_grid_add(x_subdivisions=80, y_subdivisions=80, size=6.5, location=(0, 0, 0))
    grid = bpy.context.active_object
    grid.name = "Cortical_Substrate"
    grid.data.materials.append(mat_carbon)

    # 4. Animated Cortical Gyri Displace Modifier
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

    # 5. Angled Laser Slicing Plane Cutter
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

    # 6. Wordmark Typography
    bpy.ops.object.text_add(location=(-2.1, -0.4, 0.15))
    txt = bpy.context.active_object
    txt.name = f"Wordmark_{wordmark}"
    txt.data.body = wordmark
    txt.data.extrude = 0.15
    txt.data.bevel_depth = 0.025
    txt.data.bevel_resolution = 3
    txt.data.materials.append(mat_chrome)

    # Scale Animation (Ferrofluid snap into place)
    txt.scale = (0.001, 0.001, 0.001)
    txt.keyframe_insert(data_path="scale", frame=65)
    txt.scale = (1.0, 1.0, 1.0)
    txt.keyframe_insert(data_path="scale", frame=95)

    # 7. Emissive HUD Floor Grid
    bpy.ops.mesh.primitive_grid_add(x_subdivisions=20, y_subdivisions=20, size=8.0, location=(0, 0, -0.05))
    hud = bpy.context.active_object
    hud.name = "HUD_Deck_Grid"
    hud.data.materials.append(mat_fiber)
    mod_wire = hud.modifiers.new(name="HUD_Wireframe", type='WIREFRAME')
    mod_wire.thickness = 0.008

    # 8. Lighting & Camera
    bpy.ops.object.light_add(type='SPOT', location=(0, -4.5, 4.0))
    spot = bpy.context.active_object
    spot.data.energy = 600
    spot.data.color = (0.80, 0.65, 0.97)

    bpy.ops.object.camera_add(location=(0, -5.5, 3.6), rotation=(math.radians(57), 0, 0))
    cam = bpy.context.active_object
    cam.name = "Hero_Camera"
    scene.camera = cam

    print(f"[Concept 3] Scene generated successfully for '{wordmark}'!")

if __name__ == "__main__":
    build_concept_3("PALEXUS")
