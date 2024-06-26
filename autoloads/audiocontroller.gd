extends Node

# Paths
const MUSIC_CONTROLLER_PATH = "/root/Main/MusicController"
const MASTER_SLIDER_PATH = "/root/Main/SpawnedItems/World/PauseMenu/Settings/MarginContainer/VBoxContainer/Settings_Tab_Container/TabContainer/Audio/MarginContainer/ScrollContainer/VBoxContainer/Audio_Slider_Settings/HBoxContainer/HSlider"
const MUSIC_SLIDER_PATH = "/root/Main/SpawnedItems/World/PauseMenu/Settings/MarginContainer/VBoxContainer/Settings_Tab_Container/TabContainer/Audio/MarginContainer/ScrollContainer/VBoxContainer/Audio_Slider_Settings2/HBoxContainer/HSlider"
const SFX_SLIDER_PATH = "/root/Main/SpawnedItems/World/PauseMenu/Settings/MarginContainer/VBoxContainer/Settings_Tab_Container/TabContainer/Audio/MarginContainer/ScrollContainer/VBoxContainer/Audio_Slider_Settings3/HBoxContainer/HSlider"

# Music
#var menu_music = preload("res://assets/audio/music/Galactic Groove (Menu).ogg")
#var lobby_music = preload("res://assets/audio/music/Galactic Showdown (Lobby).ogg")
#var game_music = preload("res://assets/audio/music/Galactic Battle (In Game).ogg")
#var finish_menu_music = preload("res://assets/audio/music/finish_menu_audio.ogg")
const FINISH_MENU_AUDIO = preload("res://assets/audio/music/finish_menu_audio.ogg")
const GALACTIC_BATTLE__IN_GAME_ = preload("res://assets/audio/music/Galactic Battle (In Game).ogg")
const GALACTIC_GROOVE__MENU_ = preload("res://assets/audio/music/Galactic Groove (Menu).ogg")
const GALACTIC_SHOWDOWN__LOBBY_ = preload("res://assets/audio/music/Galactic Showdown (Lobby).ogg")
# Sound effects
const ABILITY_UP_1 = preload("res://assets/audio/sfx/ability_up1.ogg")
const ABILITY_UP_2 = preload("res://assets/audio/sfx/ability_up2.ogg")
const ATTACK_FIST = preload("res://assets/audio/sfx/attack_fist.ogg")
const A_BOX_BEING_PUSHED_A__1_ = preload("res://assets/audio/sfx/a_box_being_pushed_a (1).ogg")
const A_BOX_BEING_PUSHED_A = preload("res://assets/audio/sfx/a_box_being_pushed_a.ogg")
const BOMB_EXPLOSION = preload("res://assets/audio/sfx/bomb_explosion.ogg")
const BOMB_IGNITION = preload("res://assets/audio/sfx/bomb_ignition.ogg")
const BOSS_HURT = preload("res://assets/audio/sfx/boss_hurt.ogg")
const BOSS_ROAR = preload("res://assets/audio/sfx/boss_roar.ogg")
const BOSS_SPAWN_MINIONS = preload("res://assets/audio/sfx/boss_spawn_minions.ogg")
const BUTTON = preload("res://assets/audio/sfx/button.ogg")
const CHASE_MUSIC = preload("res://assets/audio/sfx/chase_music.ogg")
const COUNTDOWN_1 = preload("res://assets/audio/sfx/countdown1.ogg")
const COUNTDOWN_2 = preload("res://assets/audio/sfx/countdown2.ogg")
const DOOR = preload("res://assets/audio/sfx/door.ogg")
const ELECTRIC_RAY = preload("res://assets/audio/sfx/electric_ray.ogg")
const ENEMY_TEAM_DEATH = preload("res://assets/audio/sfx/enemy_team_death.ogg")
const FAN = preload("res://assets/audio/sfx/fan.ogg")
const GUN_RAY_BEAM = preload("res://assets/audio/sfx/gun_ray_beam.ogg")
const HEALTH_FULL = preload("res://assets/audio/sfx/health_full.ogg")
const HEALTH_PICKUP_REGEN = preload("res://assets/audio/sfx/health_pickup_regen.ogg")
const ITEM_PICKUP = preload("res://assets/audio/sfx/item_pickup.ogg")
const JUMP_ = preload("res://assets/audio/sfx/jump_.ogg")
const KEY_IN_LOCK = preload("res://assets/audio/sfx/key_in_lock.ogg")
const LASER_HIT_PLAYER = preload("res://assets/audio/sfx/laser_hit_player.ogg")
const LEVER = preload("res://assets/audio/sfx/lever.ogg")
const MOVING_WOOD = preload("res://assets/audio/sfx/moving_wood.ogg")
const PICK_TEAM = preload("res://assets/audio/sfx/pick_team.ogg")
const PLAYER_DEATH = preload("res://assets/audio/sfx/player_death.ogg")
const POTION_OPEN = preload("res://assets/audio/sfx/potion_open.ogg")
const POTION_PICKUP = preload("res://assets/audio/sfx/potion_pickup.ogg")
const PRESSURE_PLATE = preload("res://assets/audio/sfx/pressure_plate.ogg")
const PRESSURE_PLATE_FIXED = preload("res://assets/audio/sfx/pressure_plate_fixed.ogg")
const REGEN_OVER = preload("res://assets/audio/sfx/regen_over.ogg")
const RIZZ = preload("res://assets/audio/sfx/rizz.ogg")
const START_1 = preload("res://assets/audio/sfx/start1.ogg")
const START_2 = preload("res://assets/audio/sfx/start2.ogg")
const TELEPORTATION = preload("res://assets/audio/sfx/teleportation.ogg")
const TERMINAL = preload("res://assets/audio/sfx/terminal.ogg")
const UI_PRESS = preload("res://assets/audio/sfx/ui_press.ogg")
const UNPICK_TEAM = preload("res://assets/audio/sfx/unpick_team.ogg")
const WALKING = preload("res://assets/audio/sfx/walking.ogg")
const ZOMBIE_CHASING = preload("res://assets/audio/sfx/zombie_chasing.ogg")
const ZOMBIE_SPAWN = preload("res://assets/audio/sfx/zombie_spawn.ogg")
const ZOMBIE_STOPS_CHASING = preload("res://assets/audio/sfx/zombie_stops_chasing.ogg")

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
	play_music(GALACTIC_GROOVE__MENU_)

