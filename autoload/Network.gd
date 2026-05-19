extends Node

signal player_connected(peer_id)

enum Role {
	SERVER,
	LOCAL_PLAYER,
	REMOTE_PLAYER,
}

const DEFAULT_SERVER_IP = "192.168.1.191"
const MAX_CONNECTIONS = 20
const PLAYER = preload("res://player/player.tscn")
const GAME_PORT = 7000

const NetLoading = preload("res://scripts/networking/netloading.gd")
const NetDiscovery = preload("res://scripts/networking/netdiscovery.gd")
const NetUtility = preload("res://scripts/networking/netutility.gd")

var players_loaded = 0
var ip_address: String

var players_info: Dictionary
var loading
var discovery
var utility


func _ready():
	multiplayer.peer_connected.connect(_on_player_connected) # Happens on existing clients
	#multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok) # Happens locally...
	#multiplayer.connection_failed.connect(_on_connected_fail)
	#multiplayer.server_disconnected.connect(_on_server_disconnected)
	loading = NetLoading.new()
	utility = NetUtility.new(multiplayer)
	ip_address = utility.get_local_lan_ip()
	discovery = NetDiscovery.new(loading, utility, ip_address, GAME_PORT)


func join_game(address: String):
	if address.is_empty():
		address = ip_address
	
	loading.set_step(loading.Step.CONNECTING)
	
	var peer = ENetMultiplayerPeer.new()
	
	var error = peer.create_client(address, GAME_PORT)
	if error:
		loading.set_step(loading.Step.FAILED, "Could not connect to server.")
		return error
	
	multiplayer.multiplayer_peer = peer
	
	players_info[multiplayer.get_unique_id()] = ""
	#register_player.rpc_id(1, multiplayer.get_unique_id(), username)


func create_game():
	var peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(GAME_PORT, MAX_CONNECTIONS)
	
	if error:
		return error
	
	multiplayer.multiplayer_peer = peer
		
	utility.log("Server created.")
	utility.log("Local Server IP: ", ip_address)


func _on_connected_ok():
	loading.set_step(loading.Step.CONNECTED)
	utility.log("Connected To Server | I've succesfully connected to the server.")
	loading.set_step(loading.Step.REGISTERING_PLAYER)
	#add_player_info.rpc_id(1, players_info[multiplayer.get_unique_id()])
	loading.set_step(loading.Step.READY)


func _on_player_connected(id):
	utility.log("Peer Connected | Player", id, "has successfully connected to me.")
	#log(players_info)
	#if is_multiplayer_authority():
		#player_connected.emit(1, players_info)
	#else:
		#add_player_info.rpc_id(1, players_info[multiplayer.get_unique_id()])


@rpc("any_peer")
func add_player_info(username: String):
	var player_peer_id := multiplayer.get_remote_sender_id()

	players_info[player_peer_id] = username

	utility.log("Player", player_peer_id, "has been registered as", username)

	player_connected.emit(1, { player_peer_id: username })
	loading.set_step(loading.Step.PLAYER_REGISTERED)


func get_network_role(peer_id: int) -> Role:
	if multiplayer.is_server():
		return Role.SERVER
	
	if multiplayer.get_unique_id() == peer_id:
		return Role.LOCAL_PLAYER
	
	return Role.REMOTE_PLAYER
