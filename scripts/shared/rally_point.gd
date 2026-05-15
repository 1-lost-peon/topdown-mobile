extends Node3D

class_name RallyPoint

@export var needs_all_players: bool

var players_in_area: Array[Player]
var players_in_world: Array[Player]
var load_time: float = 5.0
var get_player_list: Callable
var has_all_players: bool

@onready var progress_bar: ProgressBar = $ProgressBar


func _process(delta: float) -> void:
	if is_multiplayer_authority() and players_in_area.size() != 0:
		update_loading_bar.rpc(progress_bar.value)
		progress_bar.value += 20 * delta


func _on_area_3d_body_entered(body: Node3D) -> void:
	if is_multiplayer_authority():
		if body.is_in_group("players"):
			print(get_player_list.call())
			players_in_area.append(body)
			if needs_all_players:
				pass # Visual "Waiting for all players..."
			else:
				show_loading_bar.rpc()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("players"):
		players_in_area.erase(body)


@rpc()
func show_loading_bar():
	progress_bar.visible = true


@rpc()
func update_loading_bar(server_value: float):
	progress_bar.value = server_value
