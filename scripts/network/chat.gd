extends Control

@onready var message_display = $MessageDisplay
@onready var send_button = $SendButton
@onready var message_input = $MessageInput
@onready var message_timer = $MessageTimer
@onready var video_stream_player = $VideoStreamPlayer
@onready var fps_meter = $FPS_Meter

#var player_spawner_script = preload("res://scripts/player/player_spawner.gd").new()


# Enable BBCode parsing and text selection
func _ready():
	message_display.bbcode_enabled = true
	message_display.selection_enabled = true


# This function handles different kinds of inputs given by the user
func _input(event):
	if Input.is_action_just_pressed("open_chat") and not Global.in_pause and Global.on_floor:
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


func _process(_delta):
	if SettingsContainer.get_fps_meter():
		fps_meter.visible = true
		fps_meter.text = "FPS: " + str(Engine.get_frames_per_second())
	else:
		fps_meter.visible = false


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


# Remote procedure call (RPC) for sending messages between players
@rpc("any_peer", "call_local")
func msg_rpc(sender, message):	
	var peer_id = _get_key(sender)
	var team = Network.player_teams[peer_id]
	message_display.append_text(str(new_timestamp()))
	if str(team) == "1":
		var colored_sender_id = "[color=red]" + str(team) + " - " + str(sender) + "[/color]"
		message_display.append_text(" " + colored_sender_id + ": " + message + "\n")
	elif str(team) == "2":
		var colored_sender_id = "[color=blue]" + str(team) + " - " + str(sender) + "[/color]"
		message_display.append_text(" " + colored_sender_id + ": " + message + "\n")
	else:
		var colored_sender_id = "[color=grey]" + str(sender) + "[/color]"
		message_display.append_text(" " + colored_sender_id + ": " + message + "\n")
	message_display.set_scroll_follow(true)
	message_display.visible = true
	start_message_timer()


# Returns the corresponding peer id given a name
func _get_key(sender):
	var players = Network.player_names
	for key in players.keys():
		if players[key] == sender:
			return str(key)
	return 0


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
	if leave_game() or easter_egg() or stop_easter_egg() \
	or mute_master_command() or mute_music_command() or mute_sfx_command() \
	or unmute_master_command() or unmute_music_command() or unmute_sfx_command() \
	or respawn_command() or rizz_command():
		return true


# This function allows the player to leave the game when submitting "/leave"
# in the chat
func leave_game():
	if message_input.text == "/leave":
		Network._on_leave_button_pressed()
		Audiocontroller.play_menu_music()
		return true


# Function to start an easter egg when the "/easteregg" command is submitted
func easter_egg():
	if message_input.text == "/easteregg":
		Audiocontroller.mute_music()
		video_stream_player.play()
		return true


# Function to stop the easter egg when the "/stop_easteregg" command is
# submitted
func stop_easter_egg():
	if message_input.text == "/stop_easteregg":
		Audiocontroller.unmute_music()
		video_stream_player.stop()
		return true


func _on_video_stream_player_finished():
	Audiocontroller.unmute_music()


func mute_master_command():
	if message_input.text == "/mute_master":
		Audiocontroller.mute_master()
		return true


func unmute_master_command():
	if message_input.text == "/unmute_master":
		Audiocontroller.unmute_master()
		return true


func mute_music_command():
	if message_input.text == "/mute_music":
		Audiocontroller.mute_music()
		return true


func unmute_music_command():
	if message_input.text == "/unmute_music":
		Audiocontroller.unmute_music()
		return true


func mute_sfx_command():
	if message_input.text == "/mute_sfx":
		Audiocontroller.mute_sfx()
		return true


func unmute_sfx_command():
	if message_input.text == "/unmute_sfx":
		Audiocontroller.unmute_sfx()
		return true


func rizz_command():
	if message_input.text == "/rizz":
		Audiocontroller.play_rizz_sfx()
		return true


func respawn_command():
	if message_input.text == "/respawn":
		#var player_spawner = get_node("/root/Main/SpawnedItems/World/PlayerSpawner")
		#player_spawner.respawn_player()
		return true

# Called when the message timer times out, hides the message display if the
# input field is not focused
func _on_message_timer_timeout():
	if not message_input.has_focus():
		message_display.visible = false


# Start the message timer for hiding the message display after a delay
func start_message_timer():
	message_timer.start(5.0)
