class_name AnimationController
extends Node

var _target_node: Node
var _target_shader_material: ShaderMaterial
var _offset_scale_tween: Tween
var _idle_tween: Tween

func _ready() -> void:
	_target_node = get_parent() as Node
	
	if _target_node is Control:
		if _target_node.material is ShaderMaterial:
			_target_shader_material = _target_node.material

func offset_scale_to(scale_: Vector2, duration: float, trans_: Tween.TransitionType, ease_: Tween.EaseType) -> Tween:
	if _offset_scale_tween:
		_offset_scale_tween.kill()
	
	return tween_property("offset_transform_scale", scale_, duration, trans_, ease_)

func tween_property(
	property: NodePath,
	target: Variant,
	duration: float,
	trans_: Tween.TransitionType,
	ease_: Tween.EaseType) -> Tween:
		var tween := create_tween()
		tween.set_trans(trans_).set_ease(ease_)
		
		tween.tween_property(_target_node, property, target, duration)
		
		return tween

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

func kill_tweens() -> void:
	if _offset_scale_tween:
		_offset_scale_tween.kill()
		_offset_scale_tween = null
	
	if _idle_tween:
		_idle_tween.kill()
		_idle_tween = null
