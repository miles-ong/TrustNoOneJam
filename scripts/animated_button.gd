class_name AnimatedButton
extends Button

@export var base_scale := Vector2.ONE
@export var press_scale := 0.9
@export var hover_scale := 1.05
@export var animation_time := 0.1

@onready var animation_controller: AnimationController = %AnimationController

func _ready() -> void:
	pivot_offset_ratio = base_scale / 2.0

func _gui_input(event: InputEvent) -> void:
	if disabled:
		return
	
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		
		if event.pressed:
			_press_animation()
		else:
			_release_animation()

func _on_mouse_entered() -> void:
	await animation_controller.scale_to(base_scale * hover_scale, animation_time, Tween.TRANS_QUAD, Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	await animation_controller.scale_to(base_scale, animation_time, Tween.TRANS_BACK, Tween.EASE_OUT)

func animate_press() -> void:
	await _press_animation()
	await _release_animation()

func _press_animation() -> void:
	await animation_controller.scale_to(base_scale * press_scale, animation_time, Tween.TRANS_QUAD, Tween.EASE_OUT)

func _release_animation() -> void:
	await animation_controller.scale_to(base_scale, animation_time, Tween.TRANS_BACK, Tween.EASE_OUT)
