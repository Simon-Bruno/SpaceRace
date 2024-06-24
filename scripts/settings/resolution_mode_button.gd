extends Control

@onready var option_button = $HBoxContainer/OptionButton


const RESOLUTION_DICTIONARY : Dictionary = {
	"1920 x 1080": Vector2i(1920, 1080),
	"1280 x 720": Vector2i(1280, 720),
	"1152 x 648": Vector2i(1152, 648)
}

var DISPLAY_RESOLUTION_KEYS : Array = RESOLUTION_DICTIONARY.keys()
var DISPLAY_RESOLUTION_VALUES : Array = RESOLUTION_DICTIONARY.values()
var DISPLAY_RESOLUTION_X_VALUES : Array = []
var DISPLAY_RESOLUTION_Y_VALUES : Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	create_display_arr()
	add_resolution_items()
	if FileAccess.file_exists(SaveManager.SETTINGS_SAVE_PATH) and not SettingsContainer.get_first():
		load_data()
	else:
		select_current_display_resolution()


func load_data():
	_on_option_button_item_selected(SettingsContainer.get_resolution_mode_index())
	option_button.select(SettingsContainer.get_resolution_mode_index())


func create_display_arr():
	for i in range(len(DISPLAY_RESOLUTION_VALUES)):
		DISPLAY_RESOLUTION_X_VALUES.append(DISPLAY_RESOLUTION_VALUES[i][0])
		DISPLAY_RESOLUTION_Y_VALUES.append(DISPLAY_RESOLUTION_VALUES[i][1])


func add_resolution_items():
	for resolution_size_text in RESOLUTION_DICTIONARY:
		option_button.add_item(resolution_size_text)


func _on_option_button_item_selected(index):
	SettingsSignalBus.emit_on_resolution_mode_selected(index)
	DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])
	option_button.select(index)
	centre_window()


func select_current_display_resolution():
	var curr_resolution = DisplayServer.window_get_size()
	var curr_resolution_str = str(curr_resolution.x) + " " + "x" + " " + str(curr_resolution.y)
	var index_with_keys = DISPLAY_RESOLUTION_KEYS.find(curr_resolution_str)
	var index_with_xvalues = DISPLAY_RESOLUTION_X_VALUES.find(curr_resolution[0])
	var index_with_yvalues = DISPLAY_RESOLUTION_Y_VALUES.find(curr_resolution[1])
	if index_with_keys != -1:
		_on_option_button_item_selected(index_with_keys)
	elif index_with_xvalues != -1:
		_on_option_button_item_selected(index_with_xvalues)
	elif index_with_yvalues != -1:
		_on_option_button_item_selected(index_with_yvalues)


func centre_window():
	var centre_screen = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(centre_screen - window_size / 2)
