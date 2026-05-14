extends CanvasLayer
class_name GUI

enum Scene {
	MAIN_MENU,
	TUTORIAL,
	RESULTS,
	EMPTY,
}

@export var main_menu_scene: PackedScene
@export var tutorial_scene: PackedScene
@export var results_scene: PackedScene

var world: Node3D
var main_menu: Node
var tutorial: Node
var results: Node
var scene: Scene

@onready var black_scene: Control = $BlackScene


func _ready() -> void:
	setup_main_menu()
	
	if OS.has_feature("server"):
		return
	
	main_menu.scene_changed.connect(_on_scene_changed)

#func _process(delta: float) -> void:
	#match scene:
		#Scene.MAIN_MENU:
			#print("Standing still.")
		#Scene.EMPTY: # Comma-separated list for multiple matches
			#print("Character is moving.")



func setup_main_menu() -> void:
	main_menu = main_menu_scene.instantiate()
	add_child(main_menu)


func setup_tutorial() -> void:
	tutorial = tutorial_scene.instantiate()
	add_child(tutorial)
	tutorial.scene_changed.connect(_on_scene_changed)


func setup_results() -> void:
	results = results_scene.instantiate()
	add_child(results)
	results.scene_changed.connect(_on_scene_changed)


func set_results(new_results: Dictionary) -> void:
	results.status_label.text = str(new_results.status)


func _on_scene_changed(scene: Scene) -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(black_scene, "modulate", Color.from_rgba8(255, 255, 255, 255), 0.0)
	match scene:
		Scene.MAIN_MENU:
			setup_main_menu()
		Scene.TUTORIAL:
			setup_tutorial()
		Scene.RESULTS:
			setup_results()
		Scene.EMPTY:
			pass


func _on_scene_loaded() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(black_scene, "modulate", Color.from_rgba8(255, 255, 255, 0), 1.0)
