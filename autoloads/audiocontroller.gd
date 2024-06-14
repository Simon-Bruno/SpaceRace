extends Node

var menu = preload("res://assets/audio/music/Galactic Groove (Menu).ogg")
var lobby = preload("res://assets/audio/music/Galactic Showdown (Lobby).ogg")
var game = preload("res://assets/audio/music/Galactic Battle (In Game).ogg")

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


func change_audio_bus(bus_name: String):
	get_node("/root/Main/MusicController").bus = bus_name
	


