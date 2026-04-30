extends CanvasLayer

@export var main_menu_scene: PackedScene

var world: Node3D
var main_menu: Node

@onready var black_scene: Control = $BlackScene


func _ready() -> void:
	main_menu = main_menu_scene.instantiate()
	add_child(main_menu)
	
	if OS.has_feature("server"):
		return
	
	main_menu.scene_changed.connect(_on_scene_changed)
	# world.scene_changed.connect(_on_scene_changed)
	


func _on_scene_changed() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(black_scene, "modulate", Color.from_rgba8(255, 255, 255, 255), 0.0)


func _on_scene_loaded() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(black_scene, "modulate", Color.from_rgba8(255, 255, 255, 0), 1.0)
