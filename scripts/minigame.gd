class_name Minigame extends Control

signal completed
signal failed

const FAIL_FREEZE_TIME := 0.5
const FAIL_FADE_TIME := 0.8
const FAIL_HOLD_TIME := 0.5

var receive_inputs := false
var _fail_overlay: ColorRect
var _fail_digit: Label

func setup(fail_overlay: ColorRect, fail_digit: Label) -> void:
	_fail_overlay = fail_overlay
	_fail_digit = fail_digit

func start() -> void:
	pass

func complete() -> void:
	receive_inputs = false
	await telegraph_complete()
	completed.emit()

func fail(one_position: Vector2) -> void:
	receive_inputs = false
	await _telegraph_fail(one_position)
	failed.emit()

func get_one_position() -> Vector2:
	return Vector2.ZERO

func get_one_position_label(_label: Label) -> Vector2:
	var index := _label.text.find("1")
	var character_rect := _label.get_character_bounds(index)
	
	return _label.global_position + character_rect.position

func get_one_position_button(_button: Button) -> Vector2:
	var index := _button.text.find("1")
	var font := _button.get_theme_font("font")
	var font_size := _button.get_theme_font_size("font_size")
	var text_size := font.get_string_size(_button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var prefix_size := font.get_string_size(_button.text.substr(0, index), HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var text_start_x := (_button.size.x - text_size.x) / 2.0
	var one_x := text_start_x + prefix_size.x
	var one_y := (_button.size.y - font.get_height(font_size)) / 2.0
	
	return _button.global_position + Vector2(one_x, one_y)

func telegraph_complete() -> void:
	pass

func _telegraph_fail(one_position: Vector2) -> void:
	_fail_overlay.modulate.a = 0.0
	
	_fail_digit.text = "1"
	_fail_digit.modulate.a = 0.0
	_fail_digit.modulate.a = 0.0
	_fail_digit.global_position = one_position
	
	await get_tree().create_timer(FAIL_FREEZE_TIME).timeout
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(_fail_overlay, "modulate:a", 1.0, FAIL_FADE_TIME)
	tween.tween_property(_fail_digit, "modulate:a", 1.0, FAIL_FADE_TIME)
	await tween.finished
	await get_tree().create_timer(FAIL_HOLD_TIME).timeout
