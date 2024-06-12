extends Node


@onready var DEFAULT_SETTINGS : DefaultSettingsResource = preload("res://resources/settings/DefaultSettings.tres")

var window_mode_index : int = 0 
var resolution_mode_index : int = 0
var master_volume : float = 0.0
var music_volume : float = 0.0
var sfx_volume : float = 0.0
var fps_state : bool = false
var loaded_data : Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	handle_signals()
	make_storage_dict()
	#SettingsSignalBus.on_fps_toggled.connect(on_fps_toggled)


func make_storage_dict():
	var settings_container_dict : Dictionary = {
		"window_mode_index": window_mode_index,
		"resolution_mode_index": resolution_mode_index,
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"fps_state": fps_state,
		"move_left": InputMap.action_get_events("move_left"),
		"move_right": InputMap.action_get_events("move_right"),
		"move_back": InputMap.action_get_events("move_back"),
		"move_forward": InputMap.action_get_events("move_forward"),
		"jump": InputMap.action_get_events("jump"),
		"interact": InputMap.action_get_events("interact")
	}
	
	return settings_container_dict


func get_window_mode_index():
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_WINDOW_MODE_INDEX
	return window_mode_index


func get_resolution_mode_index():
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_RESOLUTION_MODE_INDEX
	return resolution_mode_index


func get_master_volume():
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_MASTER_VOLUME
	return master_volume


func get_music_volume():
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_MUSIC_VOLUME
	return music_volume


func get_sfx_volume():
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_SFX_VOLUME
	return sfx_volume


func get_fps_meter():
	if loaded_data == {}:
		return DEFAULT_SETTINGS.DEFAULT_FPS_METER
	return fps_state


func on_window_mode_selected(index : int):
	window_mode_index = index


func on_resolution_mode_selected(index : int):
	resolution_mode_index = index


func on_master_sound_set(value: float):
	master_volume = value


func on_music_sound_set(value: float):
	music_volume = value


func on_sfx_sound_set(value: float):
	sfx_volume = value


func on_fps_toggled(value : bool):
	fps_state = value
	#print(fps_state)


func on_settings_data_loaded(data : Dictionary):
	loaded_data = data
	print(loaded_data)
	on_window_mode_selected(loaded_data.window_mode_index)
	on_resolution_mode_selected(loaded_data.resolution_mode_index)
	on_master_sound_set(loaded_data.master_volume)
	on_music_sound_set(loaded_data.music_volume)
	on_sfx_sound_set(loaded_data.sfx_volume)
	on_fps_toggled(loaded_data.fps_state)


func handle_signals():
	SettingsSignalBus.on_window_mode_selected.connect(on_window_mode_selected)
	SettingsSignalBus.on_resolution_mode_selected.connect(on_resolution_mode_selected)
	SettingsSignalBus.on_master_sound_set.connect(on_master_sound_set)
	SettingsSignalBus.on_music_sound_set.connect(on_music_sound_set)
	SettingsSignalBus.on_sfx_sound_set.connect(on_sfx_sound_set)
	SettingsSignalBus.on_fps_toggled.connect(on_fps_toggled)
	SettingsSignalBus.load_settings_data.connect(on_settings_data_loaded)
