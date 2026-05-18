extends Screen

signal game_joined

var server_info: Dictionary

@onready var name_line: LineEdit = $VBoxContainer/NameLine


func _on_join_game_pressed() -> void:
	#Network.join_game(server_info.ip, name_line.text) # This one should probably be on the previous screen?
	game_joined.emit(name_line.text)
	end_scene()
