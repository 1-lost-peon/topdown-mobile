extends Control

signal screen_changed

func _on_start_server_pressed() -> void:
	NetworkHandling.start_server()
	queue_free()


func _on_join_game_pressed() -> void:
	NetworkHandling.start_client()
	screen_changed.emit()
	queue_free()
