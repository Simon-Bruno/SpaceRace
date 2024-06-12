class_name Settings
extends Control
#var pause_menu = preload("res://scenes/menu/pause.tscn").instantiate()

@onready var back_button = $MarginContainer/VBoxContainer/BackButton as Button

signal exit_options_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	back_button.button_down.connect(on_exit_pressed)
	set_process(false)

func on_exit_pressed() -> void:
	exit_options_menu.emit()
	set_process(false)

func _on_back_button_pressed():
	self.visible = false
	exit_options_menu.emit()
	set_process(false)
