extends Node

signal player_connected(peer_id, player_info)

const PORT = 7000
const DEFAULT_SERVER_IP = "192.168.1.191" # IPv4 localhost
const MAX_CONNECTIONS = 20
const PLAYER = preload("res://player/player.tscn")

var players = {}

var player_info = {"name": "Name"}

var players_loaded = 0

var ip_address: String = get_local_lan_ip()



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
		var addresses = iface.get("addresses", [])
		if "wi-fi" in friendly or "wifi" in friendly or "wlan" in friendly or "wireless" in friendly:
			return addresses[1]
		
	return "127.0.0.1"

func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, PORT)
	if error:
		return error
	multiplayer.multiplayer_peer = peer

func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		return error
	multiplayer.multiplayer_peer = peer
	
	player_info["name"] = "Server"
	
	players[1] = player_info
	player_connected.emit(1, player_info)
	
	log_message("Server created.")
	log_message("Local Server IP: ", ip_address)

func _on_connected_ok():
	#print("")
	#print("_on_connected_ok; from id ", multiplayer.get_unique_id())
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = player_info
	player_connected.emit(peer_id, player_info)
	#print(multiplayer.get_unique_id())
	log_message("Player", multiplayer.get_unique_id(), "has succesfully connected to the server.")

func _on_player_connected(id):
	log_message("Player", multiplayer.get_unique_id(), "has connected to", id)
	#print("")
	#print("_on_player_connected; new player id: ", id)
	_register_player.rpc_id(id, player_info) # Have the new client take existing info
	#print("spawn player", id, "into the server...")
	
	

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)
	log_message("Player", multiplayer.get_unique_id(), "has updated its player list", players)
	if multiplayer.get_remote_sender_id() == 1:
		_spawn_player.rpc_id(1, player_info)

@rpc("any_peer", "call_local", "reliable")
func _spawn_player(new_player_info):
	var peer_id: int = int(players.keys()[-1])
	
	if !multiplayer.is_server():
		return
	if peer_id == 1:
		return
		
	log_message("Player", multiplayer.get_unique_id(), "is spawning a player node")
		#if multiplayer.is_server():
		#return
	
	var world: Node = get_tree().current_scene.world
		
	#log_message("Spawning player ", peer_id, " under ", get_path())
	var new_player = PLAYER.instantiate()
	new_player.name = str(peer_id)
	world.add_child(new_player, true)
	new_player.global_position = world.level.get_spawn_location()


func log_message(...args) -> void:
	var role: String= "SERVER" if OS.has_feature("server") else "CLIENT"
	var peer_id := multiplayer.get_unique_id()

	var parts: PackedStringArray = []
	for arg in args:
		parts.append(str(arg))

	print("[%s][%s] %s" % [role, peer_id, " ".join(parts)])
