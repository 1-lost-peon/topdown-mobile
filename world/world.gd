extends Node3D

@export var enemy: PackedScene
@export var level_scene: PackedScene
@onready var spawn_locations: Array[Vector3]

var level: Node

func spawn_level() -> void:
	level = level_scene.instantiate()	
	#level.name = str(peer_id)
	add_child(level, true)
	NetworkHandling.log_message("World spawned in")

#func _ready() -> void:
	#spawn_level()
	#for location in $SpawnLocations.get_children():
		#spawn_locations.append(location.global_position)
		#
#func spawn_player_in_world(player: Node3D) -> void:
	#var pos := new_spawn_location()
	#print("chosen spawn:", pos)
	#print("before:", player.global_position)
	#player.global_position = pos
	#if player is CharacterBody3D:
		#player.velocity = Vector3.ZERO
	#print("after:", player.global_position)
	#
#
#func _on_enemy_timer_timeout():
	#var players = get_tree().get_nodes_in_group("players")
	#if players:
		#var enemy_node: Node = enemy.instantiate()	
		#add_child(enemy_node)
#
#
#func new_spawn_location() -> Vector3:
	#print("spawn_locations: ", spawn_locations)
	#var rnd_index := randi_range(0, spawn_locations.size() - 1)
	#return spawn_locations[rnd_index]
