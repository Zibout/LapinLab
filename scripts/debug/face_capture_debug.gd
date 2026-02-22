extends Control

var is_first = true

@onready var grid_layout = $GridContainer
@onready var progress_bar_scene = preload("res://scenes/debug/simple_progress_bar.tscn")

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Debug"):
		visible = ! visible

func _on_face_data_received(blend_shapes: Dictionary, orientation: Dictionary):
	if is_first:
		is_first = false
		for shape_name in blend_shapes.keys():
			var progress_bar = progress_bar_scene.instantiate()
			var label = progress_bar.get_child(0)
			label.text = shape_name
			grid_layout.add_child(progress_bar)
	
	var i := 0
	for shape_name in blend_shapes.keys():
		var progress_bar = grid_layout.get_child(i)
		progress_bar.value = blend_shapes[shape_name]
		i += 1


	
