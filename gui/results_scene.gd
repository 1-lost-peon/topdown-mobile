extends Control

signal scene_changed

@onready var status_label: Label = $VSplitContainer/HSplitContainer/StatusLabel
@onready var survivors_label: Label = $"VSplitContainer/HSplitContainer2/Survivors Label"
@onready var resources_label: Label = $VSplitContainer/HSplitContainer3/ResourcesLabel

func end_scene() -> void:
	scene_changed.emit(GUI.Scene.MAIN_MENU)
	queue_free()
