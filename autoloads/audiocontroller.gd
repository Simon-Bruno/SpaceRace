extends Node

# Paths
const MUSIC_CONTROLLER_PATH = "/root/Main/MusicController"
const MASTER_SLIDER_PATH = "/root/Main/SpawnedItems/World/PauseMenu/Settings/MarginContainer/VBoxContainer/Settings_Tab_Container/TabContainer/Audio/MarginContainer/ScrollContainer/VBoxContainer/Audio_Slider_Settings/HBoxContainer/HSlider"
const MUSIC_SLIDER_PATH = "/root/Main/SpawnedItems/World/PauseMenu/Settings/MarginContainer/VBoxContainer/Settings_Tab_Container/TabContainer/Audio/MarginContainer/ScrollContainer/VBoxContainer/Audio_Slider_Settings2/HBoxContainer/HSlider"
const SFX_SLIDER_PATH = "/root/Main/SpawnedItems/World/PauseMenu/Settings/MarginContainer/VBoxContainer/Settings_Tab_Container/TabContainer/Audio/MarginContainer/ScrollContainer/VBoxContainer/Audio_Slider_Settings3/HBoxContainer/HSlider"

# Music
const FINISH_MENU_AUDIO = preload("res://assets/audio/music/finish_menu_audio.ogg")
const GALACTIC_BATTLE__IN_GAME_ = preload("res://assets/audio/music/Galactic Battle (In Game).ogg")
const GALACTIC_GROOVE__MENU_ = preload("res://assets/audio/music/Galactic Groove (Menu).ogg")
const GALACTIC_SHOWDOWN__LOBBY_ = preload("res://assets/audio/music/Galactic Showdown (Lobby).ogg")

