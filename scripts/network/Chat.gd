extends Control

@onready var message_display = $MessageDisplay
@onready var leave_button = $LeaveButton
@onready var send_button = $SendButton
@onready var message_input = $MessageInput
@onready var message_timer = $MessageTimer

func _input(event):
	if Input.is_action_just_pressed("chat_command"):
		message_input.grab_focus()
	if Input.is_key_pressed(KEY_ESCAPE):
		message_input.release_focus()
		send_button.release_focus()
		_on_message_input_focus_exited()
		message_display.visible = false
	if event is InputEventMouseButton and event.pressed:
		if not message_display.get_rect().has_point(get_local_mouse_position()) \
		and not message_input.get_rect().has_point(get_local_mouse_position()) \
		and not send_button.get_rect().has_point(get_local_mouse_position()): 
			message_display.visible = false


# Handle send button pressed for chat functionality
func _on_send_pressed():
	var msg = message_input.text
	if msg != "":
		msg_rpc.rpc(Network.playername, msg)
		message_display.visible = true
		send_button.disabled = true
		message_input.text = ""
		start_message_timer()


func pad_left(value, length, character="0"):
	var str_value = str(value)
	while str_value.length() < length:
		str_value = character + str_value
	return str_value


# Calculates the current in hours, minutes and seconds
func new_timestamp():
	var time = Time.get_time_dict_from_system()
	var hour = pad_left(time.hour, 2)
	var minute = pad_left(time.minute, 2)
	var second = pad_left(time.second, 2)
	var timestamp = "[color=beige]" + "[" + hour + ":" + minute + ":" + second +"]" + "[/color]"
	return timestamp


# Allows the player to leave the game when the button is pressed
func _on_leave_button_pressed():
	Network._on_leave_button_pressed()


@rpc("any_peer", "call_local")
func msg_rpc(sender, message):
	var colored_sender_id = "[color=red]" + str(sender) + "[/color]"
	message_display.bbcode_enabled = true
	message_display.append_text(str(new_timestamp()))
	message_display.append_text(" " + colored_sender_id + ": " + message + "\n")
	message_display.set_scroll_follow(true)
	message_display.visible = true
	start_message_timer()


func _on_message_input_text_submitted(_new_text):
	if not commands():
		_on_send_pressed()


# This function sets the caret to the correct position based on the length
# of the input in the 
func set_caret_pos():
	if message_input.text != "":
		message_input.set_caret_column(message_input.text.length())


func _on_message_input_focus_entered():
	Global.in_chat = true # to disable other actions when in chat (remove global later)
	message_input.set_max_length(1024) # Prevent message abuse
	message_display.visible = true 
	set_caret_pos()
	message_timer.stop()


func _on_message_input_focus_exited():
	if message_input.get_rect().has_point(get_local_mouse_position()) and message_input.has_focus():
		Global.in_chat = true
	else:
		Global.in_chat = false
		start_message_timer() 


func _on_message_input_gui_input(_event):
	if message_input.text != "":
		send_button.disabled = false 
	else:
		send_button.disabled = true


#TODO add more commands (respawn, etc)
func commands():
	if leave_game() or easter_egg():
		return true


# This function allows the player to leave the game when submitting "/leave" 
# in the chat
func leave_game():
	if message_input.text == "/leave":
		_on_leave_button_pressed()
		return true


func easter_egg():
	if message_input.text == "/easteregg":
		pass
		return true


func _on_message_timer_timeout():
	if not message_input.has_focus():
		message_display.visible = false


func start_message_timer():
	message_timer.start(5.0)
