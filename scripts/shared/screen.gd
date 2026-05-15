extends Control

class_name Screen

signal screen_changed

enum Types {
	TITLE,
	MAIN_MENU,
	NAME,
	TUTORIAL,
	RESULTS,
	EMPTY,
}

@export var next_screen: Types
@export var type: Types
@export var timeout_time: float = 2.0

var can_end_screen: bool

@onready var timer: Timer = $Timer


func _ready() -> void:
	can_end_screen = false
	timer.timeout.connect(_on_timer_timeout)
	timer.start(timeout_time)


#func _process(_delta: float) -> void:
	#if can_end_screen:
		#end_scene()


func _on_timer_timeout() -> void:
	can_end_screen = true


func end_scene() -> void:
	screen_changed.emit(next_screen)