# Sound effects
var ABILITY_UP_1 = load("res://assets/audio/sfx/ability_up1.ogg")
var ABILITY_UP_2 = load("res://assets/audio/sfx/ability_up2.ogg")
var AIR_PUNCH = load("res://assets/audio/sfx/air_punch.ogg")
var ATTACK_FIST = load("res://assets/audio/sfx/attack_fist.ogg")
var A_BOX_BEING_PUSHED_A__1_ = load("res://assets/audio/sfx/a_box_being_pushed_a (1).ogg")
var A_BOX_BEING_PUSHED_A = load("res://assets/audio/sfx/a_box_being_pushed_a.ogg")
var BOMB_EXPLOSION = load("res://assets/audio/sfx/bomb_explosion.ogg")
var BOMB_IGNITION = load("res://assets/audio/sfx/bomb_ignition.ogg")
var BOSS_HURT = load("res://assets/audio/sfx/boss_hurt.ogg")
var BOSS_ROAR = load("res://assets/audio/sfx/boss_roar.ogg")
var BOSS_SPAWN_MINIONS = load("res://assets/audio/sfx/boss_spawn_minions.ogg")
var BUTTON = load("res://assets/audio/sfx/button.ogg")
var CHASE_MUSIC = load("res://assets/audio/sfx/chase_music.ogg")
var COUNTDOWN_1 = load("res://assets/audio/sfx/countdown1.ogg")
var DEFEAT_1 = load("res://assets/audio/sfx/defeat1.ogg")
var DEFEAT_2 = load("res://assets/audio/sfx/defeat2.ogg")
var DOOR = load("res://assets/audio/sfx/door.ogg")
var ELECTRIC_RAY = load("res://assets/audio/sfx/electric_ray.ogg")
var ENEMY_TEAM_DEATH = load("res://assets/audio/sfx/enemy_team_death.ogg")
var FAN = load("res://assets/audio/sfx/fan.ogg")
var GUN_RAY_BEAM = load("res://assets/audio/sfx/gun_ray_beam.ogg")
var HEALTH_FULL = load("res://assets/audio/sfx/health_full.ogg")
var HEALTH_PICKUP_REGEN = load("res://assets/audio/sfx/health_pickup_regen.ogg")
var IDLE_SPACESTATION_SO = load("res://assets/audio/sfx/idle_spacestation_so.ogg")
var ITEM_PICKUP = load("res://assets/audio/sfx/item_pickup.ogg")
var JUMP_ = load("res://assets/audio/sfx/jump_.ogg")
var KEY_IN_LOCK = load("res://assets/audio/sfx/key_in_lock.ogg")
var LASER_HIT_PLAYER = load("res://assets/audio/sfx/laser_hit_player.ogg")
var MOVING_WOOD = load("res://assets/audio/sfx/moving_wood.ogg")
var PICK_TEAM = load("res://assets/audio/sfx/pick_team.ogg")
var PLAYER_DEATH = load("res://assets/audio/sfx/player_death.ogg")
var PLAYER_RESPAWN = load("res://assets/audio/sfx/player_respawn.ogg")
var PLAYER_WALK_1 = load("res://assets/audio/sfx/player_walk1.ogg")
var PLAYER_WALK_2 = load("res://assets/audio/sfx/player_walk2.ogg")
var POTION_OPEN = load("res://assets/audio/sfx/potion_open.ogg")
var POTION_PICKUP = load("res://assets/audio/sfx/potion_pickup.ogg")
var PRESSURE_PLATE_FIXED = load("res://assets/audio/sfx/pressure_plate_fixed.ogg")
var REGEN_OVER = load("res://assets/audio/sfx/regen_over.ogg")
var RIZZ = load("res://assets/audio/sfx/rizz.ogg")
var SABOTAGED = load("res://assets/audio/sfx/sabotaged.ogg")
var SABOTAGING = load("res://assets/audio/sfx/sabotaging.ogg")
var TEAMMATE_DEATH = load("res://assets/audio/sfx/teammate_death.ogg")
var TELEPORTATION = load("res://assets/audio/sfx/teleportation.ogg")
var TERMINAL = load("res://assets/audio/sfx/terminal.ogg")
var UI_PRESS = load("res://assets/audio/sfx/ui_press.ogg")
var UNPICK_TEAM_FIXED = load("res://assets/audio/sfx/unpick_team_fixed.ogg")
var VICTORY = load("res://assets/audio/sfx/victory2.ogg")
var WALKING = load("res://assets/audio/sfx/walking.ogg")
var ZOMBIE_CHASING = load("res://assets/audio/sfx/zombie_chasing.ogg")
var ZOMBIE_DEATH = load("res://assets/audio/sfx/zombie_death.ogg")
var ZOMBIE_GETS_HIT_1 = load("res://assets/audio/sfx/zombie_gets_hit1.ogg")
var ZOMBIE_GETS_HIT_2 = load("res://assets/audio/sfx/zombie_gets_hit2.ogg")
var ZOMBIE_SPAWN = load("res://assets/audio/sfx/zombie_spawn.ogg")
var ZOMBIE_STOPS_CHASING = load("res://assets/audio/sfx/zombie_stops_chasing.ogg")
var ZOMBIE_WALK = load("res://assets/audio/sfx/zombie_walk.ogg")

# To keep track of h_slider values after being muted
var cur_hslider_val_master: float
var cur_hslider_val_music: float
var cur_hslider_val_sfx: float

func _ready():
	play_menu_music()

func play_music(music, volume_db : float = 0.0):
	var music_controller = get_node(MUSIC_CONTROLLER_PATH)
	music_controller.stream = music
	music_controller.volume_db = volume_db
	change_audio_bus_music_controller("Music")
	music_controller.play()

func play_Sfx(sfx, volume_db : float = 0):
	var sfx_controller = AudioStreamPlayer.new()
	sfx_controller.stream = sfx
	sfx_controller.volume_db = volume_db
	change_audio_bus_sfx_controller("Sfx", sfx_controller)
	add_child(sfx_controller)
	sfx_controller.play()
	await sfx_controller.finished
	sfx_controller.queue_free()

