extends Node3D

var players: Array[Node]

func _ready() -> void:
	players = get_tree().get_nodes_in_group("players")


func _physics_process(delta: float) -> void:
	players = players.filter(func(p): return is_instance_valid(p))
	
	if players.is_empty():
		return
	
	global_position = global_position.move_toward(players[0].global_position, 3 * delta)

func _on_area_3d_body_shape_entered(_body_rid: RID, body: Node3D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.is_in_group("players"):
		body.died()
