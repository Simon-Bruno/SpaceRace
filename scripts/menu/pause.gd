extends Control

@onready var settings = $Settings
const CHAT_PATH = "/root/Main/SpawnedItems/World/Chat"
const HUD_PATH = "/root/Main/SpawnedItems/World/HUD/InGame"
const LOBBY_PATH = "/root/Main/SpawnedItems/Lobby"
const MENU_PATH = "/root/Main/SpawnedItems/Menu"


func _ready():
	self.visible = false
	settings.visible = false


# Handles the ESC button event, to activate the pause menu
func handle_esc_input():
	if Global.in_pause:
		_resume_game()
	else:
		_pause_game()


# Will show the pause menu, while the game is still going
func _pause_game():
	self.visible = true
	Global.in_pause = true
	var chat = get_node_or_null(CHAT_PATH)
	var hud = get_node_or_null(HUD_PATH)
	if chat != null:
		chat.visible = false
	if hud != null:
		hud.visible = false



# Hides the pause menu
func _resume_game():
	self.visible = false
	Global.in_pause = false
	var chat = get_node_or_null(CHAT_PATH)
	var hud = get_node_or_null(HUD_PATH)
	if chat != null:
		chat.visible = true
	if hud != null:
		hud.visible = true


func _on_resume_button_pressed():
	_resume_game()
	Audiocontroller.play_ui_press_sfx()


func _on_settings_button_pressed():
	Audiocontroller.play_ui_press_sfx()
	settings.set_process(true)
	settings.visible = true


func _on_settings_back_button_down():
	settings.visible = false
	

func _on_titlescreen_button_pressed():
	Network._on_leave_button_pressed()
	Audiocontroller.play_menu_music()
	Audiocontroller.play_ui_press_sfx()
	self.visible = false
	Global.in_pause = false
	var lobby = get_node_or_null(LOBBY_PATH)
	if lobby:
		lobby.queue_free()

	var menu = get_node_or_null(MENU_PATH)
	if menu:
		menu.visible = true
