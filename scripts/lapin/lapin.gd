extends Node3D



# Sensitivity multiplier for head rotation
@export var rotation_multiplier: float = 1.0

# Store the initial rotation to apply offsets correctly

@export var face_mesh: MeshInstance3D 

@export var skeleton: Skeleton3D

@export var node_eye_l: Node3D
@export var node_eye_r: Node3D
@export var node_head_target: Node3D

func _ready() -> void:
	print("Blend shape count:", str(face_mesh.get_blend_shape_count()))
	
	
	
func _on_face_data_received(blend_shapes: Dictionary, orientation: Dictionary):
	
	#var eye_look_l = Vector2(0, -0.3)
	#var eye_look_r = Vector2(0, -0.3)
	
	var eye_look_l = Vector2(0, 0)
	var eye_look_r = Vector2(0, 0)
	
	# 1. Update Blend Shapes
	# ARKit keys (e.g., "jawOpen") must match your Godot Mesh BlendShape names.
	# If your mesh uses different names, you need a mapping dictionary.
	for shape_name in blend_shapes.keys():
		var value = blend_shapes[shape_name]
		
		# Find the index of the blend shape by name
		var shape_index = face_mesh.find_blend_shape_by_name(shape_name)
		
		if shape_index != -1:
			#print(str(shape_index) + ": " + shape_name + ": " + str(value))
			# ARKit sends 0.0 to 1.0 usually. Godot expects the same.
			face_mesh.set_blend_shape_value(shape_index, value)
		else:
			print(shape_name)
		
	eye_look_l.x += blend_shapes["eyeLookInLeft"] - blend_shapes["eyeLookOutLeft"]
	eye_look_l.y += blend_shapes["eyeLookDownLeft"] - blend_shapes["eyeLookUpLeft"]
	eye_look_r.x += blend_shapes["eyeLookOutRight"] - blend_shapes["eyeLookInRight"]
	eye_look_r.y += blend_shapes["eyeLookDownRight"] - blend_shapes["eyeLookUpRight"]


	# 2. Update Head Orientation
	# ARKit sends Pitch, Yaw, Roll in Radians.
	# Note: You might need to invert some axes depending on your model's import settings.
	var pitch = orientation.get("pitch", 0.0)
	var yaw = orientation.get("yaw", 0.0)
	var roll = orientation.get("roll", 0.0)
	
	# Create a new rotation basis from Euler angles (YXZ order is common for heads)
	# You may need to swap these or negate them based on your specific 3D model orientation
	
	
	if node_head_target:
		node_head_target.rotation.x = (pitch * rotation_multiplier)
		node_head_target.rotation.y = -(yaw * rotation_multiplier) # Often needs inversion
		node_head_target.rotation.z = (roll * rotation_multiplier)
	
	var eye_movement_mult := 0.8
	node_eye_l.rotation.y = eye_look_l.x * eye_movement_mult
	node_eye_l.rotation.x = eye_look_l.y * eye_movement_mult
	node_eye_r.rotation.y = eye_look_r.x * eye_movement_mult
	node_eye_r.rotation.x = eye_look_r.y * eye_movement_mult
