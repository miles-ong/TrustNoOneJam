class_name AnimationController
extends Node

var _target: Node
var _tween: Tween

func _ready() -> void:
	_target = get_parent() as Node

func scale_to(target_scale: Vector2, duration: float, _trans := Tween.TRANS_QUAD, _ease := Tween.EASE_OUT) -> void:
	if _tween:
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_trans(_trans)
	_tween.set_ease(_ease)
	
	_tween.tween_property(_target, "offset_transform_scale", target_scale, duration)
	
	await _tween.finished
