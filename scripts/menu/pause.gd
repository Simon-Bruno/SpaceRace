extends Control

func _process(delta):
	if Input.is_action_pressed("pause") and !get_tree().paused:
		_pause_game()
	elif Input.is_action_pressed("pause") and get_tree().paused:
		_resume_game()

func _pause_game():
	get_tree().paused = true
	self.visible = true
	print("Pausing game")

func _resume_game():
	get_tree().paused = false
	self.visible = false
	print("Resuming game")

func _on_resume_button_pressed():
	print("Resume button pressed")
	_resume_game()

func _on_settings_button_pressed():
	print("Settings button pressed")

func _on_titlescreen_button_pressed():
	print("Titlescreen button pressed")
