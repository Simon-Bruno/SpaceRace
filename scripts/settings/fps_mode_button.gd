extends Control


@onready var check_button = $HBoxContainer/CheckButton
@onready var state_label = $HBoxContainer/State_Label

# Called when the node enters the scene tree for the first time.
func _ready():
	check_button.toggled.connect(on_fps_toggled)


func set_label_text(button_pressed : bool):
	if button_pressed != true:
		state_label.text = "Off"
	else:
		state_label.text = "On"


func on_fps_toggled(button_pressed : bool):
	set_label_text(button_pressed)
	Network.emit_on_fps_toggled(button_pressed)


