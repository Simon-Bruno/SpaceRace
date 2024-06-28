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
	# Load data if it exists
	if FileAccess.file_exists(SaveManager.SETTINGS_SAVE_PATH) and not SettingsContainer.get_first():
		load_data()
	else:
		select_current_window_mode()


func load_data():
	_on_option_button_item_selected(SettingsContainer.get_window_mode_index())
	option_button.select(SettingsContainer.get_window_mode_index())


func add_window_mode_items():
	# Add window mode items to the option button
	for window_mode in WINDOW_MODE_ARRAY:
		option_button.add_item(window_mode)


func _on_option_button_item_selected(index):
	# Emit signal based on the selected window mode
	SettingsSignalBus.emit_on_window_mode_selected(index)
	# Set the window mode based on the selected window mode
	match index:
		0:
			# Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		1:
			# Window Mode
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		2:
			# Borderless Window
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		3:
			# Borderless Fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)


func select_current_window_mode() -> void:
	# Select the window mode based on the current window mode
	var mode = DisplayServer.window_get_mode()
	var borderless = DisplayServer.window_get_flag(DisplayServer.WINDOW_FLAG_BORDERLESS)
	match mode:
		DisplayServer.WINDOW_MODE_WINDOWED:
			if borderless:
				# Borderless Window
				option_button.select(2)
				_on_option_button_item_selected(2)
			else:
				# Window Mode
				option_button.select(1)
				_on_option_button_item_selected(1)
		DisplayServer.WINDOW_MODE_FULLSCREEN:
			if borderless:
				# Borderless Fullscreen
				option_button.select(3)
				_on_option_button_item_selected(3)
			else:
				# Fullscreen
				option_button.select(0)
				_on_option_button_item_selected(0)
		_:
			pass
