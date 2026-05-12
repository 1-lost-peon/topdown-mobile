extends RigidBody3D

@onready var coin_a_2: Node3D = $Coin_A2

var bob_time := 0.0

func _ready() -> void:
	sleeping = false
	linear_damp = 4.0
	angular_damp = 6.0

	var dir := Vector3(
		randf_range(-1.0, 1.0),
		randf_range(0.15, 0.5),
		randf_range(-1.0, 1.0)
	).normalized()

	apply_central_impulse(dir * randf_range(0.8, 2.0))


func _process(delta: float) -> void:
	bob_time += delta

	coin_a_2.rotate_y(delta * 3.0)
	coin_a_2.position.y = 0.25 + sin(bob_time * 4.0) * 0.15

func _on_area_3d_body_entered(body: Node3D) -> void:
	if is_multiplayer_authority():
		if body.is_in_group("players"):
			if !body.is_dead:
				body.coins += 1
				body.visuals.number_plate.text = str(body.coins)
				Network.log_message(body.coins)
				pickup_collected.rpc_id(int(body.name))
				body.collected_pickup.rpc_id(int(body.name))
  
				queue_free()
	#if !is_multiplayer_authority():
		#return

@rpc()
func pickup_collected():
	queue_free()
