extends Node3D

@onready var anim_player := $robot_arm/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var anim_names = anim_player.get_animation_list()
	anim_player.play(anim_names[randi() % anim_names.size()])
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
