extends Node

signal player_connected(peer_id)

const DEFAULT_SERVER_IP = "192.168.1.191"
const MAX_CONNECTIONS = 20
const PLAYER = preload("res://player/player.tscn")
const PORT = 7000

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
		
	log_message("Server created.")
	log_message("Local Server IP: ", ip_address)


func _on_connected_ok():
	log_message("Connected To Server | I've succesfully connected to the server.")


func _on_player_connected(id):
	log_message("Peer Connected | Player", id, "has successfully connected to me.")
	if is_multiplayer_authority():
		player_connected.emit(1, id)


func log_message(...args) -> void:
	var role: String= "SERVER" if OS.has_feature("server") else "CLIENT"
	var peer_id := multiplayer.get_unique_id()

	var parts: PackedStringArray = []
	for arg in args:
		parts.append(str(arg))

	print("[%s][%s] %s" % [role, peer_id, " ".join(parts)])
