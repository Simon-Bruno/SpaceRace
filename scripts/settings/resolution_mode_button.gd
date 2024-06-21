extends Control

@onready var option_button = $HBoxContainer/OptionButton


const RESOLUTION_DICTIONARY : Dictionary = {
	"1920 x 1080": Vector2i(1920, 1080),
	"1280 x 720": Vector2i(1280, 720),
	"1152 x 648": Vector2i(1152, 648)
}

var DISPLAY_RESOLUTION_KEYS : Array = RESOLUTION_DICTIONARY.keys()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_resolution_items()
	if FileAccess.file_exists(SaveManager.SETTINGS_SAVE_PATH) and not SettingsContainer.get_first():
		load_data()
	else:
		select_current_display_resolution()


func load_data():
	_on_option_button_item_selected(SettingsContainer.get_resolution_mode_index())
	option_button.select(SettingsContainer.get_resolution_mode_index())


func add_resolution_items():
	for resolution_size_text in RESOLUTION_DICTIONARY:
		option_button.add_item(resolution_size_text)


func _on_option_button_item_selected(index):
	SettingsSignalBus.emit_on_resolution_mode_selected(index)
	DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])
	option_button.select(2)
	centre_window()


func select_current_display_resolution():
	var curr_resolution = DisplayServer.window_get_size()
	var curr_resolution_str = str(curr_resolution.x) + " " + "x" + " " + str(curr_resolution.y)
	var index = DISPLAY_RESOLUTION_KEYS.find(curr_resolution_str)
	_on_option_button_item_selected(index)


func centre_window():
	var centre_screen = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(centre_screen - window_size / 2)
