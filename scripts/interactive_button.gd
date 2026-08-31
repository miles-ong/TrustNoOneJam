class_name InteractiveButton
extends Button

signal left_clicked
signal right_clicked

@export var press_scale := 0.9
@export var hover_scale := 1.05
@export var animation_time := 0.1
@export var click_sound: AudioStream

var _base_scale: Vector2

@onready var animation_controller: AnimationController = %AnimationController
@onready var sound_controller: SoundController = %SoundController

func _ready() -> void:
	_base_scale = scale
	offset_transform_enabled = true
	offset_transform_visual_only = true
	offset_transform_pivot_ratio = Vector2(0.5, 0.5)
	offset_transform_scale = _base_scale

func enable() -> void:
	if disabled == false:
		return
	
	disabled = false
	mouse_filter = Control.MOUSE_FILTER_STOP
	await animation_controller.offset_scale_to(_base_scale, animation_time, Tween.TRANS_BACK, Tween.EASE_OUT).finished

func disable() -> void:
	if disabled == true:
		return
	
	disabled = true
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	await animation_controller.offset_scale_to(_base_scale, animation_time, Tween.TRANS_BACK, Tween.EASE_OUT).finished

func _gui_input(event: InputEvent) -> void:
	if disabled:
		return
	
	if event is InputEventMouseButton:
		if event.pressed:
			sound_controller.play(click_sound)
			_press_animation()
			
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					left_clicked.emit()
				MOUSE_BUTTON_RIGHT:
					right_clicked.emit()
		else:
			_release_animation()

func _on_mouse_entered() -> void:
	if disabled:
		return
	
	await animation_controller.offset_scale_to(_base_scale * hover_scale, animation_time, Tween.TRANS_QUAD, Tween.EASE_OUT).finished

func _on_mouse_exited() -> void:
	if disabled:
		return
	
	await animation_controller.offset_scale_to(_base_scale, animation_time, Tween.TRANS_BACK, Tween.EASE_OUT).finished

func telegraph_press() -> void:
	if disabled:
		return
	
	sound_controller.play(click_sound)
	await _press_animation()
	await _release_animation()

func _press_animation() -> void:
	await animation_controller.offset_scale_to(_base_scale * press_scale, animation_time, Tween.TRANS_QUAD, Tween.EASE_OUT).finished

func _release_animation() -> void:
	await animation_controller.offset_scale_to(_base_scale, animation_time, Tween.TRANS_BACK, Tween.EASE_OUT).finished
