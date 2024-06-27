extends Control


@onready var check_button = $HBoxContainer/CheckButton
@onready var state_label = $HBoxContainer/State_Label

# Called when the node enters the scene tree for the first time.
func _ready():
	check_button.toggled.connect(on_fps_toggled)
	if FileAccess.file_exists(SaveManager.SETTINGS_SAVE_PATH) and not SettingsContainer.get_first():
		load_data()


func load_data():
	if SettingsContainer.get_fps_meter():
		check_button.button_pressed = true
	else:
		check_button.button_pressed = false

	on_fps_toggled(SettingsContainer.get_fps_meter())


func set_label_text(button_pressed : bool):
	if not button_pressed:
		state_label.text = "Off"
	else:
		state_label.text = "On"


func on_fps_toggled(button_pressed : bool):
	set_label_text(button_pressed)
	SettingsSignalBus.emit_on_fps_toggled(button_pressed)


