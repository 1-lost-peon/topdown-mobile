extends Screen

signal game_selected()

@onready var name_line: LineEdit = $VBoxContainer/NameLine


func _on_join_game_pressed() -> void:
	Network.players_info[multiplayer.get_unique_id()] = name_line.text
	Network.add_player_info.rpc_id(1, Network.players_info[multiplayer.get_unique_id()])
	end_scene()
