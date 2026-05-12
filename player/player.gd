extends CharacterBody3D

signal player_died

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOVEMENT_INDICATOR_MAX = 1.025
const FULL_SPEED_AT := 0.7

@onready var mesh_3d: Node3D = $Mesh3D
@onready var camera = $Camera3D
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var hud: HUD = $HUD
@onready var respawn_timer: Timer = $RespawnTimer
@onready var visuals: Visuals = $Visuals
@onready var weapon: Weapon = $Weapon

var spawn_locations: Array[Vector3]
var movement_direction: Vector3
var attack_direction: Vector3
var is_dead: bool
var spawn_location: Vector3
var input_movement_direction: Vector2 = Vector2.ZERO
var input_movement_strength: float = 0.0
var input_attack_direction: Vector2 = Vector2.ZERO
var input_attack_strength: float = 0.0
var coins: int = 0

func _enter_tree() -> void:
	add_to_group("players")


func _ready() -> void:
	visuals.nameplate.text = name
	is_dead = false
	
	if multiplayer.get_unique_id() != int(name):
		visuals.nameplate.modulate = Pallette.BLUE
		setup_as_other_player()
		return
	
	camera.current = true
	visuals.nameplate.modulate = Pallette.GREEN


func _physics_process(delta: float) -> void:
	if is_dead:
		# Turn on the players respwn label here, an RPC
		show_player_respawn.rpc_id(int(name), str(int(respawn_timer.time_left)))
		return
	
	if is_multiplayer_authority():
		#Network.log_message("Process player as authority") # just server
		process_as_server(delta)
		
	if multiplayer.get_unique_id() == 1: return
	
	if multiplayer.get_unique_id() == int(name):
		process_as_local_player(delta)
		#Network.log_message("Remotely process player", name) # Other client # oops server happens here too
		#process_as_other_player(delta)
	#if multiplayer.get_unique_id() == 1:
	#else:
		#Network.log_message("Locally process player", name) # from itself


func process_as_local_player(delta):
	attack_direction = (transform.basis * Vector3(input_attack_direction.x, 0, input_attack_direction.y)).normalized()
	
	var attack_material := weapon.aim_indicator.get_active_material(0)

	if attack_direction and input_attack_strength > 0.3:
		var target_angle = atan2(attack_direction.x, attack_direction.z)
		weapon.aim_rotator.rotation.y = lerp_angle(
			weapon.aim_rotator.rotation.y,
			target_angle,
			15.0 * delta
		)
		create_tween().tween_method(
			func(value): attack_material.set_shader_parameter("width", value),
			attack_material.get_shader_parameter("width"),
			0.5,
			0.01
		)
	else:
		create_tween().tween_method(
			func(value): attack_material.set_shader_parameter("width", value),
			attack_material.get_shader_parameter("width"),
			0.0,
			0.1
		)


func setup_as_other_player():
	var mat := visuals.player_circle.get_active_material(0)
	visuals.player_circle.set_surface_override_material(0, mat.duplicate())
	weapon.aim_rotator.visible = false
	visuals.player_circle.get_active_material(0).set_shader_parameter(
		"outline_color",
		Pallette.BLUE
	)


#func process_as_other_player(delta):
	## don't read input
	## smoothly follow synced position
	#aim_rotator.visible = false
	#player_circle.get_active_material(0).set_shader_parameter("outline_color", Color(0x00a0ffff))


func process_as_server(delta):
	# enemies, interactables, validation, spawning, damage
	if not is_on_floor():
		velocity += get_gravity() * delta


	attack_direction = (transform.basis * Vector3(input_attack_direction.x, 0, input_attack_direction.y)).normalized()
	
	if attack_direction and input_attack_strength > 0.3:
		var target_angle = atan2(attack_direction.x, attack_direction.z)
		weapon.aim_rotator.rotation.y = lerp_angle(
			weapon.aim_rotator.rotation.y,
			target_angle,
			15.0 * delta
		)
	#var input_dir: Vector2 = Vector2.ZERO
	
	#if !is_dead:
		#input_dir = hud.drag_vector.normalized()

	movement_direction = (transform.basis * Vector3(input_movement_direction.x, 0, input_movement_direction.y)).normalized()
	
	if movement_direction:
		var adjusted_strength: float = clamp(input_movement_strength / FULL_SPEED_AT, 0.0, 1.0)
		velocity.x = movement_direction.x * SPEED * adjusted_strength
		velocity.z = movement_direction.z * SPEED * adjusted_strength
		
		update_movement_indicator()
		
		var target_angle = atan2(movement_direction.x, movement_direction.z)
		mesh_3d.rotation.y = lerp_angle(
			mesh_3d.rotation.y,
			target_angle,
			5.0 * delta
		)
		
		visuals.player_circle.rotation.y = lerp_angle(
			mesh_3d.rotation.y,
			target_angle,
			15.0 * delta
		)
		
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		create_tween().tween_property(
			visuals.movement_indicator,
			"position",
			Vector3.ZERO,
			0.08
		)

	move_and_slide()



#func _physics_process(delta: float) -> void:
	#if !is_multiplayer_authority(): return
	#if multiplayer.get_unique_id() != int(name) and multiplayer.get_unique_id() != 1: return # Server can't run here...
	#
	#Network.log_message(multiplayer.get_unique_id(), "Is the only one running player process") # Yup, only server still
	## Basically, we only want the current player to run his client side on his player stuff...
	#
	#if multiplayer.get_unique_id() == int(name):


func update_movement_indicator() -> void:
	var distance: float = input_movement_strength * MOVEMENT_INDICATOR_MAX
	visuals.movement_indicator.position.z = distance


func apply_input(new_movement_direction, new_movement_strength, new_attack_direction, new_attack_strength) -> void:
	input_movement_direction = new_movement_direction
	input_movement_strength = new_movement_strength
	input_attack_direction = new_attack_direction
	input_attack_strength = new_attack_strength


@rpc("authority")
func show_player_respawn(time: String) -> void:
	hud.respawn_label.visible = true
	hud.respawn_label.text = "Respawning in " + time + "..."


@rpc("authority")
func hide_player_respawn() -> void:
	hud.respawn_label.visible = false


@rpc()
func collected_pickup():
	coins += 1
	visuals.number_plate.text = str(coins)

@rpc()
func set_coins_amount(new_coins_amount):
	coins = new_coins_amount
	visuals.number_plate.text = str(coins)

func died() -> void:
	if is_multiplayer_authority():
		is_dead = true
		visible = false
		respawn_timer.start()
		player_died.emit()
		set_coins_amount.rpc_id(int(name), 0)
		coins = 0
		visuals.number_plate.text = str(coins)


func _on_respawn_timer_timeout() -> void:
	if is_multiplayer_authority():
		visible = true
		is_dead = false
		hide_player_respawn.rpc_id(int(name))
