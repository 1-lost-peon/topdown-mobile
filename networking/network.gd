extends Node

signal player_connected(peer_id)
signal game_found(game)

enum Role {
	SERVER,
	LOCAL_PLAYER,
	REMOTE_PLAYER,
}

const DEFAULT_SERVER_IP = "192.168.1.191"
const MAX_CONNECTIONS = 20
const PLAYER = preload("res://player/player.tscn")
const GAME_PORT = 7000
const DISCOVERY_PORT := 9999


var players_loaded = 0
var ip_address: String = get_local_lan_ip()
var broadcast_udp := PacketPeerUDP.new()
var discovery_udp := PacketPeerUDP.new()
var players_info: Dictionary




func _ready():
	multiplayer.peer_connected.connect(_on_player_connected) # Happens on existing clients
	#multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok) # Happens locally...
	#multiplayer.connection_failed.connect(_on_connected_fail)
	#multiplayer.server_disconnected.connect(_on_server_disconnected)


func get_local_lan_ip() -> String:
	var interfaces = IP.get_local_interfaces()

	for iface in interfaces:
		var friendly := str(iface.get("friendly", "")).to_lower()
		var addresses: Array = iface.get("addresses", [])

		if "wi-fi" in friendly or "wifi" in friendly or "wlan" in friendly or "wireless" in friendly:
			for address in addresses:
				var ip := str(address)

				# IPv4 only
				if "." in ip and ":" not in ip:
					# Avoid link-local fallback addresses like 169.254.x.x
					if not ip.begins_with("169.254."):
						return ip

	return "127.0.0.1"


func get_lan_broadcast_ip() -> String:
	var ip := get_local_lan_ip()
	var parts := ip.split(".")

	if parts.size() != 4:
		return "255.255.255.255"

	return "%s.%s.%s.255" % [parts[0], parts[1], parts[2]]	


func join_game(address: String, username: String):
	if address.is_empty():
		address = ip_address
	
	var peer = ENetMultiplayerPeer.new()
	
	var error = peer.create_client(address, GAME_PORT)
	if error:
		return error
	
	multiplayer.multiplayer_peer = peer
	
	players_info[multiplayer.get_unique_id()] = username
	#register_player.rpc_id(1, multiplayer.get_unique_id(), username)


func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(GAME_PORT, MAX_CONNECTIONS)
	
	if error:
		return error
	
	multiplayer.multiplayer_peer = peer
		
	log_message("Server created.")
	log_message("Local Server IP: ", ip_address)


func _on_connected_ok():
	log_message("Connected To Server | I've succesfully connected to the server.")
	add_player_info.rpc_id(1, players_info[multiplayer.get_unique_id()])


func _on_player_connected(id):
	log_message("Peer Connected | Player", id, "has successfully connected to me.")
	#log_message(players_info)
	#if is_multiplayer_authority():
		#player_connected.emit(1, players_info)
	#else:
		#add_player_info.rpc_id(1, players_info[multiplayer.get_unique_id()])


@rpc("any_peer")
func add_player_info(username: String):
	var player_peer_id = multiplayer.get_remote_sender_id()
	players_info[player_peer_id] = username
	log_message("Player", player_peer_id, "has been registered as", username)
	player_connected.emit(1, players_info)


func get_network_role(peer_id: int) -> Role:
	if multiplayer.is_server():
		return Role.SERVER
	
	if multiplayer.get_unique_id() == peer_id:
		return Role.LOCAL_PLAYER
	
	return Role.REMOTE_PLAYER


func start_game_broadcast():
	#if address.is_empty():
		#address = ip_address
	broadcast_udp.set_broadcast_enabled(true)


func broadcast_game() -> void:
	var msg := {
		"name": "Josh's super cool game",
		"ip": ip_address,
		"port": GAME_PORT,
		"players": multiplayer.get_peers().size() + 1,
		"max_players": MAX_CONNECTIONS
	}

	var data := JSON.stringify(msg).to_utf8_buffer()
	var broadcast_ip := get_lan_broadcast_ip()

	broadcast_udp.set_dest_address(broadcast_ip, DISCOVERY_PORT)
	var error := broadcast_udp.put_packet(data)

	if error != OK:
		log_message("Broadcast failed:", error)
	else:
		log_message("Broadcast sent:", broadcast_ip, msg.ip, msg.port)


func start_game_discovery() -> void:
	log_message("Trying to start discovery...")

	if OS.has_feature("server"):
		log_message("Skipped discovery because this is server build.")
		return

	discovery_udp.set_broadcast_enabled(true)

	var error := discovery_udp.bind(DISCOVERY_PORT, "0.0.0.0")

	if error != OK:
		log_message("Discovery bind failed:", error)
		return

	log_message("Discovery receiver started on port:", DISCOVERY_PORT)


func discover_game() -> void:
	while discovery_udp.get_available_packet_count() > 0:
		var packet := discovery_udp.get_packet()
		var text := packet.get_string_from_utf8()
		var data = JSON.parse_string(text)

		if data:
			log_message("Found game:", data.name, data.ip, data.port)
			game_found.emit(data)


func log_message(...args) -> void:
	var role: String= "SERVER" if OS.has_feature("server") else "CLIENT"
	var peer_id := multiplayer.get_unique_id()

	var parts: PackedStringArray = []
	for arg in args:
		parts.append(str(arg))

	print("[%s][%s] %s" % [role, peer_id, " ".join(parts)])
