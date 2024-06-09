extends Control

@onready var message_display = $MessageDisplay
@onready var leave_button = $LeaveButton
@onready var send_button = $SendButton
@onready var message_input = $MessageInput
@onready var message_timer = $MessageTimer
@onready var video_stream_player = $VideoStreamPlayer

# Enable BBCode parsing and text selection
func _ready():
	message_display.bbcode_enabled = true
	message_display.selection_enabled = true


# This function handles different kinds of inputs given by the user
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
	if msg != "" and not commands():
		msg_rpc.rpc(Network.playername, msg)
		message_display.visible = true
		send_button.disabled = true
		start_message_timer()
	message_input.text = ""


# Helper function to pad a value with leading characters up to a given length
func pad_left(value, length, character="0"):
	var str_value = str(value)
	while str_value.length() < length:
		str_value = character + str_value
	return str_value


# Generates a timestamp string with the current time
func new_timestamp():
	var time = Time.get_time_dict_from_system()
	var hour = pad_left(time.hour, 2)
	var minute = pad_left(time.minute, 2)
	var second = pad_left(time.second, 2)
	var timestamp = "[color=beige]" + "[" + hour + ":" + minute + ":" + \
	second +"]" + "[/color]"
	return timestamp


# Allows the player to leave the game when the leave button is pressed
func _on_leave_button_pressed():
	Network._on_leave_button_pressed()


# Remote procedure call (RPC) for sending messages between players
@rpc("any_peer", "call_local")
func msg_rpc(sender, message):
	var colored_sender_id = "[color=red]" + str(sender) + "[/color]"
	message_display.append_text(str(new_timestamp()))
	message_display.append_text(" " + colored_sender_id + ": " + message + "\n")
	message_display.set_scroll_follow(true)
	message_display.visible = true
	start_message_timer()


# To handle when text is submitted with the enter key
func _on_message_input_text_submitted(_new_text):
	_on_send_pressed()


# This function sets the caret to the correct position based on the length of
# the input
func set_caret_pos():
	if message_input.text != "":
		message_input.set_caret_column(message_input.text.length())


# Called when the message input field gets focus
func _on_message_input_focus_entered():
	Global.in_chat = true # To disable other actions when in chat #TODO remove
	message_display.visible = true
	message_input.set_max_length(1024)
	set_caret_pos()
	message_timer.stop()


# Called when the message input field loses focus
func _on_message_input_focus_exited():
	if message_input.get_rect().has_point(get_local_mouse_position()) and \
	 message_input.has_focus():
		Global.in_chat = true # TODO remove global
	else:
		Global.in_chat = false # TODO remove global
		start_message_timer()


# Enable or disable the send button based on whether the input field has text
func _on_message_input_gui_input(_event):
	if message_input.text != "":
		send_button.disabled = false
	else:
		send_button.disabled = true


#TODO add more commands (respawn, etc)
# Check for special commands in the input field
func commands():
	if leave_game() or easter_egg() or stop_easter_egg():
		return true


# This function allows the player to leave the game when submitting "/leave"
# in the chat
func leave_game():
	if message_input.text == "/leave":
		_on_leave_button_pressed()
		return true


# Function to start an easter egg when the "/easteregg" command is submitted
func easter_egg():
	if message_input.text == "/easteregg":
		video_stream_player
		video_stream_player.play()
		return true


# Function to stop the easter egg when the "/stop_easteregg" command is
# submitted
func stop_easter_egg():
	if message_input.text == "/stop_easteregg":
		video_stream_player.stop()
		return true


# Called when the message timer times out, hides the message display if the
# input field is not focused
func _on_message_timer_timeout():
	if not message_input.has_focus():
		message_display.visible = false


# Start the message timer for hiding the message display after a delay
func start_message_timer():
	message_timer.start(5.0)
