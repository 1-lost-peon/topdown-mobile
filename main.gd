extends Node

var udp := PacketPeerUDP.new()

@onready var world: Node3D = %World
@onready var gui: CanvasLayer = %GUI
@onready var broadcast_timer: Timer = $BroadcastTimer


func _ready() -> void:
	#world.scene_loaded.connect(gui._on_scene_loaded)
	#world.scene_changed.connect(gui._on_scene_changed)
	world.game_ended.connect(gui.set_results)
	
	if OS.has_feature("server"):
		gui.visible = false
		Network.player_connected.connect(_on_player_connected.rpc_id)
		Network.create_game()
		_on_click_join_game()
		
		Network.start_game_broadcast()
		broadcast_timer.timeout.connect(Network.broadcast_game)
		
	else:
		Network.start_game_discovery()
		broadcast_timer.timeout.connect(Network.discover_game)
		
		_on_click_join_game()
				
	broadcast_timer.start()



func _on_click_join_game() -> void:
	world.spawn_level()


@rpc("authority", "call_local")
func _on_player_connected(new_player_id) -> void:
	world.spawn_player(str(new_player_id))
