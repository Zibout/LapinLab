extends Node



#func _ready() -> void:
	#pass 

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


#func _process(delta: float) -> void:
	#pass
