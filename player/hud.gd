extends CanvasLayer
class_name HUD

enum JoystickType {
	MOVEMENT,
	ATTACK
}

var joystick_data := {
	JoystickType.MOVEMENT: {
		"pad": null,
		"nub": null,
		"default_position": Vector2.ZERO,
		"active": -1,
		"input_direction": Vector2.ZERO,
		"input_strength": 0.0,
	},
	JoystickType.ATTACK: {
		"pad": null,
		"nub": null,
		"default_position": Vector2.ZERO,
		"active": -1,
		"input_direction": Vector2.ZERO,
		"input_strength": 0.0,
	}
}

@onready var movement_joy_stick_nub: TextureRect = %JoyStickNub
@onready var movement_joy_stick_pad: TextureRect = %JoyStickPad
@onready var attack_joy_stick_nub: TextureRect = $Main/AttackPad/AttackNub
@onready var attack_joy_stick_pad: TextureRect = $Main/AttackPad

var default_position := Vector2(64, 64)
var active_touch := -1
#var max_distance := 192.0 # 3 * 64
var max_distance := 64 * 2 # 3 * 64
var movement_drag_vector: Vector2
var attack_drag_vector: Vector2
@onready var v_box_container: VBoxContainer = $Main/ColorRect/VBoxContainer
var player_count: int = 0
@onready var respawn_label: Label = $Main/RespawnLabel

func _ready() -> void:
	respawn_label.visible = false
	Network.player_connected.connect(_on_player_connected)
	joystick_data[JoystickType.MOVEMENT]["pad"] = movement_joy_stick_pad
	joystick_data[JoystickType.MOVEMENT]["nub"] = movement_joy_stick_nub
	joystick_data[JoystickType.MOVEMENT]["default_position"] = movement_joy_stick_nub.position

	joystick_data[JoystickType.ATTACK]["pad"] = attack_joy_stick_pad
	joystick_data[JoystickType.ATTACK]["nub"] = attack_joy_stick_nub
	joystick_data[JoystickType.ATTACK]["default_position"] = attack_joy_stick_nub.position


func _on_player_connected(peer_id, player_info) -> void:
	var rows = v_box_container.get_children()
	
	if player_count >= rows.size():
		return
	
	var row = rows[player_count]
	var player_label = row.get_node("Player1") as Label
	player_label.text = str(peer_id)
	
	player_count += 1


func _input(event: InputEvent) -> void:
	if multiplayer.get_unique_id() == 1:
		return
	
	if event is InputEventScreenTouch:
		if event.pressed:
			check_joy_stick_active(JoystickType.MOVEMENT, event)
			check_joy_stick_active(JoystickType.ATTACK, event)

		else:
			reset_joystick_active(JoystickType.MOVEMENT, event)
			reset_joystick_active(JoystickType.ATTACK, event)

	elif event is InputEventScreenDrag:
		update_joystick_drag(JoystickType.MOVEMENT, event)
		update_joystick_drag(JoystickType.ATTACK, event)
	
	send_movement_input.rpc_id(1, joystick_data) # send movement input to server
	send_movement_input.rpc_id(multiplayer.get_unique_id(), joystick_data) # send movement input to server


func check_joy_stick_active(type: JoystickType, event: InputEventScreenTouch) -> void:
	var joystick = joystick_data[type]
	var nub: Control = joystick["nub"]

	var center = nub.global_position + nub.size / 2.0
	var radius = nub.size.x / 2.0

	if event.position.distance_to(center) <= radius:
		joystick["active"] = event.index


func reset_joystick_active(type: JoystickType, event: InputEventScreenTouch) -> void:
	var joystick = joystick_data[type]
	var nub: Control = joystick["nub"]

	if event.index == joystick["active"]:
		if type == JoystickType.ATTACK:
			var direction: Vector2 = joystick["input_direction"].normalized()
			var strength: float = joystick["input_strength"]
			
			if strength <= 0.3:
				shoot_request.rpc_id(1)
			elif direction != Vector2.ZERO:
				shoot_request.rpc_id(1)

		
		
		joystick["input_direction"] = Vector2.ZERO
		joystick["active"] = -1
		create_tween().tween_property(
			nub,
			"position",
			joystick["default_position"],
			0.08
		)


func update_joystick_drag(type: JoystickType, event: InputEventScreenDrag) -> void:
	var joystick = joystick_data[type]

	if event.index != joystick["active"]:
		return

	var pad: Control = joystick["pad"]
	var nub: Control = joystick["nub"]

	var base_center = pad.global_position + pad.size / 2.0
	var drag_vector = event.position - base_center

	if drag_vector.length() > max_distance:
		drag_vector = drag_vector.normalized() * max_distance

	var strength := drag_vector.length() / max_distance
	
	joystick["input_direction"] = drag_vector
	joystick["input_strength"] = strength
	nub.global_position = base_center + drag_vector - nub.size / 2.0


@rpc("any_peer", "call_local", "reliable")
func shoot_request() -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	var players = get_tree().get_nodes_in_group("players")
	var player: CharacterBody3D
	for p in players:
		#print(p.name)
		if p.name == str(sender_id):
			player = p
	if player:
		player.shoot()


@rpc("any_peer", "call_local", "reliable")
func send_movement_input(new_joystick_data) -> void:
	#if !multiplayer.is_server():
		#return	
	var movement_direction: Vector2 = new_joystick_data[JoystickType.MOVEMENT]["input_direction"]
	var movement_strength: float = new_joystick_data[JoystickType.MOVEMENT]["input_strength"]
	var attack_direction: Vector2 = new_joystick_data[JoystickType.ATTACK]["input_direction"]
	var attack_strength: float = new_joystick_data[JoystickType.ATTACK]["input_strength"]


	var sender_id := multiplayer.get_remote_sender_id()
	var players = get_tree().get_nodes_in_group("players")
	var player: CharacterBody3D
	for p in players:
		#print(p.name)
		if p.name == str(sender_id):
			player = p
	if player:
		player.apply_input(movement_direction, movement_strength, attack_direction, attack_strength)
