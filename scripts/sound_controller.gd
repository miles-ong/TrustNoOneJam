class_name SoundController
extends Node

var _player: AudioStreamPlayer

func _ready() -> void:
	_player = AudioStreamPlayer.new()
	add_child(_player)

func play(sound: AudioStream) -> void:
	if sound == null:
		return
	
	_player.stream = sound
	_player.play()
