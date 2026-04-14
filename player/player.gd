extends CharacterBody3D

@onready var hud: HUD = $HUD
@onready var camera = $Camera3D
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer
@onready var respawn_timer: Timer = $RespawnTimer

signal player_died

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var direction: Vector3
var is_dead: bool
var spawn_location: Vector3


func _enter_tree() -> void:
	set_multiplayer_authority(int(name))
	add_to_group("players")


func _ready() -> void:
	if is_multiplayer_authority():
		camera.current = true
	
	respawn_timer.timeout.emit()


func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority(): return
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	var input_dir: Vector2 = Vector2.ZERO
	
	if !is_dead:
		input_dir = hud.drag_vector.normalized()
	
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()


var is_despawning := false

func died() -> void:
	is_dead = true
	respawn_timer.start()
	player_died.emit()


func _on_respawn_timer_timeout() -> void:
	is_dead = false
