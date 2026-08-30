class_name WaveBackground
extends ColorRect

@export var animation_duration := 1.0

var wave_color: Color:
	get:
		return _wave_color
	set(value):
		_set_shader_parameter("top_color", value)
		_wave_color = value
var wave_level: float:
	get:
		return _wave_level
	set(value):
		_set_shader_parameter("wave_level", value)
		_wave_level = value
var _shader_material: ShaderMaterial
var _wave_color := Color.WHITE
var _wave_level := 1.2

@onready var animation_controller: AnimationController = %AnimationController

func _ready() -> void:
	_shader_material = material as ShaderMaterial
	wave_color = _wave_color
	wave_level = _wave_level

func transition_color(color_: Color) -> Tween:
	_wave_color = color_
	return animation_controller.tween_shader_param("top_color", color_, animation_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)

func transition_wave_level(level: float) -> Tween:
	_wave_level = level
	return animation_controller.tween_shader_param("wave_level", level, animation_duration, Tween.TRANS_SINE, Tween.EASE_IN_OUT)

func _set_shader_parameter(target: String, value: Variant) -> void:
	_shader_material.set_shader_parameter(target, value)
