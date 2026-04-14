extends CanvasLayer

signal entered_main_menu

var world: Node3D
var main_menu

func _ready() -> void:
	main_menu = load("res://gui/main_menu.tscn").instantiate()
	main_menu.name = "main_menu"
	add_child(main_menu)
	entered_main_menu.emit()
