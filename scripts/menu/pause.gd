extends Control

var game_status = false # Is true when game is paused, otherwise false

func _ready():
	var status = false 

func _process(delta):
	if Input.is_action_pressed("pause") and !game_status:
		_pause_game()
	elif Input.is_action_pressed("pause") and game_status:
		_resume_game()

func _pause_game():
	self.visible = true
	game_status = true
	print("Pausing game")

func _resume_game():
	self.visible = false
	game_status = false
	print("Resuming game")

func _on_resume_button_pressed():
	print("Resume button pressed")
	_resume_game()

func _on_settings_button_pressed():
	print("Settings button pressed")
	# Link with settings page TBC

func _on_titlescreen_button_pressed():
	print("Titlescreen button pressed")
	Network._on_leave_button_pressed()
	self.visible = false
