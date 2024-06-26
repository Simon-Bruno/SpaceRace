extends Node

# Paths
const MUSIC_CONTROLLER_PATH = "/root/Main/MusicController"
const SFX_CONTROLLER_PATH = "/root/Main/SfxController"
const MASTER_SLIDER_PATH = "/root/Main/SpawnedItems/World/PauseMenu/Settings/MarginContainer/VBoxContainer/Settings_Tab_Container/TabContainer/Audio/MarginContainer/ScrollContainer/VBoxContainer/Audio_Slider_Settings/HBoxContainer/HSlider"
const MUSIC_SLIDER_PATH = "/root/Main/SpawnedItems/World/PauseMenu/Settings/MarginContainer/VBoxContainer/Settings_Tab_Container/TabContainer/Audio/MarginContainer/ScrollContainer/VBoxContainer/Audio_Slider_Settings2/HBoxContainer/HSlider"
const SFX_SLIDER_PATH = "/root/Main/SpawnedItems/World/PauseMenu/Settings/MarginContainer/VBoxContainer/Settings_Tab_Container/TabContainer/Audio/MarginContainer/ScrollContainer/VBoxContainer/Audio_Slider_Settings3/HBoxContainer/HSlider"

# Music
var menu_music = preload("res://assets/audio/music/Galactic Groove (Menu).ogg")
var lobby_music = preload("res://assets/audio/music/Galactic Showdown (Lobby).ogg")
var game_music = preload("res://assets/audio/music/Galactic Battle (In Game).ogg")
var finish_menu_music = preload("res://assets/audio/music/finish_menu_audio.ogg")

# Sound effects
var attack_fist_sfx = preload("res://assets/audio/sfx/attack_fist.ogg")
var bomb_explosion_sfx = preload("res://assets/audio/sfx/bomb_explosion.ogg")
var bomb_ignition_sfx = preload("res://assets/audio/sfx/bomb_ignition.ogg")
var boss_hurt_sfx = preload("res://assets/audio/sfx/boss_hurt.ogg")
var boss_roar_sfx = preload("res://assets/audio/sfx/boss_roar.ogg")
var boss_spawn_minions_sfx = preload("res://assets/audio/sfx/boss_spawn_minions.ogg")
var button_sfx = preload("res://assets/audio/sfx/button.ogg")
var door_sfx = preload("res://assets/audio/sfx/door.ogg")
var electric_ray_sfx = preload("res://assets/audio/sfx/electric_ray.ogg")
var fan_sfx = preload("res://assets/audio/sfx/fan.ogg")
var gun_ray_beam_sfx = preload("res://assets/audio/sfx/gun_ray_beam.ogg")
var health_pickup_regen_sfx = preload("res://assets/audio/sfx/health_pickup_regen.ogg")
var item_pickup_sfx = preload("res://assets/audio/sfx/item_pickup.ogg")
var jump_sfx = preload("res://assets/audio/sfx/jump_.ogg")
var key_in_lock_sfx = preload("res://assets/audio/sfx/key_in_lock.ogg")
var laser_hit_player_sfx = preload("res://assets/audio/sfx/laser_hit_player.ogg")
var player_death_sfx = preload("res://assets/audio/sfx/player_death.ogg")
var potion_open_sfx = preload("res://assets/audio/sfx/potion_open.ogg")
var potion_pickup_sfx = preload("res://assets/audio/sfx/potion_pickup.ogg")
var pressure_plate_sfx = preload("res://assets/audio/sfx/pressure_plate_fixed.ogg")
var rizz_sfx = preload("res://assets/audio/sfx/rizz.ogg")
var teleportation_sfx = preload("res://assets/audio/sfx/teleportation.ogg")
var ui_press_sfx = preload("res://assets/audio/sfx/ui_press.ogg")
var walking_sfx = preload("res://assets/audio/sfx/walking.ogg")

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

