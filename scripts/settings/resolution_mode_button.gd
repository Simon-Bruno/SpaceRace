extends Control

@onready var option_button = $HBoxContainer/OptionButton


const RESOLUTION_DICTIONARY : Dictionary = {
	"1152 x 648": Vector2i(1152, 648),
	"1280 x 720": Vector2i(1280, 720),
	"1920 x 1080": Vector2i(1920, 1080)
}

var DISPLAY_RESOLUTION_KEYS : Array = RESOLUTION_DICTIONARY.keys()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_resolution_items()
	select_current_display_resolution()
	option_button.item_selected.connect(on_resolution_selected)


func on_resolution_selected(index : int):
	DisplayServer.window_set_size(RESOLUTION_DICTIONARY.values()[index])
	centre_window()


func add_resolution_items():
	for resolution_size_text in RESOLUTION_DICTIONARY:
		option_button.add_item(resolution_size_text)


func select_current_display_resolution():
	var current_resolution = DisplayServer.window_get_size()
	var current_resolution_string = str(current_resolution.x) + " " + "x" + " " + str(current_resolution.y)
	var index = DISPLAY_RESOLUTION_KEYS.find(current_resolution_string)
	option_button.select(index)


func centre_window():
	var centre_screen = DisplayServer.screen_get_position() + DisplayServer.screen_get_size() / 2
	var window_size = get_window().get_size_with_decorations()
	get_window().set_position(centre_screen - window_size/2)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
