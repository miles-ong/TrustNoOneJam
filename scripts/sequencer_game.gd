class_name SequencerGame
extends Minigame

var _sequence_order: Array[int] = []
var _receive_inputs = false

@onready var buttons: GridContainer = %Buttons

func _ready() -> void:
	for button in buttons.get_children():
		if button is Button:
			button.gui_input.connect(_on_button_pressed.bind(button))

func start() -> void:
	_generate_sequence(0, 99)
	_receive_inputs = true

func get_one_position() -> Vector2:
	return Vector2.ZERO

func _generate_sequence(min_range: int, max_range: int) -> void:
	_sequence_order.clear()
	
	var buttons_size = buttons.get_children().size()
	var current_button_index = 1
	
	while current_button_index <= buttons_size:
		var number := randi_range(min_range, max_range)
		
		while _sequence_order.has(number):
			number = randi_range(min_range, max_range)
		
		var current_button: Button = buttons.get_node("S%dButton" %current_button_index)
		current_button.text = str(number)
		
		if not "1" in str(number):
			_sequence_order.append(number)
		
		current_button_index += 1
	
	_sequence_order.sort()

func _handle_left_click(button: Button) -> void:
	if "1" in button.text:
		fail(get_one_position_button(button))
		return
	
	var target_number: int = _sequence_order.front()
	print("Target: %d, Pressed: %d" %[target_number, int(button.text)])
	
	if int(button.text) != target_number:
		fail(get_one_position_button(button))
		return
	
	button.disabled = true
	button.add_theme_color_override("font_disabled_color", Color.GREEN)
	_sequence_order.remove_at(0)
	
	if _sequence_order.size() == 0:
		complete()

func _handle_right_click(button: Button) -> void:
	if int(button.text) in _sequence_order:
		fail(get_one_position_button(button))
		return
	
	button.disabled = true
	button.add_theme_color_override("font_disabled_color", Color.ORANGE)

func _on_button_pressed(event: InputEvent, button: Button) -> void:
	if !_receive_inputs:
		return
	
	if event is InputEventMouseButton:
		if not event.pressed:
			return
		
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_handle_left_click(button)
			MOUSE_BUTTON_RIGHT:
				_handle_right_click(button)
