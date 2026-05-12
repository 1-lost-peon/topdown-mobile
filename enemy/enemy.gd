extends Node3D

@export var speed: float = 3.0

var players: Array[Node]

func _ready() -> void:
	add_to_group("enemies")


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	if players.is_empty():
		return
	
	var closest_player: Node3D = null
	var closest_distance := INF
	
	for player in players:
		if player == null or player.is_dead:
			continue
		
		var distance := global_position.distance_squared_to(player.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_player = player
	
	if closest_player != null:
		global_position = global_position.move_toward(
			closest_player.global_position,
			speed * delta
		)


func _on_area_3d_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if !is_multiplayer_authority():
		return
	
	if body.is_in_group("players"):
		body.died()


func _on_search_area_3d_body_entered(body: Node3D) -> void:
	if !is_multiplayer_authority():
		return
	
	if body.is_in_group("players") and !players.has(body):
		players.append(body)


func _on_search_area_3d_body_exited(body: Node3D) -> void:
	if !is_multiplayer_authority():
		return
	
	if body.is_in_group("players"):
		players.erase(body)
