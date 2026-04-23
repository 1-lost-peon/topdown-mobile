extends CanvasLayer
class_name HUD

@onready var joy_stick_nub: TextureRect = %JoyStickNub
@onready var joy_stick_pad: TextureRect = %JoyStickPad

var default_position := Vector2(64, 64)
var active_touch := -1
var max_distance := 192.0 # 3 * 64
var drag_vector: Vector2
@onready var v_box_container: VBoxContainer = $Main/ColorRect/VBoxContainer
var player_count: int = 0
@onready var label: Label = $Main/Label

#@rpc("any_peer", "call_remote", "unreliable")
#func send_input(input_dir: Vector2) -> void:
	#if multiplayer.get_remote_sender_id() != name.to_int():
		#return
	
	#net_input = input_dir

func _ready() -> void:
	Network.player_connected.connect(_on_player_connected)
	label.text = str(multiplayer.get_unique_id())

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
			var center = joy_stick_nub.global_position + joy_stick_nub.size / 2.0
			var radius = joy_stick_nub.size.x / 2.0
			
			if event.position.distance_to(center) <= radius:
				active_touch = event.index
		else:
			if event.index == active_touch:
				drag_vector = Vector2.ZERO
				active_touch = -1
				create_tween().tween_property(joy_stick_nub, "position", default_position, 0.08)
		
	elif event is InputEventScreenDrag:
		if event.index == active_touch:
			var base_center = joy_stick_pad.global_position + joy_stick_pad.size / 2.0
			drag_vector = event.position - base_center
		
			if drag_vector.length() > max_distance:
				drag_vector = drag_vector.normalized() * max_distance
			
			joy_stick_nub.global_position = base_center + drag_vector - joy_stick_nub.size / 2.0
	
	send_movement_input.rpc_id(1, drag_vector) # send movement input to server	 
	


@rpc("any_peer", "reliable")
func send_movement_input(dir: Vector2) -> void:
	if !multiplayer.is_server():
		return

	var sender_id := multiplayer.get_remote_sender_id()
	var players = get_tree().get_nodes_in_group("players")
	var player: CharacterBody3D
	for p in players:
		#print(p.name)
		if p.name == str(sender_id):
			player = p
	player.apply_input(dir)
