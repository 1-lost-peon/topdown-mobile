extends Screen

func _process(_delta: float) -> void:
	if can_end_screen:
		end_scene()
