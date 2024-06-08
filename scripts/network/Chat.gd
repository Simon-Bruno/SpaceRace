extends Control

@onready var message_display = $MessageDisplay
@onready var leave_button = $LeaveButton
@onready var send_button = $SendButton
@onready var message_input = $MessageInput


func _input(event):
	if event is InputEventMouseButton and event.pressed or Input.is_key_pressed(KEY_ESCAPE):
		Global.in_chat = false
		message_input.release_focus()
		send_button.release_focus()


# Handle send button pressed for chat functionality
func _on_send_pressed():
	var msg = message_input.text
	if msg != "":
		msg_rpc.rpc(Network.playername, msg)
		message_input.text = ""


func pad_left(value, length, character="0"):
	var str_value = str(value)
	while str_value.length() < length:
		str_value = character + str_value
	return str_value


func new_timestamp():
	var time = Time.get_time_dict_from_system()
	var hour = pad_left(time.hour, 2)
	var minute = pad_left(time.minute, 2)
	var second = pad_left(time.second, 2)
	var timestamp = "[color=beige]" + "[" + hour + ":" + minute + ":" + second +"]" + "[/color]"
	return timestamp


func _on_leave_button_pressed():
	Network._on_leave_button_pressed()

@rpc("any_peer", "call_local")
func msg_rpc(sender, message):
	var colored_sender_id = "[color=red]" + str(sender) + "[/color]"
	message_display.bbcode_enabled = true
	message_display.text += str(new_timestamp())
	message_display.text += " " + colored_sender_id + ": " + message + "\n"


func _on_message_input_text_submitted(new_text):
	_on_send_pressed()


func _on_message_input_focus_entered():
	message_input.set_max_length(1024)
	Global.in_chat = true
