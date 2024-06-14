extends Node

var menu = preload("res://assets/audio/music/Galactic Groove (Menu).ogg")
var lobby = preload("res://assets/audio/music/Galactic Showdown (Lobby).ogg")
var game = preload("res://assets/audio/music/Galactic Battle (In Game).ogg")

#var audio_slider_scene = preload("res://scenes/settings/audio_slider_settings.tscn").instantiate()
#var audio_slider_script = preload("res://scripts/settings/audio_slider_settings.gd").new()

func _ready():
	play_menu_music()


func play_menu_music():
	get_node("/root/Main/MusicController").stream = menu
	change_audio_bus("Music")
	get_node("/root/Main/MusicController").play()


func play_lobby_music():
	get_node("/root/Main/MusicController").stream = lobby
	change_audio_bus("Music")
	get_node("/root/Main/MusicController").play()


func play_game_music():
	get_node("/root/Main/MusicController").stream = game
	change_audio_bus("Music")
	get_node("/root/Main/MusicController").play()


func mute_master():
	#audio_slider_scene.
	#audio_slider_script.set_slider_value(0)
	AudioServer.set_bus_volume_db(0, -80)


func unmute_master():
	AudioServer.set_bus_volume_db(0, 0)


func mute_music():
	AudioServer.set_bus_volume_db(1, -80)


func unmute_music():
	AudioServer.set_bus_volume_db(1, 0)


func mute_sfx():
	AudioServer.set_bus_volume_db(2, -80)


func unmute_sfx():
	AudioServer.set_bus_volume_db(2, 0)


func change_audio_bus(bus_name: String):
	get_node("/root/Main/MusicController").bus = bus_name
	


