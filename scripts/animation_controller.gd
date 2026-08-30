class_name AnimationController
extends Node

var _target_node: Node
var _target_shader_material: ShaderMaterial
var _scale_tween: Tween

func _ready() -> void:
	_target_node = get_parent() as Node
	
	if _target_node is Control:
		if _target_node.material is ShaderMaterial:
			_target_shader_material = _target_node.material

func scale_to(target_scale: Vector2, duration: float, trans_: Tween.TransitionType, ease_: Tween.EaseType) -> void:
	if _scale_tween:
		_scale_tween.kill()
	
	_scale_tween = create_tween()
	_scale_tween.set_trans(trans_).set_ease(ease_)
	
	_scale_tween.tween_property(_target_node, "offset_transform_scale", target_scale, duration)
	
	await _scale_tween.finished

func tween_shader_param(
	param: String,
	target: Variant,
	duration: float,
	trans_: Tween.TransitionType,
	ease_: Tween.EaseType) -> Tween:
		var tween := create_tween()
		tween.set_trans(trans_).set_ease(ease_)
		
		tween.tween_property(_target_shader_material, "shader_parameter/" + param, target, duration)
		
		return tween
