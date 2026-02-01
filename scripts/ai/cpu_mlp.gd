class_name CPU_MLP
extends RefCounted

var batch_size: int = 1

func _init(sizes: Array[int], lr: float = 0.001, random_seed: int = -1):
	pass
	
func forward(input_array: Array[float]) -> Array[float]:
	var tmp: Array[float]
	tmp.push_back(0.0)
	return tmp

func train(inputs: Array[float], targets: Array[float]):
	pass
