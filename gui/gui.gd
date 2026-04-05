extends CanvasLayer

var world: Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var main_menu = load("res://gui/main_menu.tscn").instantiate()
	main_menu.name = "main_menu"
	add_child(main_menu)
