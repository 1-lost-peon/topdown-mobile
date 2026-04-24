extends CharacterBody3D

@onready var mannequin_medium: Node3D = $Mannequin_Medium
@onready var camera = $Camera3D
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var hud: HUD = $HUD
@onready var respawn_timer: Timer = $RespawnTimer
@onready var nameplate: Label3D = $Nameplate
@onready var player_circle: MeshInstance3D = $PlayerCircle
@onready var movement_indicator: MeshInstance3D = $PlayerCircle/MovementIndicator
@onready var aim_rotator: Marker3D = $AimRotator
@onready var aim_indicator: MeshInstance3D = $AimRotator/AimIndicator



signal player_died

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOVEMENT_INDICATOR_MAX = 1.025

var spawn_locations: Array[Vector3]
var movement_direction: Vector3
var attack_direction: Vector3
var is_dead: bool
var spawn_location: Vector3
var input_movement_direction: Vector2 = Vector2.ZERO
var input_movement_strength: float = 0.0
var input_attack_direction: Vector2 = Vector2.ZERO


func _enter_tree() -> void:
	add_to_group("players")


func _ready() -> void:
	nameplate.text = name
	
	if multiplayer.get_unique_id() != int(name):
		nameplate.modulate = Color(0x00a0ffff)
		return
	
	camera.current = true
	nameplate.modulate = Color(0x8aff00ff)
	respawn_timer.timeout.emit()


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority() and multiplayer.get_unique_id() != int(name): return
	
	if multiplayer.get_unique_id() == int(name):
		attack_direction = (transform.basis * Vector3(input_attack_direction.x, 0, input_attack_direction.y)).normalized()
		
		var attack_material := aim_indicator.get_active_material(0)
		
		if attack_direction:
			var target_angle = atan2(attack_direction.x, attack_direction.z)
			aim_rotator.rotation.y = lerp_angle(
				aim_rotator.rotation.y,
				target_angle,
				15.0 * delta
			)
			create_tween().tween_method(
				func(value): attack_material.set_shader_parameter("width", value),
				attack_material.get_shader_parameter("width"),
				0.5,
				0.3
			)
		else:
			create_tween().tween_method(
				func(value): attack_material.set_shader_parameter("width", value),
				attack_material.get_shader_parameter("width"),
				0.0,
				0.2
			)
		
	if not is_on_floor():
		velocity += get_gravity() * delta

	#var input_dir: Vector2 = Vector2.ZERO
	
	#if !is_dead:
		#input_dir = hud.drag_vector.normalized()
	
	#attack_direction = (transform.basis * Vector3(input_attack_direction.x, 0, input_attack_direction.y)).normalized()
	#var attack_material := aim_indicator.get_active_material(0)
	#if attack_direction:
		#var target_angle = atan2(attack_direction.x, attack_direction.z)
		#aim_rotator.rotation.y = lerp_angle(
			#aim_rotator.rotation.y,
			#target_angle,
			#15.0 * delta
		#)
		#create_tween().tween_method(
			#func(value): attack_material.set_shader_parameter("width", value),
			#attack_material.get_shader_parameter("width"),
			#0.5,
			#0.3
		#)
		
	#else:
		#create_tween().tween_method(
			#func(value): attack_material.set_shader_parameter("width", value),
			#attack_material.get_shader_parameter("width"),
			#0.0,
			#0.2
		#)
	
	movement_direction = (transform.basis * Vector3(input_movement_direction.x, 0, input_movement_direction.y)).normalized()
	
	if movement_direction:
		velocity.x = movement_direction.x * SPEED * input_movement_strength
		velocity.z = movement_direction.z * SPEED * input_movement_strength
		
		update_movement_indicator()
		
		var target_angle = atan2(movement_direction.x, movement_direction.z)
		mannequin_medium.rotation.y = lerp_angle(
			mannequin_medium.rotation.y,
			target_angle,
			5.0 * delta
		)
		
		player_circle.rotation.y = lerp_angle(
			mannequin_medium.rotation.y,
			target_angle,
			15.0 * delta
		)
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		create_tween().tween_property(
			movement_indicator,
			"position",
			Vector3.ZERO,
			0.08
		)

	move_and_slide()


func update_movement_indicator() -> void:
	var distance: float = input_movement_strength * MOVEMENT_INDICATOR_MAX
	movement_indicator.position.z = distance


func apply_input(new_movement_direction, new_movement_strength, new_attack_direction) -> void:
	input_movement_direction = new_movement_direction
	input_movement_strength = new_movement_strength
	input_attack_direction = new_attack_direction

var is_despawning := false

func died() -> void:
	is_dead = true
	respawn_timer.start()
	player_died.emit()


func _on_respawn_timer_timeout() -> void:
	is_dead = false
