class_name KeybindRebindButton
extends Control

@export var action_name : String = "move_left"
@onready var label = $HBoxContainer/Label
@onready var button = $HBoxContainer/Button 


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_unhandled_key_input(false)
	set_action_name()
	set_text_for_key()
	load_keybinds()


func load_keybinds():
	rebind_action_key(SettingsContainer.get_keybind(action_name))


func set_action_name():
	label.text = "Unassigned"
	match action_name:
		"move_forward":
			label.text = "Move Forward"
		"move_left":
			label.text = "Move Left"
		"move_back":
			label.text = "Move Back"
		"move_right":
			label.text = "Move Right"
		"jump":
			label.text = "Jump"
		"interact":
			label.text = "Interact"
		"attack":
			label.text = "Attack"
		"open_chat":
			label.text = "Open Chat"

func set_text_for_key():
	var action_events = InputMap.action_get_events(action_name)
	var action_event = action_events[0]
	var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
	button.text = "%s" % action_keycode


func _on_button_toggled(toggled_on):
	if toggled_on:
		button.text = "Press any key"
		set_process_unhandled_key_input(toggled_on)
		for i in get_tree().get_nodes_in_group("keybind_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = false
				i.set_process_unhandled_key_input(false)
	else:
		for i in get_tree().get_nodes_in_group("keybind_button"):
			if i.action_name != self.action_name:
				i.button.toggle_mode = true
				i.set_process_unhandled_key_input(false)
		set_text_for_key()


func _unhandled_key_input(event):
	rebind_action_key(event)
	button.button_pressed = false


func rebind_action_key(event):
	InputMap.action_erase_events(action_name)
	InputMap.action_add_event(action_name, event)
	SettingsContainer.set_keybind(action_name, event)
	set_process_unhandled_key_input(false)
	set_text_for_key()
	set_action_name()
	#var is_duplicate = false # Check whether a key is not used twice
	#var action_event = event
	#var action_keycode = OS.get_keycode_string(action_event.physical_keycode)
	#for i in get_tree().get_nodes_in_group("hotkey_button"):
		#if i.action_name != self.action_name:
			#if i.button.text == "%s" %action_keycode:
				#is_duplicate = true
				#break
	#if not is_duplicate:
		#InputMap.action_erase_events(action_name)
		#InputMap.action_add_event(action_name, event)
		#SettingsContainer.set_keybind(action_name, event)
		#set_process_unhandled_key_input(false)
		#set_text_for_key()
		#set_action_name()
