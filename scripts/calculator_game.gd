class_name CalculatorGame 
extends Minigame

const MAX_INPUT_LENGTH := 9
const OPERATION_SYMBOLS := {
	OperationButton.Operation.ADD: "+",
	OperationButton.Operation.SUBTRACT: "-",
	OperationButton.Operation.MULTIPLY: "X",
	OperationButton.Operation.DIVIDE: "/",
	OperationButton.Operation.NONE: "",
}

var operation_buttons: Array[OperationButton] = []
var left_value: String
var right_value: String
var current_operation: OperationButton.Operation = OperationButton.Operation.NONE:
	get: 
		return _current_operation
	set(value):
		for button in operation_buttons:
			button.disabled = value != OperationButton.Operation.NONE
		
		_current_operation = value
var _current_operation: OperationButton.Operation = OperationButton.Operation.NONE
var _receive_inputs := false
var _target_output := 0
var _disabled_number_count := 2
var _disabled_numbers: Array[int] = []

@onready var target: Label = %Target
@onready var last_execution: Label = %LastExecution
@onready var current_input: Label = %CurrentInput
@onready var calculator_buttons: GridContainer = %CalculatorButtons
@onready var equals_button: Button = %EqualsButton

func _ready() -> void:
	for button in calculator_buttons.get_children():
		if button is OperationButton:
			operation_buttons.append(button)
			button.pressed.connect(_on_operation_button_pressed.bind(button))
		elif button is Button and button != equals_button:
			button.pressed.connect(_on_button_pressed.bind(button))

func _unhandled_input(event: InputEvent) -> void:
	if !_receive_inputs:
		return
	
	if event.is_action_pressed("calc_add"):
		_enter_operation(OperationButton.Operation.ADD)
	elif event.is_action_pressed("calc_subtract"):
		_enter_operation(OperationButton.Operation.SUBTRACT)
	elif event.is_action_pressed("calc_multiply"):
		_enter_operation(OperationButton.Operation.MULTIPLY)
	elif event.is_action_pressed("calc_divide"):
		_enter_operation(OperationButton.Operation.DIVIDE)
	elif event.is_action_pressed("calc_equals"):
		_execute_formula()
	elif event.is_action_pressed("calc_delete"):
		_remove_input()
	else:
		for i in range(10):
			if event.is_action_pressed("calc_%d" %i):
				_append_input(str(i))
				return

func start() -> void:
	_target_output = _generate_safe_number(0, 99)
	var initial_input := _generate_safe_number(0, 99)
	
	while initial_input == _target_output:
		initial_input = _generate_safe_number(0, 99)
	
	left_value = str(initial_input)
	_update_input_display()
	
	while _disabled_numbers.size() < _disabled_number_count:
		var number = _generate_safe_number(0, 9)
		
		if _disabled_numbers.has(number):
			continue
		
		_disabled_numbers.append(number)
		var button: Button = calculator_buttons.get_node("%dButton" %number)
		button.disabled = true
	
	_receive_inputs = true

func _update_input_display(equals_result: int = -1) -> void:
	target.text = "MAKE=%d" % _target_output
	
	var updated_input = left_value + OPERATION_SYMBOLS[current_operation] + right_value
	
	if updated_input == "":
		updated_input = "0"
	
	if equals_result >= 0:
		last_execution.text = updated_input + equals_button.text
		updated_input = str(equals_result)
	
	current_input.text = updated_input

func _append_input(value: String) -> void:
	if _check_length() == false:
		return
	
	if _disabled_numbers.has(int(value)):
		return
	
	if current_operation == OperationButton.Operation.NONE:
		left_value += value
	else:
		right_value += value
	
	if value == "1":
		fail()
	
	_update_input_display()

func _remove_input() -> void:
	if current_operation == OperationButton.Operation.NONE:
		left_value = left_value.left(-1)
	else:
		if right_value.length() == 0:
			current_operation = OperationButton.Operation.NONE
		else:
			right_value = right_value.left(-1)
	
	_update_input_display()

func _enter_operation(value: OperationButton.Operation) -> void:
	if current_operation != OperationButton.Operation.NONE or _check_length() == false:
		return
	
	current_operation = value
	_update_input_display()

func _execute_formula() -> void:
	if current_operation == OperationButton.Operation.NONE or right_value == "":
		return
	
	var output := 0
	
	match current_operation:
		OperationButton.Operation.ADD:
			output = int(left_value) + int(right_value)
		OperationButton.Operation.SUBTRACT:
			output = max(int(left_value) - int(right_value), 0)
		OperationButton.Operation.MULTIPLY:
			output = int(left_value) * int(right_value)
		OperationButton.Operation.DIVIDE:
			if right_value == "0":
				output = 0
			else:
				output = int(left_value) / int(right_value)
	
	if output == _target_output:
		complete()
	
	_update_input_display(output)
	
	left_value = str(output)
	right_value = ""
	current_operation = OperationButton.Operation.NONE

func _check_length() -> bool:
	return left_value.length() + OPERATION_SYMBOLS[current_operation].length() + right_value.length() < MAX_INPUT_LENGTH

func _generate_safe_number(min_range: int, max_range: int) -> int:
	var number := randi_range(min_range, max_range)
	
	while "1" in str(number):
		number = randi_range(min_range, max_range)
	
	return number

func _on_button_pressed(button: Button) -> void:
	if !_receive_inputs:
		return
	
	_append_input(button.text)

func _on_operation_button_pressed(button: OperationButton) -> void:
	if !_receive_inputs:
		return
	
	_enter_operation(button.operation)

func _on_equals_button_pressed() -> void:
	if !_receive_inputs:
		return
		
	_execute_formula()
