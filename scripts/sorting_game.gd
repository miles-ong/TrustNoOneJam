class_name SortingGame
extends Minigame

@export var start_dragging_sound: AudioStream
@export var end_dragging_sound: AudioStream

var _dragged_button: SortButton
var _numbers: Array[int] = []
var _drag_original_index := -1
var _drag_target_index := -1
var _original_slot_centers: Array[float] = []
var _sibling_tweens: Dictionary = {}

@onready var buttons: HBoxContainer = %Buttons
@onready var confirm_button: InteractiveButton = %ConfirmButton
@onready var sound_controller: SoundController = %SoundController

func _ready() -> void:
	for button in buttons.get_children():
		if button is SortButton:
			button.drag_started.connect(_on_drag_started)
			button.drag_ended.connect(_on_drag_ended)
	
	confirm_button.left_clicked.connect(_on_confirm)

func start() -> void:
	_generate_numbers(2,9)
	receive_inputs = true

func fail_one(one_position: Vector2) -> void:
	_lock_buttons()
	await super.fail_one(one_position)

func _generate_numbers(min_range: int, max_range: int) -> void:
	_numbers.clear()
	
	var buttons_count = buttons.get_child_count()
	var generated_numbers: Array[int] = [1]
	
	while generated_numbers.size() < buttons_count:
		var number := randi_range(min_range, max_range)
		
		if generated_numbers.has(number):
			continue
		
		generated_numbers.append(number)
	
	generated_numbers.shuffle()
	
	for i in range(buttons_count):
		var button := buttons.get_child(i) as SortButton
		
		if button == null:
			continue
		
		button.text = str(generated_numbers[i])
		button.reset_transform()

func _on_drag_started(button: SortButton) -> void:
	if !receive_inputs:
		return
	
	_dragged_button = button
	
	if button.text == "1":
		fail_one(get_one_position_button(button))
		return
	
	_drag_original_index = button.get_index()
	_drag_target_index = _drag_original_index
	_original_slot_centers.clear()
	_sibling_tweens.clear()
	
	for child in buttons.get_children():
		if child is SortButton:
			_original_slot_centers.append(child.global_position.x + child.size.x / 2.0)
	
	button.drag_moved.connect(_on_drag_moved)
	
	sound_controller.play(start_dragging_sound)

func _on_drag_moved(button: SortButton, mouse_x: float) -> void:
	var new_target := _compute_target_index(button, mouse_x)
	
	if new_target != _drag_target_index:
		_drag_target_index = new_target
		_animate_siblings_to_target(button)
	
	_verify_sibling_positions(button)

func _on_drag_ended(button: SortButton) -> void:
	if !receive_inputs:
		return
	
	if button != _dragged_button:
		return
	
	if button.drag_moved.is_connected(_on_drag_moved):
		button.drag_moved.disconnect(_on_drag_moved)
	
	_dragged_button = null
	
	for tween in _sibling_tweens.values():
		if tween != null and tween.is_valid():
			tween.kill()
	
	_sibling_tweens.clear()
	
	if _drag_target_index != _drag_original_index:
		buttons.move_child(button, _drag_target_index)
	
	for child in buttons.get_children():
		if child is SortButton:
			child.reset_transform()
	
	sound_controller.play(end_dragging_sound)

func _compute_target_index(button: SortButton, mouse_x: float) -> int:
	var closest_index := 0
	var closest_distance := INF
	
	for i in _original_slot_centers.size():
		var distance := absf(mouse_x - _original_slot_centers[i])
		
		if distance < closest_distance:
			closest_distance = distance
			closest_index = i
	
	return closest_index

func _target_offset_for_index(index: int, slot_width: float) -> float:
	if _drag_original_index < index and index <= _drag_target_index:
		return -slot_width
	elif _drag_target_index <= index and index < _drag_original_index:
		return slot_width
	
	return 0.0

func _animate_siblings_to_target(dragged: SortButton) -> void:
	var slot_width := dragged.size.x + buttons.get_theme_constant("separation")
	
	for child in buttons.get_children():
		if child == dragged or not child is SortButton:
			continue
		
		var target_x := _target_offset_for_index(child.get_index(), slot_width)
		
		if _sibling_tweens.has(child):
			var old_tween: Tween = _sibling_tweens[child]
			
			if old_tween != null and old_tween.is_valid():
				old_tween.kill()
		
		var tween := child.create_tween()
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		tween.tween_property(child, "offset_transform_position:x", target_x, 0.12)
		
		_sibling_tweens[child] = tween

func _verify_sibling_positions(dragged: SortButton) -> void:
	var slot_width := dragged.size.x + buttons.get_theme_constant("separation")
	
	for child in buttons.get_children():
		if child == dragged or child is not SortButton:
			continue
		
		var expected_x := _target_offset_for_index(child.get_index(), slot_width)
		
		var tween: Tween = _sibling_tweens.get(child)
		var tween_running := tween != null and tween.is_valid() and tween.is_running()
		
		if not tween_running and not is_equal_approx(child.offset_transform_position.x, expected_x):
			child.offset_transform_position.x = expected_x

func _on_confirm() -> void:
	if !receive_inputs:
		return
	
	if _is_sorted():
		complete()
	else:
		fail_message("Double check next time...")

func _is_sorted() -> bool:
	var previous_number := -1
	
	for child in buttons.get_children():
		var button := child as SortButton
		
		if button == null:
			continue
		
		var number := int(button.text)
		
		if number < previous_number:
			return false
		
		previous_number = number
	
	return true

func _lock_buttons() -> void:
	confirm_button.disable()
	
	for child in buttons.get_children():
		if child is SortButton:
			child.reset_drag()
			child.disable()
