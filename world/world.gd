extends Node3D

@export var enemy: PackedScene

func _on_enemy_timer_timeout():
	var players = get_tree().get_nodes_in_group("players")
	if players:
		print(players)

		var enemy: Node = enemy.instantiate()	
		add_child(enemy)
