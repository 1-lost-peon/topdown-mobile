extends Node3D

class_name  Level

@export var enemy_spawn_locations: Node3D
@export var player_spawn_locations: Node3D
@export var rally_point: RallyPoint
@export var enemy_spawn_timer: Timer


func get_player_spawn_location() -> Vector3:
	return _get_random_spawn_location(player_spawn_locations.get_children())


func get_enemy_spawn_location() -> Vector3:
	return _get_random_spawn_location(enemy_spawn_locations.get_children())


func _get_random_spawn_location(locations: Array) -> Vector3:
	var rng = RandomNumberGenerator.new()
	var random_index = rng.randi_range(0, locations.size() - 1)
	return locations[random_index].global_position
