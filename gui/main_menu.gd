extends Screen

signal game_selected()


func _ready() -> void:
	Network.discovery.game_found.connect(_found_game)


func _found_game(server_info):
	$VBoxContainer/Button.text = server_info.name
	game_selected.emit(server_info)
	end_scene()
