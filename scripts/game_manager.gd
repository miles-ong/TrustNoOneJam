class_name GameManager extends Node

const STARTING_TIME := 60.0
const MIN_TIME := 10.0
const TIME_DECREASE := 1.0

@export var minigames: Array[PackedScene]

@onready var minigame_container: Control = %MinigameContainer
@onready var timer: Timer = $Timer

var active_minigames: Array[PackedScene]
var current_minigame: Minigame
var score := 0
var time_limit := STARTING_TIME

func _ready() -> void:
	start_run()

func start_run() -> void:
	score = 0
	time_limit = STARTING_TIME
	_refresh_active_minigames()
	_start_next_minigame()

func end_run() -> void:
	print("Game Over!")
	print("Final Score: ", score)

func _start_next_minigame() -> void:
	_clear_current_minigame()
	
	if active_minigames.is_empty():
		_refresh_active_minigames()
	
	var scene: PackedScene = active_minigames.pick_random()
	active_minigames.erase(scene)
	
	var minigame: Minigame = scene.instantiate()
	minigame.completed.connect(_on_minigame_completed)
	minigame.failed.connect(_on_minigame_failed)
	current_minigame = minigame
	
	minigame_container.add_child(minigame)
	
	timer.start(time_limit)
	
	minigame.start()

func _refresh_active_minigames() -> void:
	active_minigames = minigames.duplicate()

func _clear_current_minigame() -> void:
	if current_minigame == null:
		return
	
	current_minigame.queue_free()
	current_minigame = null

func _on_minigame_completed() -> void:
	score += 1
	time_limit = max(time_limit - TIME_DECREASE, MIN_TIME)
	_start_next_minigame()

func _on_minigame_failed() -> void:
	timer.stop()
	_clear_current_minigame()
	end_run()

func _on_timer_timeout() -> void:
	if current_minigame != null:
		current_minigame.fail()
