extends CanvasLayer
class_name GUI



@export var main_menu_scene: PackedScene
@export var tutorial_scene: PackedScene
@export var results_scene: PackedScene
@export var title_scene: PackedScene
@export var name_scene: PackedScene

var world: Node3D
var current_screen: Screen
var server_info: Dictionary
var username: String

@onready var black_scene: ColorRect = $BlackScene


func _ready() -> void:
	_on_screen_changed(Screen.Types.TITLE)
	
	if OS.has_feature("server"):
		return
	

#func _process(delta: float) -> void:
	#match scene:
		#Scene.MAIN_MENU:
			#print("Standing still.")
		#Scene.EMPTY: # Comma-separated list for multiple matches
			#print("Character is moving.")

func _on_screen_changed(screen: Screen.Types):	
	await black_fade_in()
	
	if current_screen:
		current_screen.queue_free()
	
	match screen:
		Screen.Types.MAIN_MENU:
			current_screen = main_menu_scene.instantiate()
			current_screen.game_selected.connect(set_server_info)
		Screen.Types.TUTORIAL:
			current_screen = tutorial_scene.instantiate()
		Screen.Types.TITLE:
			current_screen = title_scene.instantiate()
		Screen.Types.NAME:
			current_screen = name_scene.instantiate()
			current_screen.server_info = server_info
			current_screen.game_joined.connect(set_player_username)
		Screen.Types.RESULTS:
			current_screen = results_scene.instantiate()
		Screen.Types.EMPTY:
			await black_fade_out()
			return
		
	add_child(current_screen)
	current_screen.screen_changed.connect(_on_screen_changed)
	
	await black_fade_out()


func set_results(new_results: Dictionary) -> void:
	current_screen.status_label.text = str(new_results.status)


func set_server_info(new_info):
	server_info = new_info
	print(server_info)


func set_player_username(new_username):
	username = new_username
	print(username)


func black_fade_in() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(black_scene, "modulate", Color.from_rgba8(255, 255, 255, 255), 0.75)
	await tween.finished


func black_fade_out() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(black_scene, "modulate", Color.from_rgba8(255, 255, 255, 0), 0.75)
	await tween.finished
