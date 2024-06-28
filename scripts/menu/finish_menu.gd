extends Control

var old_teams = {}
var other_team_member_id = null
var win_team = null
var time = null
var other_ids = null

func set_screen():
	Audiocontroller.play_finish_menu_music()
	
	if old_teams[str(multiplayer.get_unique_id())] == win_team:
		$WinnerLabel/Winner1.text = Network.player_names[multiplayer.get_unique_id()]
		$WinnerLabel/Winner2.text = Network.player_names[other_team_member_id.to_int()]
		$LoserLabel/Loser1.text = Network.player_names[other_ids[0].to_int()]
		$LoserLabel/Loser2.text = Network.player_names[other_ids[1].to_int()]
		Audiocontroller.play_victory_sfx()
	else:
		$WinnerLabel/Winner1.text = Network.player_names[other_ids[0].to_int()]
		$WinnerLabel/Winner2.text = Network.player_names[other_ids[1].to_int()]
		$LoserLabel/Loser1.text = Network.player_names[multiplayer.get_unique_id()]
		$LoserLabel/Loser2.text = Network.player_names[other_team_member_id.to_int()]
		Audiocontroller.play_defeat_1_sfx()
	
	var seconds = int(floor(time))
	var minutes = floor(seconds / 60)
	seconds = seconds % 60
	seconds = "0%s" % [seconds] if seconds < 10 else str(seconds)

	$TimerTitle/TimeLabel.text = "%s:%s" % [minutes, seconds] if minutes > 0 else str(seconds)

@rpc("authority", "call_remote", "reliable")
func host_left():
	queue_free()
	get_parent().remove_child(self)

# Go to lobby
func _on_play_again_pressed():
	queue_free()
	get_parent().remove_child(self)
	Audiocontroller.play_lobby_music()
	Audiocontroller.play_ui_press_sfx()

# Go to menu
func _on_menu_pressed():
	if multiplayer.is_server():
		host_left.rpc()
	
	queue_free()
	get_parent().remove_child(self)
	Network._on_leave_button_pressed()
	Audiocontroller.play_menu_music()
	Audiocontroller.play_ui_press_sfx()

# Quit
func _on_quit_button_pressed():
	if multiplayer.is_server():
		host_left.rpc()
		
	Audiocontroller.play_ui_press_sfx()
	get_tree().quit()
