extends Node3D

signal player_extracted

var extraction_time: int = 5
var is_extracting: bool = false
var can_extract: bool = false

func _process(_delta: float) -> void:
	if multiplayer.get_unique_id() == 1: return
	if is_multiplayer_authority():
		#Network.log_message("extracting under server")
		if is_extracting and can_extract:
			Network.log_message("extracting in", extraction_time)
			if extraction_time == 0:
				Network.log_message("extracted")
				player_extracted.emit()
			else:
				extraction_time -= 1
		else: 
			extraction_time = 5

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		is_extracting = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("players"):
		is_extracting = false
