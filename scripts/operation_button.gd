class_name OperationButton 
extends InteractiveButton

enum Operation {
	ADD,
	SUBTRACT,
	MULTIPLY,
	DIVIDE,
	NONE = -1
}

@export var operation: Operation
