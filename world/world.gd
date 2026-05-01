extends Node3D

signal scene_loaded
signal scene_changed

enum State {
	LOADING,
	PLAYING,
	PAUSING,
	MENU,
}

@export var enemy_scene: PackedScene
@export var level_scene: PackedScene
@export var player_scene: PackedScene

var is_client_loaded: bool
var level: Node
var players: Node
var state: State

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner


func _ready() -> void:
	players = Node.new()
	players.name = "Players"
	add_child(players)
	multiplayer_spawner.spawn_path = players.get_path()


func _process(_delta: float) -> void:
	if state == State.MENU:
		pass
	if state == State.LOADING: # I need a way to capture the client
		if !is_multiplayer_authority():
			check_if_scene_loaded()
		if is_client_loaded:
			scene_loaded.emit()
			state = State.PLAYING
	if state == State.PLAYING:
		var players = get_tree().get_nodes_in_group("players")
		players = players.filter(func(p): return is_instance_valid(p))
		
		if players.is_empty():
			return
		
		if players[0].coins == 1:
			level.extraction_spot.can_extract = true

	if state == State.PAUSING:
		pass
	# IF STATE == PAUSED


# This only runs on the server. It is replicated to clients.
func spawn_level() -> void:
	level = level_scene.instantiate()	
	add_child(level, true)
	level.extraction_spot.player_extracted.connect(end_game)


# This only runs on the server. It is replicated to clients.
func spawn_player(player_name) -> void:
	Network.log_message("Spawning player", player_name, "into the world...")
	
	var player = player_scene.instantiate()
	player.name = str(player_name)
	players.add_child(player, true)
	player.global_position = level.get_spawn_location()


@rpc("any_peer")
func set_is_client_loaded(loaded: bool) -> void:
	is_client_loaded = loaded


func check_if_scene_loaded() -> void:
	if level == null or not level.is_node_ready():
		return
	
	for player in players.get_children():
		if not player.is_node_ready():
			return
	
	# Gives the network a chance to fully load
	await get_tree().create_timer(0.5).timeout
	
	is_client_loaded = true
	if multiplayer.is_server():
		set_is_client_loaded.rpc_id(1, is_client_loaded)


func end_game() -> void:
	Network.log_message("Wins game")
	scene_changed.emit(GUI.Scene.MAIN_MENU)
	get_tree().paused = true
