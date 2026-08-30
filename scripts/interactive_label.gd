class_name AnimatedLabel
extends Label

@export var base_scale := Vector2.ONE
@export var grow_scale := 1.1
@export var shrink_scale := 0.9
@export var animation_time := 0.1

@onready var animation_controller: AnimationController = %AnimationController

func _ready() -> void:
	pivot_offset_ratio = base_scale / 2.0

func animate_grow() -> void:
	await animation_controller.scale_to(base_scale * grow_scale, animation_time, Tween.TRANS_QUAD, Tween.EASE_OUT)
	await _return_to_base()

func animate_shrink() -> void:
	await animation_controller.scale_to(base_scale * shrink_scale, animation_time, Tween.TRANS_QUAD, Tween.EASE_OUT)

func _return_to_base() -> void:
	await animation_controller.scale_to(base_scale, animation_time, Tween.TRANS_BACK, Tween.EASE_OUT)
