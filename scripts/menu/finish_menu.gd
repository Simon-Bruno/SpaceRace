extends Control

var old_teams = {}
var other_team_member_id = null
var win_team = null
var time = null
var other_ids = null

func set_screen():
	Audiocontroller.play_finish_menu_music()
	var username = Network.playername
	
	if old_teams[str(multiplayer.get_unique_id())] == win_team:
		$WinnerLabel/Winner1.text = Network.player_names[multiplayer.get_unique_id()]
		$WinnerLabel/Winner2.text = Network.player_names[other_team_member_id]
		$LoserLabel/Loser1.text = Network.player_names[other_ids[0]]
		$LoserLabel/Loser1.text = Network.player_names[other_ids[1]]
		Audiocontroller.play_victory_sfx()
	else:
		$WinnerLabel/Winner1.text = Network.player_names[other_ids[0]]
		$WinnerLabel/Winner2.text = Network.player_names[other_ids[1]]
		$LoserLabel/Loser1.text = Network.player_names[multiplayer.get_unique_id()]
		$LoserLabel/Loser1.text = Network.player_names[other_team_member_id]
		Audiocontroller.play_defeat_1_sfx()
	
	var seconds = int(floor(time))
	var minutes = floor(seconds / 60)
	seconds = seconds % 60
	seconds = "0%s" % [seconds] if seconds < 10 else str(seconds)

	$TimerTitle/TimeLabel.text = "%s:%s" % [minutes, seconds] if minutes > 0 else str(seconds)


# Go to lobby
func _on_play_again_pressed():
	queue_free()
	Audiocontroller.play_lobby_music()
	Audiocontroller.play_ui_press_sfx()

# Go to menu
func _on_menu_pressed():
	Network._on_leave_button_pressed()
	Audiocontroller.play_menu_music()
	Audiocontroller.play_ui_press_sfx()

# Quit
func _on_quit_button_pressed():
	Audiocontroller.play_ui_press_sfx()
	get_tree().quit()
