extends Node

# Signal to send data to your 3D character
signal face_data_received(blend_shapes, orientation)

const PORT = 8765
var tcp_server = TCPServer.new()
var socket = WebSocketPeer.new()

# The exact same order as defined in Swift
const BLEND_SHAPE_NAMES = [
	"browDownLeft", "browDownRight", "browInnerUp", "browOuterUpLeft", "browOuterUpRight",
	"cheekPuff", "cheekSquintLeft", "cheekSquintRight",
	"eyeBlinkLeft", "eyeBlinkRight", "eyeLookDownLeft", "eyeLookDownRight",
	"eyeLookInLeft", "eyeLookInRight", "eyeLookOutLeft", "eyeLookOutRight",
	"eyeLookUpLeft", "eyeLookUpRight", "eyeSquintLeft", "eyeSquintRight", "eyeWideLeft", "eyeWideRight",
	"jawForward", "jawLeft", "jawOpen", "jawRight",
	"mouthClose", "mouthDimpleLeft", "mouthDimpleRight", "mouthFrownLeft", "mouthFrownRight",
	"mouthFunnel", "mouthLeft", "mouthLowerDownLeft", "mouthLowerDownRight", "mouthPressLeft", "mouthPressRight",
	"mouthPucker", "mouthRight", "mouthRollLower", "mouthRollUpper", "mouthShrugLower", "mouthShrugUpper",
	"mouthSmileLeft", "mouthSmileRight", "mouthStretchLeft", "mouthStretchRight", "mouthUpperUpLeft", "mouthUpperUpRight",
	"noseSneerLeft", "noseSneerRight", "tongueOut"
]

func _ready():
	# Start listening on the port
	if tcp_server.listen(PORT) != OK:
		print("Error: Could not start server on port " + str(PORT))
		set_process(false)
	else:
		print("Server listening on port " + str(PORT))

func _process(_delta):
	# 1. Check for new incoming connections
	if tcp_server.is_connection_available():
		var conn = tcp_server.take_connection()
		print("Client connected: " + conn.get_connected_host())
		
		# Upgrade the raw TCP connection to a WebSocket
		# This performs the WebSocket handshake automatically
		socket.accept_stream(conn)

	# 2. Poll the socket for updates
	socket.poll()
	
	# 3. Read data if the socket is open
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count() > 0:
			var packet_data: PackedByteArray = socket.get_packet()
			parse_binary_data(packet_data)
			#var packet_data = socket.get_packet().get_string_from_utf8()
			#parse_data(packet_data)
			
	
	elif socket.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		# Optional: Handle disconnection logic here
		pass
		
func parse_binary_data(packet_data: PackedByteArray):
	# We expect 55 floats * 4 bytes = 220 bytes. 
	# Reject malformed packets to prevent crashes.
	if packet_data.size() != 220:
		return
		
	# 1. Extract Orientation (First 3 floats at byte offsets 0, 4, and 8)
	var orientation = {
		"pitch": packet_data.decode_float(0),
		"yaw": packet_data.decode_float(4),
		"roll": packet_data.decode_float(8)
	}
	var byte_offset = 12
	
	# 2. Extract Blend Shapes (Next 52 floats starting at byte offset 12)
	var blend_shapes = {}
	for i in range(52):
		var value = packet_data.decode_float(byte_offset)
		byte_offset += 4
		var shape_name = BLEND_SHAPE_NAMES[i]
		blend_shapes[shape_name] = value
		
	# Emit the dictionary to your character script just like before
	emit_signal("face_data_received", blend_shapes, orientation)

#func parse_data(json_string):
	#var json = JSON.new()
	#var error = json.parse(json_string)
	#
	#if error == OK:
		#var data = json.data
		#var blend_shapes = data.get("blendShapes", {})
		#var orientation = data.get("orientation", {})
		#
		## Emit the signal so your character script can use it
		#emit_signal("face_data_received", blend_shapes, orientation)
	#else:
		#print("JSON Parse Error: ", json.get_error_message())
