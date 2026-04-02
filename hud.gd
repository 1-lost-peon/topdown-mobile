extends Control

@onready var joy_stick_nub: TextureRect = %JoyStickNub
@onready var joy_stick_pad: TextureRect = %JoyStickPad

var default_position := Vector2(32, 32)
var active_touch := -1
var max_distance := 96.0 # 3 * 32

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			var center = joy_stick_nub.global_position + joy_stick_nub.size / 2.0
			var radius = joy_stick_nub.size.x / 2.0

			if event.position.distance_to(center) <= radius:
				active_touch = event.index
		else:
			if event.index == active_touch:
				active_touch = -1
				create_tween().tween_property(joy_stick_nub, "position", default_position, 0.08)
	
	elif event is InputEventScreenDrag:
		if event.index == active_touch:
			var base_center = joy_stick_pad.global_position + joy_stick_pad.size / 2.0
			var drag_vector = event.position - base_center
			
			if drag_vector.length() > max_distance:
				drag_vector = drag_vector.normalized() * max_distance
			
			joy_stick_nub.global_position = base_center + drag_vector - joy_stick_nub.size / 2.0
