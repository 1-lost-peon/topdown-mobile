extends Node3D

@export var speed = 20

var direction: Vector3 = Vector3.ZERO
var is_despawning := false

func _physics_process(delta: float) -> void:
	global_position += direction * delta * speed


func _on_area_3d_area_entered(area: Area3D) -> void:
	if !is_multiplayer_authority():
		return

	if area.name != "HitArea3D":
		return

	var enemy := area.get_parent()
	
	if enemy.get("is_despawning"):
		return

	if !enemy or !enemy.is_in_group("enemies"):
		return

	despawn_enemy.rpc(enemy.get_path())


@rpc("authority", "call_local", "reliable")
func despawn_enemy(enemy_path: NodePath) -> void:
	var enemy := get_node_or_null(enemy_path)

	if enemy:
		if is_despawning:
			return

		is_despawning = true
		
		enemy.visible = false
#
		for area in find_children("*", "Area3D", true, false):
			area.set_deferred("monitoring", false)
			area.set_deferred("monitorable", false)
#
		for shape in find_children("*", "CollisionShape3D", true, false):
			shape.set_deferred("disabled", true)
		print(multiplayer.get_unique_id(), " WE SHOULD DELETE")
		#call_deferred("queue_free")
		enemy.queue_free()
