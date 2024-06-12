extends Control

func _ready():
	print("username is: "+ Network.playername)
	var username = Network.playername
	var pressure_plate_vals = get_parent()
	var winning_players = pressure_plate_vals.winning_players
	print(winning_players, multiplayer.get_unique_id())
	
	if str(multiplayer.get_unique_id()) in winning_players:
		var label_node = get_node("VBoxContainer/Label")
		label_node.text = str(username + "\nYou won!")
	else:
		var label_node = get_node("VBoxContainer/Label")
		label_node.text = str(username + "\nYou lost")

# Go to lobby
func _on_play_again_pressed():
	pass

# Go to menu
func _on_menu_pressed():
	pass

# Quit
func _on_quit_button_pressed():
	get_tree().quit()
