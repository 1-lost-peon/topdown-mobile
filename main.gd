extends Node

@onready var world: Node3D = %World
@onready var gui: CanvasLayer = %GUI


func _ready() -> void:
	if OS.has_feature("server"):
		Network.player_connected.connect(_on_player_connected.rpc_id)
		gui.main_menu._on_start_server_pressed()
		_on_click_join_game()
	else:
		gui.main_menu.game_joined.connect(_on_click_join_game)


func _on_click_join_game() -> void:
	world.spawn_level()


@rpc("authority", "call_local")
func _on_player_connected(new_player_id) -> void:
	world.spawn_player(str(new_player_id))
