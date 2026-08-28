class_name Minigame extends Control

signal completed
signal failed

func start() -> void:
	pass

func complete() -> void:
	completed.emit()

func fail() -> void:
	failed.emit()
