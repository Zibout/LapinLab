extends Node

@export var pitch_mult: float = 0.1
@export var yaw_mult: float = 0.1
@export var roll_mult: float = 0.1

@export var throttle: float = 0.0

@export var target_drone: Drone = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_R:
			target_drone.request_rest()
			throttle = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	throttle += Input.get_axis("move_backward", "move_forward") * delta
	throttle = clamp(throttle, 0.0, 1.0)
	
	var roll = roll_mult * -Input.get_axis("ui_right", "ui_left")
	var pitch = pitch_mult * -Input.get_axis("ui_down", "ui_up")
	var yaw = yaw_mult * Input.get_axis("move_right", "move_left")
	
	if target_drone:
		var drone_inputs: Array[float] = [
			throttle + roll + pitch + yaw,
			throttle - roll + pitch - yaw,
			throttle + roll - pitch - yaw,
			throttle - roll - pitch + yaw
		]
		target_drone.set_inputs(drone_inputs)
		
