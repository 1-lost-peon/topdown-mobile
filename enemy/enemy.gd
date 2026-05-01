extends Node3D

@export var speed: float = 3.0

var players: Array[Node]

func _ready() -> void:
	add_to_group("enemies")


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	players = get_tree().get_nodes_in_group("players")
	players = players.filter(func(p): return is_instance_valid(p))
	
	if players.is_empty():
		return
	
	if not players[0].is_dead:
		global_position = global_position.move_toward(players[0].global_position, speed * delta)

func _on_area_3d_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if !is_multiplayer_authority():
		return
	
	if body.is_in_group("players"):
		body.died()
