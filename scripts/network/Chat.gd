extends Node

@onready var message_display = $MessageDisplay
@onready var message_input = $VBoxContainer/HBoxContainer/MessageInput

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