func play_lobby_music():
	play_music(GALACTIC_SHOWDOWN__LOBBY_)

func play_game_music():
	play_music(GALACTIC_BATTLE__IN_GAME_)

func play_finish_menu_music():
	play_music(FINISH_MENU_AUDIO)

func play_ability_1_sfx(volume_db : float = 0.0):
	play_sfx(ABILITY_UP_1, volume_db)

func play_ability_2_sfx(volume_db : float = 0.0):
	play_sfx(ABILITY_UP_2, volume_db)

func play_attack_fist_sfx(volume_db: float = 0.0):
	play_sfx(ATTACK_FIST, volume_db)

func play_bomb_explosion_sfx(volume_db: float = 0.0):
	play_sfx(BOMB_EXPLOSION, volume_db)

func play_bomb_ignition_sfx(volume_db: float = 0.0):
	play_sfx(BOMB_IGNITION, volume_db)

func play_boss_hurt_sfx(volume_db: float = 0.0):
	play_sfx(BOSS_HURT, volume_db)

func play_boss_roar_sfx(volume_db: float = 0.0):
	play_sfx(BOSS_ROAR, volume_db)

func play_boss_spawn_minions_sfx(volume_db: float = 0.0):
	play_sfx(BOSS_SPAWN_MINIONS, volume_db)

func play_button_sfx(volume_db: float = 0.0):
	play_sfx(BUTTON, volume_db)

func play_door_sfx(volume_db: float = 10.0):
	play_sfx(DOOR, volume_db)

func play_electric_ray_sfx(volume_db: float = 0.0):
	play_sfx(ELECTRIC_RAY, volume_db)

func play_fan_sfx(volume_db: float = 0.0):
	play_sfx(FAN, volume_db)

func play_gun_ray_beam_sfx(volume_db: float = 0.0):
	play_sfx(GUN_RAY_BEAM, volume_db)

func play_health_pickup_regen_sfx(volume_db: float = 0.0):
	play_sfx(HEALTH_PICKUP_REGEN, volume_db)

func play_item_pickup_sfx(volume_db: float = -10.0):
	play_sfx(ITEM_PICKUP, volume_db)

func play_jump_sfx(volume_db: float = 15.0):
	play_sfx(JUMP_, volume_db)

func play_key_in_lock_sfx(volume_db: float = 0.0):
	play_sfx(KEY_IN_LOCK, volume_db)

func play_laser_hit_player_sfx(volume_db: float = 0.0):
	play_sfx(LASER_HIT_PLAYER, volume_db)

func play_player_death(volume_db : float = 0.0):
	play_sfx(PLAYER_DEATH, volume_db)

func play_potion_open_sfx(volume_db: float = 0.0):
	play_sfx(POTION_OPEN, volume_db)

func play_potion_pickup_sfx(volume_db: float = 0.0):
	play_sfx(POTION_PICKUP, volume_db)

func play_pressure_plate_sfx(volume_db: float = 0.0):
	play_sfx(PRESSURE_PLATE, volume_db)

func play_rizz_sfx(volume_db: float = 0.0):
	play_sfx(RIZZ, volume_db)

func play_teleportation_sfx(volume_db : float = 0.0):
	play_sfx(TELEPORTATION, volume_db)

func play_ui_press_sfx(volume_db: float = 0.0):
	play_sfx(UI_PRESS, volume_db)

func play_walking_sfx(volume_db: float = 0.0):
	play_sfx(WALKING, volume_db)

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
