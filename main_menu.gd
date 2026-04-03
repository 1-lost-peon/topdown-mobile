extends Control

signal game_joined

func _on_start_server_pressed() -> void:
	NetworkHandling.start_server()
	queue_free()


func _on_join_game_pressed() -> void:
	NetworkHandling.start_client()
	game_joined.emit()
	queue_free()
