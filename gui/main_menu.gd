extends Control

signal game_joined
signal server_started

@onready var line_edit: LineEdit = $LineEdit


func _on_start_server_pressed() -> void:
	NetworkHandling.start_server()
	server_started.emit()
	queue_free()


func _on_join_game_pressed() -> void:
	#NetworkHandling.start_client()
	if line_edit.text != "":
		NetworkHandling.join_server(line_edit.text)
		game_joined.emit()
		queue_free()
