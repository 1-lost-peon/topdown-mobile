extends Node

signal game_found(game)

const DISCOVERY_PORT := 9999
const DISCOVERY_CLIENT_PORT := 9998

var broadcast_udp := PacketPeerUDP.new()
var discovery_udp := PacketPeerUDP.new()
var searching_for_server: bool

var game_port
var ip_address

var loading
var utility

#
#start_discovery_listener()
#process_discovery_requests()
#start_game_discovery()
#discover_game()
#process_discovery_responses()
#get_lan_broadcast_ip()


func _init(new_loading, new_utility, new_ip_address, new_game_port) -> void:
	loading = new_loading
	utility = new_utility
	ip_address = new_ip_address
	game_port = new_game_port


func _ready():
	searching_for_server = true


func get_lan_broadcast_ip() -> String:
	var ip = utility.get_local_lan_ip()
	var parts = ip.split(".")

	if parts.size() != 4:
		return "255.255.255.255"

	return "%s.%s.%s.255" % [parts[0], parts[1], parts[2]]	


### Server will be listening for clients to connect
func start_discovery_listener() -> void:
	discovery_udp.set_broadcast_enabled(true)

	var error := discovery_udp.bind(DISCOVERY_PORT, "0.0.0.0")

	if error != OK:
		utility.log("Server discovery bind failed:", error)
		return

	utility.log("Server discovery listener started on port:", DISCOVERY_PORT)


func process_discovery_requests() -> void:
	while discovery_udp.get_available_packet_count() > 0:
		var packet := discovery_udp.get_packet()
		var text := packet.get_string_from_utf8()
		var data = JSON.parse_string(text)

		if not data:
			continue

		if data.get("type", "") != "discover_request":
			continue

		var client_ip := discovery_udp.get_packet_ip()
		var client_port := discovery_udp.get_packet_port()

		utility.log("Discovery request from:", client_ip, client_port)

		var response := {
			"type": "discover_response",
			"name": "Josh's super cool game",
			"ip": ip_address,
			"port": game_port,
		}

		var response_data := JSON.stringify(response).to_utf8_buffer()

		discovery_udp.set_dest_address(client_ip, client_port)
		var error := discovery_udp.put_packet(response_data)

		if error != OK:
			utility.log("Discovery response failed:", error)
		else:
			utility.log("Discovery response sent to:", client_ip, client_port)


func start_game_discovery() -> void:
	loading.set_step(loading.Step.SEARCHING_FOR_SERVER)
	utility.log("Trying to start discovery...")

	if OS.has_feature("server"):
		utility.log("Skipped discovery because this is server build.")
		return

	discovery_udp.set_broadcast_enabled(true)

	var error := discovery_udp.bind(DISCOVERY_CLIENT_PORT, "0.0.0.0")

	if error != OK:
		loading.set_step(loading.Step.FAILED, "Could not start server discovery.")
		utility.log("Client discovery bind failed:", error)
		return

	utility.log("Client discovery started on port:", DISCOVERY_CLIENT_PORT)


func discover_game() -> void:
	var request := {
		"type": "discover_request"
	}

	var data := JSON.stringify(request).to_utf8_buffer()
	var broadcast_ip := get_lan_broadcast_ip()

	discovery_udp.set_dest_address(broadcast_ip, DISCOVERY_PORT)
	var error := discovery_udp.put_packet(data)

	if error != OK:
		utility.log("Discovery request failed:", error)
	else:
		utility.log("Discovery request sent:", broadcast_ip, DISCOVERY_PORT)


func process_discovery_responses() -> void:
	while discovery_udp.get_available_packet_count() > 0:
		var packet := discovery_udp.get_packet()
		var text := packet.get_string_from_utf8()
		var data = JSON.parse_string(text)

		if not data:
			continue

		if data.get("type", "") != "discover_response":
			continue

		utility.log("Found game:", data.name, data.ip, data.port)
		searching_for_server = false
		loading.set_step(loading.Step.SERVER_FOUND, "Found server: %s" % data.name)
		game_found.emit(data)
