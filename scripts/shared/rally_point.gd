extends Node3D

class_name RallyPoint

var list_of_players: Array[Player]
var load_time: float = 5.0

@onready var progress_bar: ProgressBar = $ProgressBar


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		list_of_players.append(body)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("players"):
		list_of_players.erase(body)
