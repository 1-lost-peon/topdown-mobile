extends Node

@onready var world: Node3D = %World
@onready var gui: CanvasLayer = %GUI

func _ready() -> void:
	if OS.has_feature("server"):
		#NetworkHandling.start_server()
		Network.create_game()
		world.spawn_level()
		gui.main_menu.queue_free()
	else:
		gui.main_menu.game_joined.connect(player_joined_game)

func player_joined_game() -> void:
	world.spawn_level()
