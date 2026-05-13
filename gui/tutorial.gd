extends Control

signal scene_changed

@onready var timer: Timer = $Timer


func _ready() -> void:
	timer.start()


func end_scene() -> void:
	scene_changed.emit(GUI.Scene.EMPTY)
	queue_free()


func _on_timer_timeout() -> void:
	queue_free()
