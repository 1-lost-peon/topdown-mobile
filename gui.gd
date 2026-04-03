extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var main_menu = load("res://main_menu.tscn").instantiate()
	add_child(main_menu)
	main_menu.screen_changed.connect(start_hud)


func start_hud() -> void:
	var hud = load("res://hud.tscn").instantiate()
	add_child(hud)
