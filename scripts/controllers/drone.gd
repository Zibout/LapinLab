extends RigidBody3D
class_name Drone

@export var thrust_power: float = 8.0

@export var torque_coefficient: float = 0.1

@onready var motors = [
	$FrontLeft, $FrontRight,
	$RearLeft, $RearRight
]

var last_received_input: Array[float] = [0.0, 0.0, 0.0, 0.0]
var motor_thrusts: Array[float] = [0.0, 0.0, 0.0, 0.0]

@onready var throttle := 0.0

# To handle drone reset
@onready var start_transform = global_transform
var reset_requested = false

func set_inputs(input_data: Array[float]) -> void:
	last_received_input = input_data
	
# Array is in the form of: [FL, FR, RL, RR]
func get_output() -> Array[float]:
	var ret: Array[float] = [0.0]
	return ret

func request_rest():
	reset_requested = true

func _reset_to_initial_state():
	transform = start_transform
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	throttle = 0.0
	reset_requested = false

func _physics_process(delta: float) -> void:
	
	if reset_requested:
		_reset_to_initial_state()
	
	for i in 4:
		motor_thrusts[i] = last_received_input[i]
	
	# 3. Apply forces to the RigidBody via Jolt
	for i in 4:
		var marker = motors[i]
		var power = clamp(motor_thrusts[i], 0, 2) * thrust_power
		
		# Vertical Lift: Apply force upwards relative to the drone's orientation
		var lift_direction = global_transform.basis.y
		apply_force(lift_direction * power, marker.global_position - global_position)
		
		# Reactive Torque: To make the drone rotate (Yaw)
		# Motors spin in opposite directions, so we apply a small rotational force
		var spin_dir = -1
		if i == 0 or i == 3:
			spin_dir = 1
		var torque_vector = global_transform.basis.y * (power * torque_coefficient * spin_dir)
		apply_torque(torque_vector)
