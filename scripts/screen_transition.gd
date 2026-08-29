class_name ScreenTransition
extends ColorRect

func wipe_in(duration := 0.3) -> void:
	position.x = -320.0
	
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "position:x", 0.0, duration)
	
	await tween.finished

func wipe_out(duration := 0.3) -> void:
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self, "position:x", 320, duration)
	
	await tween.finished
