extends Node

var menu = preload("res://assets/music/Galactic Groove (Menu).ogg")
var lobby = preload("res://assets/music/Galactic Showdown (Lobby).ogg")
var game = preload("res://assets/music/Galactic Battle (In Game).ogg")

func _ready():
	play_menu_music()

func play_menu_music():
	get_node("/root/Main/MusicController").stream = menu
	get_node("/root/Main/MusicController").play()

func play_lobby_music():
	get_node("/root/Main/MusicController").stream = lobby
	get_node("/root/Main/MusicController").play()
	
func play_game_music():
	get_node("/root/Main/MusicController").stream = game
	get_node("/root/Main/MusicController").play()
