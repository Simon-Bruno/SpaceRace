extends Node

# Paths
const MUSIC_CONTROLLER_PATH = "/root/Main/MusicController"
const SFX_CONTROLLER_PATH = "/root/Main/SfxController"
const MASTER_SLIDER_PATH = "/root/Main/SpawnedItems/World/CanvasLayer/PauseMenu/Settings/MarginContainer/VBoxContainer/Settings_Tab_Container/TabContainer/Audio/MarginContainer/ScrollContainer/VBoxContainer/Audio_Slider_Settings/HBoxContainer/HSlider"
const MUSIC_SLIDER_PATH = "/root/Main/SpawnedItems/World/CanvasLayer/PauseMenu/Settings/MarginContainer/VBoxContainer/Settings_Tab_Container/TabContainer/Audio/MarginContainer/ScrollContainer/VBoxContainer/Audio_Slider_Settings2/HBoxContainer/HSlider"
const SFX_SLIDER_PATH = "/root/Main/SpawnedItems/World/CanvasLayer/PauseMenu/Settings/MarginContainer/VBoxContainer/Settings_Tab_Container/TabContainer/Audio/MarginContainer/ScrollContainer/VBoxContainer/Audio_Slider_Settings3/HBoxContainer/HSlider"

# Music
var menu_music = preload("res://assets/audio/music/Galactic Groove (Menu).ogg")
var lobby_music = preload("res://assets/audio/music/Galactic Showdown (Lobby).ogg")
var game_music = preload("res://assets/audio/music/Galactic Battle (In Game).ogg")

# Sound effects
var walking_sfx = preload("res://assets/audio/sfx/walking.ogg")
var jump_sfx = preload("res://assets/audio/sfx/jump.ogg")
var item_pickup_sfx = preload("res://assets/audio/sfx/item_pickup.ogg")
var attack_fist_sfx = preload("res://assets/audio/sfx/attack_fist.ogg")
var teleportation_sfx = preload("res://assets/audio/sfx/teleportation.ogg")
var button_sfx = preload("res://assets/audio/sfx/button.ogg")


# To keep track of h_slider values after being muted
var cur_hslider_val_master: float
var cur_hslider_val_music: float
var cur_hslider_val_sfx: float  


func _ready():
	play_menu_music()


func play_music(music):
	var music_controller = get_node(MUSIC_CONTROLLER_PATH)
	music_controller.stream = music
	change_audio_bus_music_controller("Music")
	music_controller.play()


func play_sfx(sfx):
	var sfx_controller = get_node(SFX_CONTROLLER_PATH)
	sfx_controller.stream = sfx
	change_audio_bus_sfx_controller("Sfx")
	sfx_controller.play()


func stop_sfx(sfx):
	var sfx_controller = get_node(SFX_CONTROLLER_PATH)
	sfx_controller.stream = sfx
	change_audio_bus_sfx_controller("Sfx")
	sfx_controller.stop()


func play_menu_music():
	play_music(menu_music)


func play_lobby_music():
	play_music(lobby_music)


func play_game_music():
	play_music(game_music)


func play_walking_sfx():
	play_sfx(walking_sfx)


func stop_walking_sfx():
	stop_sfx(walking_sfx)


func play_jump_sfx():
	play_sfx(jump_sfx)


func play_item_pickup_sfx():
	play_sfx(item_pickup_sfx)


func play_attack_fist_sfx():
	play_sfx(attack_fist_sfx)


func play_teleportation_sfx():
	play_sfx(teleportation_sfx)


func play_button_sfx():
	play_sfx(button_sfx)


func get_slider(path):
	return get_node(path)


func mute_slider(path, var_name):
	var slider = get_slider(path)
	set(var_name, slider.value)
	slider.value = 0


func unmute_slider(path, var_name):
	get_slider(path).value = get(var_name)


func mute_master():
	mute_slider(MASTER_SLIDER_PATH, 'cur_hslider_val_master')


func unmute_master():
	unmute_slider(MASTER_SLIDER_PATH, 'cur_hslider_val_master')


func mute_music():
	mute_slider(MUSIC_SLIDER_PATH, 'cur_hslider_val_music')


func unmute_music():
	unmute_slider(MUSIC_SLIDER_PATH, 'cur_hslider_val_music')


func mute_sfx():
	mute_slider(SFX_SLIDER_PATH, 'cur_hslider_val_sfx')


func unmute_sfx():
	unmute_slider(SFX_SLIDER_PATH, 'cur_hslider_val_sfx')


func change_audio_bus_music_controller(bus_name: String):
	get_node(MUSIC_CONTROLLER_PATH).bus = bus_name


func change_audio_bus_sfx_controller(bus_name : String):
	get_node(SFX_CONTROLLER_PATH).bus = bus_name
