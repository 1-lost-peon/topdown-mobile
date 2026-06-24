extends CanvasLayer
class_name HUD

signal builder_mode_activated

var player_count: int = 0
var is_combat_mode: bool
var world: Node3D

@onready var respawn_label: Label = $Main/RespawnLabel
@onready var build_hud: Control = $Main/BuildHUD
@onready var combat_hud: Control = $Main/CombatHUD
@onready var input_toggle: Button = $Main/InputToggle


func _ready() -> void:
	#set_multiplayer_authority(multiplayer.get_unique_id())
	builder_mode_activated.connect(toggle_mode)
	
	respawn_label.visible = false
	is_combat_mode = true
	
	build_hud.visible = false
	
	combat_hud.visible = true
	combat_hud.player_input_updated.connect(on_player_input_updated)
	

func toggle_mode():
	build_hud.visible = !build_hud.visible
	combat_hud.visible = !combat_hud.visible
	is_combat_mode = !is_combat_mode
	input_toggle.text = "Combat Mode" if !is_combat_mode else "Builder Mode"


func _on_builder_mode_pressed() -> void:
	builder_mode_activated.emit()


func on_player_input_updated(user_input: Dictionary):
	if multiplayer.multiplayer_peer == null or multiplayer.multiplayer_peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		return # Skip RPC if not connected
	world.update_player_input.rpc_id(1, user_input)
