class_name Minigame extends Control

signal completed
signal failed

const FAIL_FREEZE_TIME := 0.5
const FAIL_FADE_TIME := 0.8
const FAIL_HOLD_TIME := 0.5

var _fail_overlay: ColorRect
var _fail_digit: Label
var _failed := false

func setup(fail_overlay: ColorRect, fail_digit: Label) -> void:
	_fail_overlay = fail_overlay
	_fail_digit = fail_digit

func start() -> void:
	pass

func complete() -> void:
	completed.emit()

func fail(one_position: Vector2) -> void:
	if _failed:
		return
	
	_failed = true
	await _telegraph_fail(one_position)
	failed.emit()

func get_one_position() -> Vector2:
	return Vector2.ZERO

func get_one_position_label(_label: Label) -> Vector2:
	var index := _label.text.find("1")
	var character_rect := _label.get_character_bounds(index)
	
	return _label.global_position + character_rect.position

func get_one_position_button(_button: Button) -> Vector2:
	return Vector2.ZERO

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