func play_menu_music(volume_db : float = 0.0):
	play_music(GALACTIC_GROOVE__MENU_, volume_db)

func play_lobby_music(volume_db : float = 0.0):
	play_music(GALACTIC_SHOWDOWN__LOBBY_, volume_db)

func play_game_music(volume_db : float = 0.0):
	play_music(GALACTIC_BATTLE__IN_GAME_, volume_db)

func play_finish_menu_music(volume_db : float = 15.0):
	play_music(FINISH_MENU_AUDIO, volume_db)

func play_ability_1_sfx(volume_db : float = 0.0):
	play_Sfx(ABILITY_UP_1, volume_db)

func play_ability_2_sfx(volume_db : float = 0.0):
	play_Sfx(ABILITY_UP_2, volume_db)

func play_air_punch_sfx(volume_db : float = 0.0):
	play_Sfx(AIR_PUNCH, volume_db)

func play_attack_fist_sfx(volume_db: float = 0.0):
	play_Sfx(ATTACK_FIST, volume_db)

func play_a_box_being_pushed_1_sfx(volume_db: float = 0.0):
	play_Sfx(A_BOX_BEING_PUSHED_A, volume_db)

func play_a_box_being_pushed_sfx(volume_db : float = 0.0):
	play_Sfx(A_BOX_BEING_PUSHED_A, volume_db)

func play_bomb_explosion_sfx(volume_db: float = 0.0):
	play_Sfx(BOMB_EXPLOSION, volume_db)

func play_bomb_ignition_sfx(volume_db: float = 0.0):
	play_Sfx(BOMB_IGNITION, volume_db)

func play_boss_hurt_sfx(volume_db: float = 0.0):
	play_Sfx(BOSS_HURT, volume_db)

func play_boss_roar_sfx(volume_db: float = -5.0):
	play_Sfx(BOSS_ROAR, volume_db)

func play_boss_spawn_minions_sfx(volume_db: float = -10.0):
	play_Sfx(BOSS_SPAWN_MINIONS, volume_db)

func play_button_sfx(volume_db: float = 0.0):
	play_Sfx(BUTTON, volume_db)

func play_chase_sfx(volume_db: float = 0.0):
	play_Sfx(CHASE_MUSIC, volume_db)

func play_countdown_sfx(volume_db: float = -15.0):
	play_Sfx(COUNTDOWN_1, volume_db)

func play_defeat_1_sfx(volume_db: float = 0.0):
	play_Sfx(DEFEAT_1, volume_db)

func play_defeat_2_sfx(volume_db: float = 0.0):
	play_Sfx(DEFEAT_2, volume_db)

func play_door_sfx(volume_db: float = 10.0):
	play_Sfx(DOOR, volume_db)

func play_electric_ray_sfx(volume_db: float = 0.0):
	play_Sfx(ELECTRIC_RAY, volume_db)

func play_enemy_team_death_sfx(volume_db: float = 0.0):
	play_Sfx(ENEMY_TEAM_DEATH, volume_db)

func play_fan_sfx(volume_db: float = 0.0):
	play_Sfx(FAN, volume_db)

func play_gun_ray_beam_sfx(volume_db: float = 0.0):
	play_Sfx(GUN_RAY_BEAM, volume_db)

func play_health_full_sfx(volume_db: float = 0.0):
	play_Sfx(HEALTH_FULL, volume_db)

func play_health_pickup_regen_sfx(volume_db: float = 0.0):
	play_Sfx(HEALTH_PICKUP_REGEN, volume_db)

func play_idle_spacestation_sfx(volume_db: float = 0.0):
	play_Sfx(IDLE_SPACESTATION_SO, volume_db)

func play_item_pickup_sfx(volume_db: float = -10.0):
	play_Sfx(ITEM_PICKUP, volume_db)

