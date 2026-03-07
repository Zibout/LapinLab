@tool
extends Node
class_name MLAgent

enum Mode {
	INFERENCE,
	TRAINING
}

@export var mode: Mode = Mode.INFERENCE
@export var network_config: MLPConfig
@export var training_config: MLPTrainingConfig

var reward: float = 0.0

## Virtual function to collect sensor data. 
## Should return an Array[float] of size matching network_config.input_size.
func collect_sensors() -> Array[float]:
	return []

## Virtual function to apply the actions calculated by the MLP.
## [param action_values] is an Array[float] of size matching network_config.output_size.
func _receive_actions(action_values: Array[float]) -> void:
	pass

## Sets the current reward for training.
func set_reward(value: float) -> void:
	reward = value

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	if not network_config:
		return
		
	# 1. Collect inputs
	var inputs = collect_sensors()
	
	if inputs.is_empty():
		return
		
	# 2. Logic for inference or training would go here
	# (Future implementation: Interfacing with GPU/CPU MLP)
	
	# 3. Apply outputs (Placeholder logic for now)
	var placeholder_outputs: Array[float] = []
	placeholder_outputs.resize(network_config.output_size)
	placeholder_outputs.fill(0.0)
	
	_receive_actions(placeholder_outputs)
