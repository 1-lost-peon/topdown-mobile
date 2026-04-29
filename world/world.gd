extends Node3D

@export var enemy_scene: PackedScene
@export var level_scene: PackedScene
@export var player_scene: PackedScene

var level: Node
var players: Node

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner


func _ready() -> void:
	players = Node.new()
	players.name = "Players"
	add_child(players)
	multiplayer_spawner.spawn_path = players.get_path()


func spawn_level() -> void:
	level = level_scene.instantiate()	
	add_child(level, true)


func spawn_player(player_name) -> void:
	Network.log_message("Spawning player", player_name, "into the world...")
	
	var player = player_scene.instantiate()
	player.name = str(player_name)
	players.add_child(player, true)
	player.global_position = level.get_spawn_location()
