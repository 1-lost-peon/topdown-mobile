extends Screen

var game_joined

@onready var name_line: LineEdit = $VBoxContainer/NameLine


func _on_join_game_pressed() -> void:
	Network.players_info[multiplayer.get_unique_id()] = name_line.text
	Network.add_player_info.rpc_id(1, Network.players_info[multiplayer.get_unique_id()])
	game_joined.emit(name_line.text)
	end_scene()
