# sound_manager.gd
extends Node

var navigate_sound: AudioStream = preload("res://Audio/glass_005.ogg")
var navigate_sound_vol: float = 0.5
var select_sound: AudioStream = preload("res://Audio/glass_006.ogg")
var select_sound_vol: float = 0.5

func play_sound(sound: AudioStream, volume: float = 1.0, pitch: float = 1.0):
	var audio_player = AudioStreamPlayer.new()
	audio_player.stream = sound
	audio_player.volume_db = linear_to_db(volume)
	audio_player.pitch_scale = pitch
	audio_player.autoplay = true
	add_child(audio_player)
	audio_player.play()
	await audio_player.finished
	audio_player.queue_free()

func play_navigate_sound():
	play_sound(navigate_sound, navigate_sound_vol)

func play_select_sound():
	play_sound(select_sound,select_sound_vol)
