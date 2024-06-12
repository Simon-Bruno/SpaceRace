extends Control

@onready var settings = $Settings

var game_status = false # Is true when game is paused, otherwise false

func _ready():
	var status = false
	self.visible = false
	settings.visible = false

# Handles the ESC button event, to activate the pause menu
func handle_esc_input():
	if game_status:
		_resume_game()
	else:
		_pause_game()

# Will show the pause menu, while the game is still going
func _pause_game():
	print("Pausing game")
	self.visible = true
	game_status = true

# Hides the pause menu
func _resume_game():
	print("Resuming game")
	self.visible = false
	game_status = false

func _on_resume_button_pressed():
	print("Resume button pressed")
	_resume_game()

func _on_settings_button_pressed():
	print("Settings button pressed")
	settings.set_process(true)
	settings.visible = true

func _on_titlescreen_button_pressed():
	print("Titlescreen button pressed")
	Network._on_leave_button_pressed()
	self.visible = false
	game_status = false
