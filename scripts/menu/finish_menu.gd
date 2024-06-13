extends Control

func _ready():
	print("\n\n looking at username is: "+ Network.playername)
	var username = Network.playername
	var pressure_plate_vals = get_parent()
	var winning_players = pressure_plate_vals.winning_players
	print("with his id is", multiplayer.get_unique_id())
	print("so the winning players are: ", winning_players)

	print("2nd val should be in first array to win:" + str(winning_players) +  str( multiplayer.get_unique_id()))
	
	if str(multiplayer.get_unique_id()) in winning_players:
		print("this is a winners_id: ", multiplayer.get_unique_id())
		var label_node = get_node("VBoxContainer/Label")
		label_node.text = str(username + "\nYou won!")
	else:
		print("this is a losers_id: ", multiplayer.get_unique_id())
		var label_node = get_node("VBoxContainer/Label")
		label_node.text = str(username + "\nYou lost")
	print("end of playermenu \n\n")
# Go to lobby
func _on_play_again_pressed():
	pass

# Go to menu
func _on_menu_pressed():
	pass

# Quit
func _on_quit_button_pressed():
	get_tree().quit()
