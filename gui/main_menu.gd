extends Control

signal game_joined
signal server_started
signal scene_changed

@onready var line_edit: LineEdit = $LineEdit


func _on_start_server_pressed() -> void:
	Network.create_game()
	server_started.emit()
	end_scene()


func _on_join_game_pressed() -> void:
	Network.join_game(line_edit.text)
	game_joined.emit()
	end_scene()


func end_scene() -> void:
	scene_changed.emit(GUI.Scene.EMPTY)
	queue_free()
