extends Node3D

@onready var main_mesh: MeshInstance3D = $lapin/Skeleton/Skeleton3D/Lapin
@onready var skeleton: Skeleton3D = $lapin/Skeleton/Skeleton3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mocaplab_host_mocap_data_received(tracking_data: Dictionary) -> void:
	
	if tracking_data['type'] == 0: # Facial data
		
		tracking_data['blendshapes']['jawLeft'] *= 3.0
		tracking_data['blendshapes']['jawRight'] *= 3.0
		tracking_data['blendshapes']['mouthUpperUp_L'] *= 3.0
		tracking_data['blendshapes']['mouthUpperUp_R'] *= 3.0
		
		for blend_shape_name in tracking_data['blendshapes']:
			main_mesh.set_blend_shape_value(
				main_mesh.find_blend_shape_by_name(blend_shape_name), 
				tracking_data['blendshapes'][blend_shape_name]
				)
				
			var head_bone_idx = skeleton.find_bone("Head")
			skeleton.set_bone_pose_rotation(head_bone_idx, tracking_data['orientation'])
			
		var left_eye_orientation = Vector2(
			-tracking_data['blendshapes']['eyeLookIn_L'] + tracking_data['blendshapes']['eyeLookOut_L'],
			-tracking_data['blendshapes']['eyeLookUp_L'] + tracking_data['blendshapes']['eyeLookDown_L']
			)
		#var right_eye_orientation = Vector2(
			#tracking_data['blendshapes']['eyeLookIn_R'] - tracking_data['blendshapes']['eyeLookOut_R'],
			#tracking_data['blendshapes']['eyeLookUp_R'] - tracking_data['blendshapes']['eyeLookDown_R']
			#)
		
		var eye_track = $lapin/Skeleton/Skeleton3D/HeadAttachment/Marker3D
		eye_track.rotation.x = left_eye_orientation.y * (0.3 * PI)
		eye_track.rotation.y = left_eye_orientation.x * (0.3 * PI)
		# var left_eye_bone = skeleton.find_bone("LeftEye")
		# skeleton.set_bone_pose_rotation(left_eye_bone, Quaternion.from_euler(Vector3(left_eye_orientation.y + PI/2.0, 0.0, left_eye_orientation.x)))
		
		
	pass # Replace with function body.
