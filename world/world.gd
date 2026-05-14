extends Node3D

signal scene_loaded
signal scene_changed
signal game_ended

enum State {
	LOADING,
	PLAYING,
	PAUSING,
	MENU,
}

@export var enemy_scene: PackedScene
@export var level_scene: PackedScene
@export var player_scene: PackedScene
@export var pickup_scene: PackedScene

var is_client_loaded: bool
var level: Node
var state: State

@onready var enemies: Node3D = $Enemies
@onready var players: Node3D = $Players
@onready var pickups: Node3D = $Pickups


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
		for player in players.get_children():
			if player.coins != 0:
				level.extraction_spot.can_extract = true

	if state == State.PAUSING:
		pass
	# IF STATE == PAUSED


# This only runs on the server. It is replicated to clients.
func spawn_level() -> void:
	level = level_scene.instantiate()	
	add_child(level, true)
	level.extraction_spot.player_extracted.connect(end_game)
	
	if multiplayer.get_unique_id() == 1:
		level.enemy_timer.timeout.connect(on_enemy_spawn_timer_timeout)


# This only runs on the server. It is replicated to clients.
func spawn_player(player_name) -> void:
	Network.log_message("Spawning player", player_name, "into the world...")
	
	var player = player_scene.instantiate()
	player.name = str(player_name)
	players.add_child(player, true)
	player.global_position = level.get_spawn_location()
	player.respawn_timer.timeout.connect(on_player_respawn_timer_timeout.bind(player))
	player.player_died.connect(on_player_died.bind(player))


func on_player_respawn_timer_timeout(player: Node) -> void:
	player.global_position = level.get_spawn_location()


# This only runs on the server. It is replicated to clients.
func on_enemy_spawn_timer_timeout() -> void:
	Network.log_message("Spawning enemies into the world...")
	
	var enemy = enemy_scene.instantiate()
	enemy.name = "Enemy"
	enemies.add_child(enemy, true)
	enemy.global_position = level.get_enemy_spawn_location()


func on_player_died(player) -> void:
	Network.log_message("Spawning", player.coins, "coin(s) into the world...")
	
	for x in player.coins:
		var pickup = pickup_scene.instantiate()
	#player.name = str(player_name)
		pickups.add_child(pickup, true)
		pickup.global_position = player.global_position
	#player.respawn_timer.timeout.connect(on_player_respawn_timer_timeout.bind(player))
	#player.player_died.connect(on_player_respawn_timer_timeout.bind(player))


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
	# If players have more than 1 coin
	# if all players are dead or leave with no coins
	if players:
		var survivors = players.get_children().count(func(p): return not p.is_dead)
		var resources_collected = players.get_children().reduce(
			func(total, p): return total + p.coins, 
				0
		)
		
		var status = "Failed" if (survivors == 0 or resources_collected == 0) else "Success"
		
		var results = {
			"status": status,
			"survivors": survivors,
			"resources": resources_collected,
		}
		
		Network.log_message("End game")
		scene_changed.emit(GUI.Scene.RESULTS)
		game_ended.emit(results)
		get_tree().paused = true
