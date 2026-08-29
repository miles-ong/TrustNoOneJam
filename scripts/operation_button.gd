class_name OperationButton 
extends AnimatedButton

enum Operation {
	ADD,
	SUBTRACT,
	MULTIPLY,
	DIVIDE,
	NONE = -1
}

@export var operation: Operation
