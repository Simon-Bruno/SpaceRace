class_name Settings
extends Control


@onready var back_button = $MarginContainer/VBoxContainer/BackButton
@onready var settings_tab_container = $MarginContainer/VBoxContainer/Settings_Tab_Container

signal back_button_down

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)


func _on_back_button_button_down():
	back_button_down.emit()
	SettingsSignalBus.emit_settings_dictionary(SettingsContainer.make_storage_dict())
	set_process(false)
