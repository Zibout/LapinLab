extends Resource
class_name MLPConfig

enum Activation {
	SIGMOID,
	RELU,
	TANH,
	LEAKY_RELU,
	IDENTITY
}

@export_group("Dimensions")
@export var input_size: int = 8
@export var output_size: int = 4

@export_group("Architecture")
## Array of channel counts for each hidden layer (e.g. [64, 64])
@export var hidden_layers: Array[int] = [64, 64]
@export var hidden_activation: Activation = Activation.RELU
@export var output_activation: Activation = Activation.SIGMOID
