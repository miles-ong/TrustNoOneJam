class_name SequencerGame
extends Minigame

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("heat"):
		complete()
