extends Control

func _ready():
	Audiocontroller.play_finish_menu_music()
	print("\n\n looking at username is: "+ Network.playername)
	var username = Network.playername
	var pressure_plate_vals = get_parent()
	var winner_id = pressure_plate_vals.winner_id
	
	var your_id = multiplayer.get_unique_id() 

	if Network.other_team_member_id != null and Network.other_team_member_id.is_valid_int():
		if your_id == (winner_id) or Network.other_team_member_id.to_int() == (winner_id):
			var label_node = get_node("VBoxContainer/Label")
			label_node.text = str(username + "\nYou won!")
	elif your_id == (winner_id): 
		var label_node = get_node("VBoxContainer/Label")
		label_node.text = str(username + "\nYou won!")
	else:
		var label_node = get_node("VBoxContainer/Label")
		label_node.text = str(username + "\nYou lost!")

# Copied from menu.gd
var last_parent
func set_notification_and_show(text, parent):
	$DialogMessage/Text.text = text
	$DialogMessage.visible = true

# Currently:
# IF host press play again: everybody goes to lobby
# IF other player press play again: nothing happens (should show error message pop up)
# IF host press main menu: everybody goes to main menu
# IF other player presses main menu: He goes to main menu, host to lobby

# Go to lobby
func _on_play_again_pressed():
	if multiplayer.is_server():
		Network.go_to_lobby(multiplayer.get_unique_id())
	else: 
		print("ask the host to let everybody go to lobby!")
		set_notification_and_show("Ask the Host, to press the play again button\n 
									so that everybody can go to the lobby!", $Join)

# Go to menu
func _on_menu_pressed():
	Network._on_leave_button_pressed()
	Audiocontroller.play_menu_music()

# Quit
func _on_quit_button_pressed():
	get_tree().quit()
