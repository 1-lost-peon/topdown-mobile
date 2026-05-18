extends Node

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
		
		Network.discovery.start_discovery_listener()
		broadcast_timer.timeout.connect(Network.discovery.process_discovery_requests)
		
	else:
		Network.discovery.game_found.connect(_stop_broadcast_timer)
		Network.discovery.start_game_discovery()
		broadcast_timer.timeout.connect(Network.discovery.discover_game)
		broadcast_timer.timeout.connect(Network.discovery.process_discovery_responses)
		
		_on_click_join_game()
		
	broadcast_timer.start()


# Stops timer on the client side
func _stop_broadcast_timer(data):
	broadcast_timer.stop()
	Network.join_game(data.ip)


func _on_click_join_game() -> void:
	world.spawn_level()


@rpc("authority", "call_local")
func _on_player_connected(new_player_info: Dictionary) -> void:
	Network.utility.log("_on_player_connected in main.gd", new_player_info)
	world.spawn_player(new_player_info)
