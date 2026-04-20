extends Node

enum CAPTURE_TYPE { FACE, BODY }

signal mocap_data_received(tracking_data: Dictionary)

signal status_changed(port: int, is_active: bool)

@export var host_ports: Array[int] = [39539, 39540]
@export var timeout_seconds: float = 2.0

const FACE_BLEND_SHAPE_NAMES = [
	"browDown_L", "browDown_R", "browInnerUp", "browOuterUp_L", "browOuterUp_R",
	"cheekPuff", "cheekSquint_L", "cheekSquint_R",
	"eyeBlink_L", "eyeBlink_R", "eyeLookDown_L", "eyeLookDown_R",
	"eyeLookIn_L", "eyeLookIn_R", "eyeLookOut_L", "eyeLookOut_R",
	"eyeLookUp_L", "eyeLookUp_R", "eyeSquint_L", "eyeSquint_R", "eyeWide_L", "eyeWide_R",
	"jawForward", "jawLeft", "jawOpen", "jawRight",
	"mouthClose", "mouthDimple_L", "mouthDimple_R", "mouthFrown_L", "mouthFrown_R",
	"mouthFunnel", "mouthLeft", "mouthLowerDown_L", "mouthLowerDown_R", "mouthPress_L", "mouthPress_R",
	"mouthPucker", "mouthRight", "mouthRollLower", "mouthRollUpper", "mouthShrugLower", "mouthShrugUpper",
	"mouthSmile_L", "mouthSmile_R", "mouthStretch_L", "mouthStretch_R", "mouthUpperUp_L", "mouthUpperUp_R",
	"noseSneer_L", "noseSneer_R", "tongueOut"
]

## Dictionary structure: port (int) -> { "socket": PacketPeerUDP, "last_received": float, "is_active": bool }
var _sockets_state: Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for port in host_ports:
		_setup_socket(port)


func _setup_socket(port: int) -> void:
	# Close existing if any
	if _sockets_state.has(port):
		_sockets_state[port].socket.close()
	
	var socket = PacketPeerUDP.new()
	var err = socket.bind(port)
	
	var state = {
		"socket": socket,
		"last_received": -1.0,
		"is_active": false
	}
	
	if err == OK:
		print("MocapLab: Listening on port ", port)
	else:
		push_error("MocapLab: Failed to bind to port %d. Error code: %d" % [port, err])
	
	_sockets_state[port] = state


func _process(_delta: float) -> void:
	var current_time = Time.get_unix_time_from_system()
	
	for port in _sockets_state.keys():
		var state = _sockets_state[port]
		var socket: PacketPeerUDP = state.socket
		
		# 1. Individual Recovery Check
		if not socket.is_bound():
			push_warning("MocapLab: Port %d lost binding. Attempting recovery..." % port)
			_setup_socket(port)
			continue # Skip this frame for this port
			
		# 2. Poll Packets
		var received_this_frame = false
		while socket.get_available_packet_count() > 0:
			var packet = socket.get_packet()
			_handle_packet(packet, port)
			received_this_frame = true
			
		# 3. Status/Timeout Management
		if received_this_frame:
			state.last_received = current_time
			if not state.is_active:
				state.is_active = true
				status_changed.emit(port, true)
				print("MocapLab: Port %d reception active." % port)
		elif state.is_active and (current_time - state.last_received > timeout_seconds):
			state.is_active = false
			status_changed.emit(port, false)
			print("MocapLab: Port %d reception timed out." % port)


## Manually restarts all UDP listeners.
func restart_all_listeners() -> void:
	for port in host_ports:
		_setup_socket(port)


## Restarts a specific port listener.
func restart_listener(port: int) -> void:
	_setup_socket(port)


func _handle_packet(packet: PackedByteArray, port: int) -> void:
	if packet.size() % 4 != 0:
		push_warning("MocapLab: Received malformed packet on port %d" % port)
		return
	
	var float_array = packet.to_float32_array()
	if float_array.size() < 2:
		return
		
	var timestamp = float_array[0]
	var type = CAPTURE_TYPE.FACE if is_equal_approx(float_array[1], 0.0) else CAPTURE_TYPE.BODY
	var tracking_data: Dictionary
	
	if type == CAPTURE_TYPE.FACE:
		if float_array.size() < 61: # 1 (ts) + 1 (type) + 3 (pos) + 4 (quat) + 52 (bs)
			push_warning("MocapLab: Face packet on port %d is too small" % port)
			return
			
		# Position is Vector3 (3 floats)
		var position = Vector3(float_array[2], float_array[3], float_array[4])
		# Quaternion is x, y, z, w (4 floats)
		var orientation = Quaternion(float_array[5], float_array[6], float_array[7], float_array[8])
		# Blendshapes are 52 floats starting at index 9
		var blendshapes = {}
		var blendshape_weights = float_array.slice(9)
		var count = min(blendshape_weights.size(), FACE_BLEND_SHAPE_NAMES.size())
		for i in range(count):
			blendshapes[FACE_BLEND_SHAPE_NAMES[i]] = blendshape_weights[i]
		
		tracking_data = {
			"type": type,
			"timestamp": timestamp,
			"position": position,
			"orientation": orientation,
			"blendshapes": blendshapes
		}
	else:
		# Default format for BODY
		tracking_data = {
			"type": type,
			"timestamp": timestamp,
			"data": float_array.slice(2)
		}
	
	mocap_data_received.emit(tracking_data)
