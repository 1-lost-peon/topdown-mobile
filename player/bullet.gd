extends Node3D

@export var speed = 20

var direction: Vector3 = Vector3.ZERO

func _physics_process(delta: float) -> void:
	global_position += direction * delta * speed
