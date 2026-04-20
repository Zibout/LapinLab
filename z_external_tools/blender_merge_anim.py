import bpy
import os

# --- CONFIGURATION ---
# Path to the folder containing your animation FBX files
# NOTE: Use forward slashes (/) or double backslashes (\\)
FBX_FOLDER_PATH = "C:/Users/theo_/Downloads/Action Adventure Pack/"



# The name of your MAIN skeleton object in the scene
MAIN_ARMATURE_NAME = "Armature" 

def batch_import_animations():
    # 1. Check if Main Armature exists
    if MAIN_ARMATURE_NAME not in bpy.data.objects:
        print(f"Error: Could not find object named '{MAIN_ARMATURE_NAME}'")
        return

    main_rig = bpy.data.objects[MAIN_ARMATURE_NAME]
    
    # Ensure the main rig has animation data
    if not main_rig.animation_data:
        main_rig.animation_data_create()

    # 2. Iterate over files in the folder
    print(f"--- Starting Import from {FBX_FOLDER_PATH} ---")
    
    for file_name in os.listdir(FBX_FOLDER_PATH):
        if file_name.lower().endswith(".fbx"):
            full_path = os.path.join(FBX_FOLDER_PATH, file_name)
            anim_name = os.path.splitext(file_name)[0] # Remove .fbx extension
            
            # Deselect everything first to identify new imports easily
            bpy.ops.object.select_all(action='DESELECT')
            
            # 3. Import the FBX
            # use_anim=True ensures we get the animation
            bpy.ops.import_scene.fbx(filepath=full_path, use_anim=True)
            
            # Find the imported armature among selected objects
            imported_armature = None
            for obj in bpy.context.selected_objects:
                if obj.type == 'ARMATURE':
                    imported_armature = obj
                    break
            
            if imported_armature and imported_armature.animation_data and imported_armature.animation_data.action:
                # 4. Grab the Action
                imported_action = imported_armature.animation_data.action
                imported_action.name = anim_name # Rename action to match file
                
                # Make sure the action isn't lost when we delete the object
                imported_action.use_fake_user = True
                
                # 5. Assign to Main Rig (NLA Track)
                # Create a new NLA track on the main rig
                new_track = main_rig.animation_data.nla_tracks.new()
                new_track.name = anim_name
                
                # Place the action into the strip
                # (Action Name, Start Frame, Action Data)
                new_track.strips.new(anim_name, int(imported_action.frame_range[0]), imported_action)
                
                print(f"Success: Added '{anim_name}' to NLA.")
                
            else:
                print(f"Warning: No animation found in {file_name}")

            # 6. Cleanup
            # Delete all objects that were just imported (they are still selected)
            bpy.ops.object.delete()

    print("--- Batch Import Complete ---")

# Run the function
batch_import_animations()