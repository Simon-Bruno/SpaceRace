extends Control


@onready var option_button = $HBoxContainer/OptionButton as OptionButton


const WINDOW_MODE_ARRAY : Array[String] = [
	"Fullscreen",
	"Window Mode",
	"Borderless Window",
	"Borderless Fullscreen"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	add_window_mode_items()
	if FileAccess.file_exists(SaveManager.SETTINGS_SAVE_PATH) and not SettingsContainer.get_first():
		load_data()
	else:
		select_current_window_mode()


func load_data():
	_on_option_button_item_selected(SettingsContainer.get_window_mode_index())
	option_button.select(SettingsContainer.get_window_mode_index())


func add_window_mode_items():
	for window_mode in WINDOW_MODE_ARRAY:
		option_button.add_item(window_mode)


func _on_option_button_item_selected(index):
	SettingsSignalBus.emit_on_window_mode_selected(index)
	match index:
		0:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)


func select_current_window_mode() -> void:
	var mode = DisplayServer.window_get_mode()
	var borderless = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)
	match mode:
		DisplayServer.WINDOW_MODE_WINDOWED:
			if borderless:
				option_button.select(2)
				_on_option_button_item_selected(2)
			else:
				option_button.select(1)
				_on_option_button_item_selected(1)
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			if borderless:
				option_button.select(3)
				_on_option_button_item_selected(3)
			else:
				option_button.select(0)
				_on_option_button_item_selected(0)
		_:
			pass
