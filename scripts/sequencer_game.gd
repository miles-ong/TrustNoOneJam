class_name SequencerGame
extends Minigame

var _sequence_order: Array[int] = []

@onready var buttons: GridContainer = %Buttons

func _ready() -> void:
	for button in buttons.get_children():
		if button is InteractiveButton:
			button.left_clicked.connect(_on_left_click.bind(button))
			button.right_clicked.connect(_on_right_click.bind(button))

func start() -> void:
	_generate_sequence(1, 99)
	receive_inputs = true

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
		_sequence_order.append(number)
		current_button_index += 1
	
	_sequence_order.sort()

func _on_left_click(button: InteractiveButton) -> void:
	if !receive_inputs:
		return
	
	_validate_sequence(button, false)

func _on_right_click(button: InteractiveButton) -> void:
	if !receive_inputs:
		return
	
	_validate_sequence(button, true)

func _validate_sequence(button: InteractiveButton, skip: bool) -> void:
	var target_number: int = _sequence_order.front()
	var font_color := button.get_theme_color("font_disabled_color")
	var valid := false
	
	if int(button.text) != target_number:
		font_color = Color.RED
		fail_message("Follow the sequence...") # fail on seq mismatch
	elif "1" in button.text and !skip:
		fail_one(get_one_position_button(button)) # fail on clicking wrong
	elif "1" not in button.text and skip:
		font_color = Color.RED
		fail_message("Should've clicked that one...") # fail on skipping wrong
	elif skip:
		font_color = Color.ORANGE
		valid = true
	else:
		font_color = Color.GREEN
		valid = true
	
	button.disable()
	button.add_theme_color_override("font_disabled_color", font_color)
	
	if valid:
		_sequence_order.remove_at(0)
		
		if _sequence_order.size() == 0:
			complete()
