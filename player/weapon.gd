extends Node3D
class_name Weapon

@onready var aim_indicator: MeshInstance3D = $AimRotator/AimIndicator
@onready var aim_rotator: Marker3D = $AimRotator
@onready var max_attack_distance: Marker3D = $AimRotator/MaxAttackDistance
@onready var area_3d: Area3D = $AimRotator/Area3D
@onready var cpu_particles_3d: CPUParticles3D = $AimRotator/CPUParticles3D

var input_attack_direction: Vector2
var is_despawning := false
var is_attacking: bool = false


func _ready():
	cpu_particles_3d.emitting = true


func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		if is_attacking:
			cpu_particles_3d.emitting = true
			area_3d.position = area_3d.position.move_toward(max_attack_distance.position, 1.0)
			if area_3d.position == max_attack_distance.position:
				is_attacking = false
				cpu_particles_3d.emitting = false
				area_3d.position = Vector3.ZERO


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
		enemy.queue_free()


func attack() -> void:
	is_attacking = true
