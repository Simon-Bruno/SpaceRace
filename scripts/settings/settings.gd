class_name Settings
extends Control

@onready var back_button = $BackButton
@onready var settings_tab_container = $MarginContainer/VBoxContainer/Settings_Tab_Container

signal back_button_down

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	settings_tab_container.back.connect(_on_back_button_button_down) 


func _on_back_button_button_down():
	back_button_down.emit() # Emit signal to close the settings menu
	SettingsSignalBus.emit_settings_dictionary(SettingsContainer.make_storage_dict()) # Save settings to file
	set_process(false) # Stop processing input
	Audiocontroller.play_ui_press_sfx()
