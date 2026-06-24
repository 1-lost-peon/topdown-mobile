extends Screen

@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar


func _ready() -> void:
	super()
	Network.loading.step_changed.connect(_update_load_bar)

func _process(_delta: float) -> void:
	if can_end_screen and progress_bar.value == progress_bar.max_value:
		end_scene()


func _update_load_bar(_step: Network.NetLoading.Step, progress: float, _message: String):
	progress_bar.value = progress
