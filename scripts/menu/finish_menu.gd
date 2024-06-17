extends Control

func _ready():
	print("\n\n looking at username is: "+ Network.playername)
	var username = Network.playername
	var pressure_plate_vals = get_parent()
	var winner_id = pressure_plate_vals.winner_id

	if multiplayer.get_unique_id() == (winner_id) or int(Network.other_team_member_id) == (winner_id):
		var label_node = get_node("VBoxContainer/Label")
		label_node.text = str(username + "\nYou won!")

	else:
		#print("this is a losers_id: ", multiplayer.get_unique_id())
		var label_node = get_node("VBoxContainer/Label")
		label_node.text = str(username + "\nYou lost!")
	
# Go to lobby
func _on_play_again_pressed():
	if multiplayer.is_server():
		Network.go_to_lobby()
	else: 
		print("ask the host to let everybody go to lobby!")

# Go to menu
func _on_menu_pressed():
	Network._on_leave_button_pressed()

# Quit
func _on_quit_button_pressed():
	get_tree().quit()
