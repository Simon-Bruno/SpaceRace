class_name Settings
extends Control
#var pause_menu = preload("res://scenes/menu/pause.tscn").instantiate()

@onready var back_button = $MarginContainer/VBoxContainer/BackButton as Button

signal back_to_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	back_button.button_down.connect(on_back_button_pressed)
	set_process(false)

func on_back_button_pressed() -> void:
	back_to_menu.emit()
	SettingsSignalBus.emit_settings_dictionary(SettingsContainer.make_storage_dict())
	set_process(false)
