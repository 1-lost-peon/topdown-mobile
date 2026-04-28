extends Node3D

@onready var spawn_locations: Array[Vector3]
var spawn_index: int = spawn_locations.size() + 1

func _ready() -> void:
	for location in $SpawnLocations.get_children():
		spawn_locations.append(location.global_position)
		
func spawn_player_in_world(player: Node3D) -> void:
	var pos := new_spawn_location()
	print("chosen spawn:", pos)
	print("before:", player.global_position)
	player.global_position = pos
	if player is CharacterBody3D:
		player.velocity = Vector3.ZERO
	print("after:", player.global_position)

func get_spawn_location() -> Vector3:
	if spawn_index >= spawn_locations.size() - 1:
		spawn_index = 0
	else:
		spawn_index += 1
	
	return spawn_locations[spawn_index]
#
#func _on_enemy_timer_timeout():
	#var players = get_tree().get_nodes_in_group("players")
	#if players:
		#var enemy_node: Node = enemy.instantiate()	
		#add_child(enemy_node)


func new_spawn_location() -> Vector3:
	print("spawn_locations: ", spawn_locations)
	var rnd_index := randi_range(0, spawn_locations.size() - 1)
	return spawn_locations[rnd_index]
