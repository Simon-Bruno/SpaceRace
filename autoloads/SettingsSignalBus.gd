extends Node

signal on_fps_toggled(value : bool)
signal on_window_mode_selected(index : int)
signal on_resolution_mode_selected(index : int)
signal on_master_sound_set(value : float)
signal on_music_sound_set(value : float)
signal on_sfx_sound_set(value : float)
signal settings_dictionary(settings_dict : Dictionary)
signal load_settings_data(settings_dict : Dictionary)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func emit_load_settings_data(settings_dict : Dictionary):
	load_settings_data.emit(settings_dict)


func emit_on_fps_toggled(value : bool):
	on_fps_toggled.emit(value)


func emit_on_window_mode_selected(index : int):
	on_window_mode_selected.emit(index)


func emit_on_resolution_mode_selected(index : int):
	on_resolution_mode_selected.emit(index)


func emit_on_master_sound_set(value : float):
	on_master_sound_set.emit(value) 


func emit_on_music_sound_set(value : float):
	on_music_sound_set.emit(value) 


func emit_on_sfx_sound_set(value : float):
	on_sfx_sound_set.emit(value) 


func emit_settings_dictionary(settings_dict : Dictionary):
	settings_dictionary.emit(settings_dict)