#func play_sfx(sfx, volume_db : float = 0):
	#var sfx_controller = get_node(SFX_CONTROLLER_PATH)
	#sfx_controller.stream = sfx
	#sfx_controller.volume_db = volume_db
	#change_audio_bus_sfx_controller("Sfx")
	#sfx_controller.play()
	
func play_sfx(sfx, volume_db : float = 0):
	var sfx_controller = AudioStreamPlayer.new()
	sfx_controller.stream = sfx
	sfx_controller.volume_db = volume_db
	change_audio_bus_sfx_controller("Sfx", sfx_controller)
	add_child(sfx_controller)
	sfx_controller.play()
	await sfx_controller.finished
	sfx_controller.queue_free()

func play_menu_music():
	play_music(menu_music)

func play_lobby_music():
	play_music(lobby_music)

func play_game_music():
	play_music(game_music)

func play_finish_menu_music():
	play_music(finish_menu_music)

func play_attack_fist_sfx(volume_db: float = 0.0):
	play_sfx(attack_fist_sfx, volume_db)

func play_bomb_explosion_sfx(volume_db: float = 0.0):
	play_sfx(bomb_explosion_sfx, volume_db)

func play_bomb_ignition_sfx(volume_db: float = 0.0):
	play_sfx(bomb_ignition_sfx, volume_db)

func play_boss_hurt_sfx(volume_db: float = 0.0):
	play_sfx(boss_hurt_sfx, volume_db)

func play_boss_roar_sfx(volume_db: float = 0.0):
	play_sfx(boss_roar_sfx, volume_db)

func play_boss_spawn_minions_sfx(volume_db: float = 0.0):
	play_sfx(boss_spawn_minions_sfx, volume_db)

func play_button_sfx(volume_db: float = 0.0):
	play_sfx(button_sfx, volume_db)

func play_door_sfx(volume_db: float = 10.0):
	play_sfx(door_sfx, volume_db)

func play_electric_ray_sfx(volume_db: float = 0.0):
	play_sfx(electric_ray_sfx, volume_db)

func play_fan_sfx(volume_db: float = 0.0):
	play_sfx(fan_sfx, volume_db)

func play_gun_ray_beam_sfx(volume_db: float = 0.0):
	play_sfx(gun_ray_beam_sfx, volume_db)

func play_health_pickup_regen_sfx(volume_db: float = 0.0):
	play_sfx(health_pickup_regen_sfx, volume_db)

func play_item_pickup_sfx(volume_db: float = -10.0):
	play_sfx(item_pickup_sfx, volume_db)

func play_jump_sfx(volume_db: float = 15.0):
	play_sfx(jump_sfx, volume_db)

func play_key_in_lock_sfx(volume_db: float = 0.0):
	play_sfx(key_in_lock_sfx, volume_db)

func play_laser_hit_player_sfx(volume_db: float = 0.0):
	play_sfx(laser_hit_player_sfx, volume_db)

func play_player_death(volume_db : float = 0.0):
	play_sfx(player_death_sfx, volume_db)

func play_potion_open_sfx(volume_db: float = 0.0):
	play_sfx(potion_open_sfx, volume_db)

func play_potion_pickup_sfx(volume_db: float = 0.0):
	play_sfx(potion_pickup_sfx, volume_db)

func play_pressure_plate_sfx(volume_db: float = 0.0):
	play_sfx(pressure_plate_sfx, volume_db)

func play_rizz_sfx(volume_db: float = 0.0):
	play_sfx(rizz_sfx, volume_db)

func play_teleportation_sfx(volume_db : float = 0.0):
	play_sfx(teleportation_sfx, volume_db)

func play_ui_press_sfx(volume_db: float = 0.0):
	play_sfx(ui_press_sfx, volume_db)

func play_walking_sfx(volume_db: float = 0.0):
	play_sfx(walking_sfx, volume_db)

#func stop_walking_sfx():
	#stop_sfx(walking_sfx)

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

func change_audio_bus_sfx_controller(bus_name : String, sfx_controller):
	sfx_controller.bus = bus_name
