extends MultiplayerSpawner

@export var network_player: PackedScene


# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#multiplayer.peer_connected.connect(spawn_player)
	#print("Spawner?")


func spawn_player(id: int) -> void:
	if !multiplayer.is_server(): return
	
	var world := get_node(spawn_path)
	var player: Node = network_player.instantiate()
	player.name = str(id)
	player.spawn_location = world.level.new_spawn_location()
	#player.respawn_timer.timeout.connect(
		#Callable(world, "spawn_player_in_world").bind(player)
	#)
	
	world.call_deferred("add_child", player)
	
	player.ready.connect(func():
		player.respawn_timer.timeout.connect(
				Callable(world.level, "spawn_player_in_world").bind(player)
			)
		, CONNECT_ONE_SHOT)
	print("Player has spawned")
	
