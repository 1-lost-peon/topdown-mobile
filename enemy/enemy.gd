extends Node3D

var players: Array[Node]

func _ready() -> void:
	players = get_tree().get_nodes_in_group("players")
	if players:
		print(players)


func _physics_process(delta) -> void:
	global_position = global_position.move_toward(players[0].global_position, 3 * delta)
