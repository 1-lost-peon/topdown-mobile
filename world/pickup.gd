extends Node3D

var move_up: bool = true

@onready var coin_a_2: Node3D = $Coin_A2


func _process(_delta: float) -> void:
	coin_a_2.rotate(Vector3.UP, 0.01)
	
	if coin_a_2.position.distance_to(Vector3.ZERO) < 0.1:
		move_up = true
	elif coin_a_2.position.distance_to((Vector3(0, 2, 0))) < 0.1:
		move_up = false
	
	if move_up:
		coin_a_2.position = coin_a_2.position.move_toward(Vector3(0, 2, 0), 0.01)
	else:
		coin_a_2.position = coin_a_2.position.move_toward(Vector3.ZERO, 0.01)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("players"):
		body.coins += 1
		Network.log_message(body.coins)

		queue_free()
	#if !is_multiplayer_authority():
		#return
	
