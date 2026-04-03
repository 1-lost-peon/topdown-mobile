extends CanvasLayer
class_name HUD

@onready var joy_stick_nub: TextureRect = %JoyStickNub
@onready var joy_stick_pad: TextureRect = %JoyStickPad

var default_position := Vector2(64, 64)
var active_touch := -1
var max_distance := 192.0 # 3 * 64
var drag_vector: Vector2


func _input(event: InputEvent) -> void:
	print(drag_vector)
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
		
