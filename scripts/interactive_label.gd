class_name InteractiveLabel
extends Label

@export var grow_scale := 1.1
@export var shrink_scale := 0.9
@export var scale_animation_duration := 0.1
@export var modulate_animation_duration := 1.0

@export var seesaw_rotation_degrees := 2.0
@export var seesaw_duration := 2.0
@export var seesaw_color_a := Color.WHITE
@export var seesaw_color_b := Color.YELLOW

var _base_scale: Vector2
var _base_font_color: Color
var _seesaw_tween: Tween
var _seesaw_active := false

@onready var animation_controller: AnimationController = %AnimationController

func _ready() -> void:
	_base_scale = scale
	_base_font_color = get_theme_color("font_color")
	pivot_offset_ratio = _base_scale / 2.0

func grow() -> Tween:
	return animation_controller.offset_scale_to(_base_scale * grow_scale, scale_animation_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)

func shrink() -> Tween:
	return animation_controller.offset_scale_to(_base_scale * shrink_scale, scale_animation_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)

func fade_in(override_duration: float = modulate_animation_duration) -> Tween:
	return animation_controller.tween_property("modulate:a", 1.0, override_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)

func fade_out(override_duration: float = modulate_animation_duration) -> Tween:
	return animation_controller.tween_property("modulate:a", 0.0, override_duration, Tween.TRANS_QUAD, Tween.EASE_OUT)

func return_to_base_scale() -> Tween:
	return animation_controller.offset_scale_to(_base_scale, scale_animation_duration, Tween.TRANS_BACK, Tween.EASE_OUT)

func start_seesaw() -> void:
	stop_seesaw()
	_seesaw_active = true
	_set_font_color(seesaw_color_a)
	_run_seesaw_phase(true)

func stop_seesaw() -> void:
	_seesaw_active = false
	
	if _seesaw_tween != null and _seesaw_tween.is_valid():
		_seesaw_tween.kill()
	_seesaw_tween = null
	
	rotation_degrees = 0.0
	_set_font_color(_base_font_color)
	return_to_base_scale()

func _run_seesaw_phase(swing_positive: bool) -> void:
	if !_seesaw_active:
		return
	
	var rotation_target := seesaw_rotation_degrees if swing_positive else -seesaw_rotation_degrees
	var scale_target := _base_scale * grow_scale if swing_positive else _base_scale * shrink_scale
	var color_from := seesaw_color_a if swing_positive else seesaw_color_b
	var color_to := seesaw_color_b if swing_positive else seesaw_color_a
	
	_seesaw_tween = create_tween()
	_seesaw_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	_seesaw_tween.tween_property(self, "rotation_degrees", rotation_target, seesaw_duration)
	_seesaw_tween.parallel().tween_property(self, "offset_transform_scale", scale_target, seesaw_duration)
	_seesaw_tween.parallel().tween_method(_set_font_color, color_from, color_to, seesaw_duration)

	_seesaw_tween.finished.connect(_run_seesaw_phase.bind(!swing_positive), CONNECT_ONE_SHOT)

func _set_font_color(color: Color) -> void:
	add_theme_color_override("font_color", color)
