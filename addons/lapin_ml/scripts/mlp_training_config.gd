extends Resource
class_name MLPTrainingConfig

@export_group("Hyperparameters")
@export var learning_rate: float = 0.001
@export var batch_size: int = 32
@export var epochs: int = 100

@export_group("Optimization")
enum Optimizer { SGD, ADAM }
@export var optimizer: Optimizer = Optimizer.ADAM
