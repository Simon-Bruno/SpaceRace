extends Node

@onready var pause_menu = $Pause


func _process(delta):
	if Input.is_action_just_pressed("pause"):
		_toggle_pause_menu()


func _toggle_pause_menu():
	if get_tree().paused:
		pause_menu.hide_menu()
	else:
		pause_menu.show_menu()

func _resume_game():
	get_tree().paused = false
	
	
func _pause_game():
	get_tree().paused = true
	

func _on_resume_pressed():
	_resume_game()


func _on_settings_pressed():
	print("Settings page TBC")


func _on_titlescreen_pressed():
	print("TitleScreen TBC")


func _on_quit_pressed():
	get_tree().quit()
