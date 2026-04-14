extends Node

#const IP_ADDRESS: String = "127.0.0.1"
#const IP_ADDRESS: String = "192.168.1.191"
const PORT: int = 42069
const PLAYER = preload("res://player/player.tscn")


var peer: ENetMultiplayerPeer =  ENetMultiplayerPeer.new()
var ip_address: String = get_local_lan_ip()

func get_local_lan_ip() -> String:
	var interfaces = IP.get_local_interfaces()
	for iface in interfaces:
		var friendly := str(iface.get("friendly", "")).to_lower()
		var addresses = iface.get("addresses", [])
		if "wi-fi" in friendly or "wifi" in friendly or "wlan" in friendly or "wireless" in friendly:
			return addresses[1]
		
	return "127.0.0.1"


func start_server() -> void:
	var error: Error = peer.create_server(PORT)
	if error != OK:
		push_error("Failed to start server: " + str(error))
		return
	
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_player)
	
	log_message("Server started")
	log_message("Local Server IP: ", ip_address)



func join_server(ip: String) -> void:
	var error := peer.create_client(ip, PORT)
	if error != OK:
		push_error("Failed to connect: " + str(error))
		return

	log_message("Joining server on", ip, "with port", PORT)
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(remove_player)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

	multiplayer.multiplayer_peer = peer


func add_player(peer_id: int) -> void:
	if !multiplayer.is_server():
		return
	var world: Node = get_tree().current_scene.world
	if peer_id == 1:
		return
	
	log_message("Player", peer_id, "joining...")
	
	log_message("add_player called for peer", peer_id, "on server=", multiplayer.is_server())
	#log_message("Spawning player ", peer_id, " under ", get_path())
	var new_player = PLAYER.instantiate()
	new_player.name = str(peer_id)
	world.add_child(new_player, true)
	
	log_message("Player", peer_id, "joined.")


func remove_player(peer_id: int) -> void:
	if peer_id == 1:
		leave_server()
	
	var players: Array[Node] = get_tree().get_nodes_in_group("players")
	var player_to_remove = players.find_custom(func(item): return item.name == str(peer_id))
	if player_to_remove != -1:
		players[player_to_remove].queue_free()


func on_connected_to_server() -> void:
	var id: int = multiplayer.get_unique_id()
	log_message("Connecting Player", id, "to the server...")
	add_player(id)


func leave_server() -> void:
	multiplayer.multiplayer_peer.close()
	multiplayer.multiplayer_peer = null
	clean_up_signals()
	get_tree().reload_current_scene()


func clean_up_signals() -> void:
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(remove_player)
	multiplayer.connected_to_server.disconnect(on_connected_to_server)


func start_client() -> void:
	var error := peer.create_client(ip_address, PORT)
	if error != OK:
		push_error("Failed to connect: " + str(error))
		return
		
	multiplayer.multiplayer_peer = peer



func _on_connection_failed() -> void:
	log_message("Connection failed")

func _on_server_disconnected() -> void:
	log_message("Disconnected from server")


func log_message(...args) -> void:
	var role: String= "SERVER" if OS.has_feature("server") else "CLIENT"
	var peer_id := multiplayer.get_unique_id()

	var parts: PackedStringArray = []
	for arg in args:
		parts.append(str(arg))

	print("[%s][%s] %s" % [role, peer_id, " ".join(parts)])
