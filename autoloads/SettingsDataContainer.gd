extends Node


@onready var DEFAULT_SETTINGS : DefaultSettingsResource = preload("res://resources/settings/DefaultSettings.tres")
@onready var keybind_resource: PlayerKeybindResource = preload("res://resources/settings/PlayerKeybindDefault.tres")

var window_mode_index : int = 0 
var resolution_mode_index : int = 0
var master_volume : float = 0.0
var music_volume : float = 0.0
var sfx_volume : float = 0.0
var fps_state : bool = true
var loaded_data : Dictionary = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	handle_signals()
	make_storage_dict()


func make_storage_dict():
	var settings_container_dict : Dictionary = {
		"window_mode_index": window_mode_index,
		"resolution_mode_index": resolution_mode_index,
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"fps_state": fps_state,
		"keybinds": make_keybinds_dict()
	}

	return settings_container_dict


func make_keybinds_dict():
	var keybinds_container_dict = {
		keybind_resource.MOVE_LEFT: keybind_resource.move_left_key,
		keybind_resource.MOVE_RIGHT: keybind_resource.move_right_key,
		keybind_resource.MOVE_FORWARD: keybind_resource.move_forward_key,
		keybind_resource.MOVE_BACK: keybind_resource.move_back_key,
		keybind_resource.JUMP: keybind_resource.jump_key,
		keybind_resource.INTERACT: keybind_resource.interact_key,
		keybind_resource.ATTACK: keybind_resource.attack_key,
		keybind_resource.OPEN_CHAT: keybind_resource.open_chat_key,
		keybind_resource.USE_ITEM: keybind_resource.use_item_key,
		keybind_resource.PULL: keybind_resource.pull_key
	}

	return keybinds_container_dict


func get_first():
	if loaded_data == {}:
		return true
	return false


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


func get_keybind(action : String):
	if not loaded_data.has("keybinds"):
		match action:
			keybind_resource.MOVE_LEFT:
				return keybind_resource.DEFAULT_MOVE_LEFT_KEY
			keybind_resource.MOVE_RIGHT:
				return keybind_resource.DEFAULT_MOVE_RIGHT_KEY
			keybind_resource.MOVE_FORWARD:
				return keybind_resource.DEFAULT_MOVE_FORWARD_KEY
			keybind_resource.MOVE_BACK:
				return keybind_resource.DEFAULT_MOVE_BACK_KEY
			keybind_resource.JUMP:
				return keybind_resource.DEFAULT_JUMP_KEY
			keybind_resource.INTERACT:
				return keybind_resource.DEFAULT_INTERACT_KEY
			keybind_resource.ATTACK: 
				return keybind_resource.DEFAULT_ATTACK_KEY
			keybind_resource.OPEN_CHAT:
				return keybind_resource.DEFAULT_OPEN_CHAT_KEY
			keybind_resource.USE_ITEM:
				return keybind_resource.DEFAULT_USE_ITEM_KEY
			keybind_resource.PULL:
				return keybind_resource.DEFAULT_PULL_KEY
	else:
		match action:
			keybind_resource.MOVE_LEFT:
				return keybind_resource.move_left_key
			keybind_resource.MOVE_RIGHT:
				return keybind_resource.move_right_key
			keybind_resource.MOVE_FORWARD:
				return keybind_resource.move_forward_key
			keybind_resource.MOVE_BACK:
				return keybind_resource.move_back_key
			keybind_resource.JUMP:
				return keybind_resource.jump_key
			keybind_resource.INTERACT:
				return keybind_resource.interact_key
			keybind_resource.ATTACK: 
				return keybind_resource.attack_key
			keybind_resource.OPEN_CHAT:
				return keybind_resource.open_chat_key
			keybind_resource.USE_ITEM:
				return keybind_resource.use_item_key
			keybind_resource.PULL:
				return keybind_resource.pull_key


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


func set_keybind(action : String, event):
	match action:
		keybind_resource.MOVE_LEFT:
			keybind_resource.move_left_key = event
		keybind_resource.MOVE_RIGHT:
			keybind_resource.move_right_key = event
		keybind_resource.MOVE_FORWARD:
			keybind_resource.move_forward_key = event
		keybind_resource.MOVE_BACK:
			keybind_resource.move_back_key = event
		keybind_resource.JUMP:
			keybind_resource.jump_key = event
		keybind_resource.INTERACT:
			keybind_resource.interact_key = event
		keybind_resource.ATTACK:
			keybind_resource.attack_key = event
		keybind_resource.OPEN_CHAT:
			keybind_resource.open_chat_key = event
		keybind_resource.USE_ITEM:
			keybind_resource.use_item_key = event
		keybind_resource.PULL:
			keybind_resource.pull_key = event
		


func on_keybinds_loaded(data : Dictionary):
	var loaded_move_left = InputEventKey.new()
	var loaded_move_right = InputEventKey.new()
	var loaded_move_forward = InputEventKey.new()
	var loaded_move_back = InputEventKey.new()
	var loaded_jump = InputEventKey.new()
	var loaded_interact = InputEventKey.new()
	var loaded_attack = InputEventKey.new()
	var loaded_open_chat = InputEventKey.new()
	var loaded_use_item = InputEventKey.new()
	var loaded_pull = InputEventKey.new()

	loaded_move_left.set_physical_keycode(int(data.move_left))
	loaded_move_right.set_physical_keycode(int(data.move_right))
	loaded_move_forward.set_physical_keycode(int(data.move_forward))
	loaded_move_back.set_physical_keycode(int(data.move_back))
	loaded_jump.set_physical_keycode(int(data.jump))
	loaded_interact.set_physical_keycode(int(data.interact))
	loaded_attack.set_physical_keycode(int(data.attack))
	loaded_open_chat.set_physical_keycode(int(data.open_chat))
	loaded_use_item.set_physical_keycode(int(data.use_item))
	loaded_pull.set_physical_keycode(int(data.pull))
	
	keybind_resource.move_left_key = loaded_move_left
	keybind_resource.move_right_key = loaded_move_right
	keybind_resource.move_forward_key = loaded_move_forward
	keybind_resource.move_back_key = loaded_move_back
	keybind_resource.jump_key = loaded_jump
	keybind_resource.interact_key = loaded_interact
	keybind_resource.attack_key = loaded_attack
	keybind_resource.open_chat_key = loaded_open_chat
	keybind_resource.use_item_key = loaded_use_item
	keybind_resource.pull_key = loaded_pull
	


func on_settings_data_loaded(data : Dictionary):
	loaded_data = data
	on_window_mode_selected(loaded_data.window_mode_index)
	on_resolution_mode_selected(loaded_data.resolution_mode_index)
	on_master_sound_set(loaded_data.master_volume)
	on_music_sound_set(loaded_data.music_volume)
	on_sfx_sound_set(loaded_data.sfx_volume)
	on_fps_toggled(loaded_data.fps_state)
	on_keybinds_loaded(loaded_data.keybinds)


func handle_signals():
	SettingsSignalBus.on_window_mode_selected.connect(on_window_mode_selected)
	SettingsSignalBus.on_resolution_mode_selected.connect(on_resolution_mode_selected)
	SettingsSignalBus.on_master_sound_set.connect(on_master_sound_set)
	SettingsSignalBus.on_music_sound_set.connect(on_music_sound_set)
	SettingsSignalBus.on_sfx_sound_set.connect(on_sfx_sound_set)
	SettingsSignalBus.on_fps_toggled.connect(on_fps_toggled)
	SettingsSignalBus.load_settings_data.connect(on_settings_data_loaded)