func play_jump_sfx(volume_db: float = 15.0):
	play_Sfx(JUMP_, volume_db)

func play_key_in_lock_sfx(volume_db: float = 0.0):
	play_Sfx(KEY_IN_LOCK, volume_db)

func play_laser_hit_player_sfx(volume_db: float = 0.0):
	play_Sfx(LASER_HIT_PLAYER, volume_db)

func play_moving_wood_sfx(volume_db: float = 0.0):
	play_Sfx(MOVING_WOOD, volume_db)

func play_pick_team_sfx(volume_db: float = 0.0):
	play_Sfx(PICK_TEAM, volume_db)

func play_player_death_sfx(volume_db : float = 0.0):
	play_Sfx(PLAYER_DEATH, volume_db)

func play_player_respawn_sfx(volume_db: float = 0.0):
	play_Sfx(PLAYER_RESPAWN, volume_db)

func play_player_walk_1_sfx(volume_db: float = 0.0):
	play_Sfx(PLAYER_WALK_1, volume_db)

func play_player_walk_2_sfx(volume_db: float = 0.0):
	play_Sfx(PLAYER_WALK_2, volume_db)

func play_potion_open_sfx(volume_db: float = 0.0):
	play_Sfx(POTION_OPEN, volume_db)

func play_potion_pickup_sfx(volume_db: float = 0.0):
	play_Sfx(POTION_PICKUP, volume_db)

func play_pressure_plate_sfx(volume_db: float = 0.0):
	play_Sfx(PRESSURE_PLATE_FIXED, volume_db)

func play_regen_over_sfx(volume_db: float = 0.0):
	play_Sfx(REGEN_OVER, volume_db)

func play_rizz_sfx(volume_db: float = 0.0):
	play_Sfx(RIZZ, volume_db)

func play_sabotaged_sfx(volume_db: float = 0.0):
	play_Sfx(SABOTAGED, volume_db)

func play_sabotaging_sfx(volume_db: float = 0.0):
	play_Sfx(SABOTAGING, volume_db)

func play_teammate_death_sfx(volume_db: float = 0.0):
	play_Sfx(TEAMMATE_DEATH, volume_db)

func play_teleportation_sfx(volume_db : float = 0.0):
	play_Sfx(TELEPORTATION, volume_db)

func play_terminal_sfx(volume_db : float = 0.0):
	play_Sfx(TERMINAL, volume_db)

func play_ui_press_sfx(volume_db: float = 0.0):
	play_Sfx(UI_PRESS, volume_db)

func play_unpick_team_sfx(volume_db: float = 0.0):
	play_Sfx(UNPICK_TEAM_FIXED, volume_db)

func play_victory_sfx(volume_db: float = -5.0):
	play_Sfx(VICTORY, volume_db)

func play_walking_sfx(volume_db: float = 0.0):
	play_Sfx(WALKING, volume_db)

func play_zombie_chasing_sfx(volume_db: float = 0.0):
	play_Sfx(ZOMBIE_CHASING, volume_db)

func play_zombie_death_sfx(volume_db: float = 0.0):
	play_Sfx(ZOMBIE_DEATH, volume_db)

func play_zombie_gets_hit_1_sfx(volume_db: float = 0.0):
	play_Sfx(ZOMBIE_GETS_HIT_1, volume_db)

func play_zombie_gets_hit_2_sfx(volume_db: float = 0.0):
	play_Sfx(ZOMBIE_GETS_HIT_2, volume_db)

func play_zombie_spawn_sfx(volume_db: float = 0.0):
	play_Sfx(ZOMBIE_SPAWN, volume_db)

func play_zombie_stops_chasing_sfx(volume_db: float = 0.0):
	play_Sfx(ZOMBIE_STOPS_CHASING, volume_db)

func play_zombie_walk_sfx(volume_db: float = 0.0):
	play_Sfx(ZOMBIE_WALK, volume_db)

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
