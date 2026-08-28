class_name OperationButton extends Button

enum Operation {
	ADD,
	SUBTRACT,
	MULTIPLY,
	DIVIDE,
	NONE = -1
}

@export var operation: Operation
