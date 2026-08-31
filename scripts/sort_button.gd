class_name SortButton
extends InteractiveButton

signal drag_started(button: SortButton)
signal drag_ended(button: SortButton)
signal drag_moved(button: SortButton, global_center_x: float)

@export var drag_scale := 1.05
@export var drag_animation_time := 0.1
@export var drag_z_index := 100

var dragging := false
var _drag_offset := Vector2.ZERO
var _drag_start_position := Vector2.ZERO
var _original_z_index: int

func _ready() -> void:
	super._ready()
	offset_transform_enabled = true
	offset_transform_visual_only = true
	offset_transform_pivot_ratio = Vector2(0.5, 0.5)
	_original_z_index = z_index

func _gui_input(event: InputEvent) -> void:
	if disabled:
		return
	
	if event is InputEventMouseButton:
		if event.button_index != MOUSE_BUTTON_LEFT:
			return
		
		if event.pressed:
			_start_drag()
		else:
			_end_drag()
	elif event is InputEventMouseMotion and dragging:
		_update_drag()

func reset_transform() -> void:
	offset_transform_position = Vector2.ZERO
	offset_transform_scale = _base_scale

func reset_drag() -> void:
	if dragging:
		dragging = false
	
	offset_transform_position = Vector2.ZERO
	offset_transform_scale = _base_scale
	z_index = _original_z_index

func _start_drag() -> void:
	dragging = true
	z_index = drag_z_index
	_drag_start_position = global_position
	var mouse_position := get_global_mouse_position()
	var button_center := _drag_start_position + size / 2.0
	_drag_offset = button_center - mouse_position
	
	drag_started.emit(self)
	
	animation_controller.offset_scale_to(_base_scale * drag_scale,drag_animation_time, Tween.TRANS_QUAD, Tween.EASE_OUT)

func _update_drag() -> void:
	var mouse_position := get_global_mouse_position()
	var desired_center := mouse_position + _drag_offset
	var desired_position := desired_center - size / 2.0
	offset_transform_position = desired_position - _drag_start_position
	
	drag_moved.emit(self, desired_center.x)


func _end_drag() -> void:
	if not dragging:
		return

	dragging = false
	z_index = _original_z_index
	animation_controller.offset_scale_to(_base_scale, drag_animation_time, Tween.TRANS_BACK, Tween.EASE_OUT)
	
	drag_ended.emit(self)
