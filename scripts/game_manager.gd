class_name GameManager extends Node

const STARTING_TIME := 60.0
const MIN_TIME := 10.0
const TIME_DECREASE := 5.0

@export var minigames: Array[PackedScene]
@export var win_sound: AudioStream
@export var lose_sound: AudioStream
@export var fail_on_input_sound: AudioStream

var active_minigames: Array[PackedScene]
var current_minigame: Minigame
var score := 0
var highscore := 0
var time_limit := STARTING_TIME
var _last_displayed_time := -1

@onready var wave_background: WaveBackground = %WaveBackground
@onready var main_menu: Control = %MainMenu
@onready var minigame_container: Control = %MinigameContainer
@onready var highscore_display: InteractiveLabel = %HighscoreDisplay
@onready var timer: Timer = $Timer
@onready var fail_overlay: ColorRect = %FailOverlay
@onready var stats: VBoxContainer = %Stats
@onready var time_display: InteractiveLabel = %TimeDisplay
@onready var score_display: Label = %ScoreDisplay
@onready var fail_one: InteractiveLabel = %FailOne
@onready var fail_message: InteractiveLabel = %FailMessage
@onready var screen_transition: ScreenTransition = %ScreenTransition
@onready var sound_controller: SoundController = %SoundController

func _ready() -> void:
	highscore_display.start_seesaw()

func _process(_delta: float) -> void:
	if current_minigame == null:
		return
	
	var current_time := ceili(timer.time_left)
	
	if current_time != _last_displayed_time:
		_last_displayed_time = current_time
		time_display.text = str(current_time)
		await time_display.grow().finished
		time_display.return_to_base_scale()

func start_run() -> void:
	timer.paused = true
	score = 0
	time_limit = STARTING_TIME
	_refresh_active_minigames()
	_start_next_minigame()

func end_run() -> void:
	fail_overlay.modulate.a = 0.0
	fail_one.modulate.a = 0.0
	fail_message.modulate.a = 0.0
	wave_background.refresh()
	stats.visible = false
	main_menu.visible = true
	
	if score > highscore:
		highscore = score
		highscore_display.text = "Highscore : %d" %highscore
	
	highscore_display.start_seesaw()
	
	await screen_transition.wipe_out()

func _start_next_minigame() -> void:
	await screen_transition.wipe_in()
	
	score_display.text = "Score: %d" %score
	timer.paused = false
	
	if main_menu.visible:
		highscore_display.stop_seesaw()
		stats.visible = true
		main_menu.visible = false
	
	_clear_current_minigame()
	
	if active_minigames.is_empty():
		_refresh_active_minigames()
	
	var scene: PackedScene = active_minigames.pick_random()
	active_minigames.erase(scene)
	
	var minigame: Minigame = scene.instantiate()
	minigame.completed.connect(_on_minigame_completed)
	minigame.failed.connect(_on_minigame_failed)
	minigame.fail_inputted.connect(_on_fail_inputted)
	minigame.stop_timer.connect(_stop_timer)
	current_minigame = minigame
	
	minigame_container.add_child(minigame)
	
	_last_displayed_time = -1
	timer.start(time_limit)
	minigame.setup(wave_background, fail_overlay, fail_one, fail_message)
	minigame.start()
	
	await screen_transition.wipe_out()

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
	sound_controller.play(win_sound)
	_start_next_minigame()

func _on_minigame_failed() -> void:
	sound_controller.play(lose_sound)
	await screen_transition.wipe_in()
	
	_clear_current_minigame()
	end_run()

func _on_fail_inputted() -> void:
	sound_controller.play(fail_on_input_sound)

func _stop_timer() -> void:
	timer.paused = true

func _on_play_button_pressed() -> void:
	start_run()

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_timer_timeout() -> void:
	if current_minigame != null:
		current_minigame.fail_message("Out of time...")
