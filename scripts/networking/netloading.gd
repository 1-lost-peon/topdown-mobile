extends Node

signal step_changed(step: Step, progress: float, message: String)

enum Step {
	IDLE,
	SEARCHING_FOR_SERVER,
	SERVER_FOUND,
	CONNECTING,
	CONNECTED,
	REGISTERING_PLAYER,
	PLAYER_REGISTERED,
	READY,
	FAILED
}

const PROGRESS = {
	Step.IDLE: 0.0,
	Step.SEARCHING_FOR_SERVER: 1.0,
	Step.SERVER_FOUND: 2.0,
	Step.CONNECTING: 3.0,
	Step.CONNECTED: 4.0,
	Step.REGISTERING_PLAYER: 5.0,
	Step.PLAYER_REGISTERED: 6.0,
	Step.READY: 8.0,
	Step.FAILED: 0.0,
}

var step: Step = Step.IDLE


func set_step(new_step: Step, message: String = "") -> void:
	step = new_step
	var progress = PROGRESS.get(step, 0.0)
	
	if message.is_empty():
		message = get_message(step)
	
	step_changed.emit(step, progress, message)


func get_message(step: Step) -> String:
	match step:
		Step.IDLE:
			return "Idle"
		Step.SEARCHING_FOR_SERVER:
			return "Searching for server..."
		Step.SERVER_FOUND:
			return "Server found."
		Step.CONNECTING:
			return "Connecting to server..."
		Step.CONNECTED:
			return "Connected."
		Step.REGISTERING_PLAYER:
			return "Registering player..."
		Step.PLAYER_REGISTERED:
			return "Player registered."
		Step.READY:
			return "Ready."
		Step.FAILED:
			return "Connection failed."
		_:
			return "Loading..."
	
