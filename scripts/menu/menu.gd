extends Control

@onready var settings = $Settings
@onready var username = $UsernameField

@export var inputBackground : Texture2D
@export var inputBackgroundInvalid : Texture2D

func _play_button_pressed():
	$StartMenu.visible = false
	$PlayMenu.visible = true
	Audiocontroller.play_ui_press_sfx()
	
func _back_button_pressed():
	$PlayMenu.visible = false
	$StartMenu.visible = true

func set_input_invalid(field):
	var original = field.get_theme_stylebox("normal")
	var stylebox = StyleBoxTexture.new()
	stylebox.texture = inputBackgroundInvalid
	field.add_theme_stylebox_override("normal", stylebox)
	await get_tree().create_timer(2).timeout
	field.add_theme_stylebox_override("normal", original)

func _join_button_pressed():
	Audiocontroller.play_ui_press_sfx()
	var username_val = username.text 
	if username_val == "":
		set_input_invalid(username)
		return
	
	$JoinMenu.visible = true
	username.visible = false
	$PlayMenu.visible = false

func _back_to_play_menu():
	$JoinMenu.visible = false
	$HostMenu.visible = false
	$PlayMenu.visible = true
	username.visible = true
	Audiocontroller.play_ui_press_sfx()

# Called when the node enters the scene tree for the first time.
func _on_host_pressed():
	Audiocontroller.play_ui_press_sfx()
	var username_val = username.text 
	if username_val == "":
		set_input_invalid(username)
		return
	
	$HostMenu.visible = true
	username.visible = false
	$PlayMenu.visible = false
	
func _on_host_menu_pressed():
	var username_val = username.text 
	if username_val == "":
		set_input_invalid(username)
		return
	
	Network.playername = username_val
	
	var port = $HostMenu/PortField.text
	if port == "":
		set_input_invalid($HostMenu/PortField)
		return 
		
	var hosting = await Network._on_host_pressed(port)
	if !hosting:
		set_notification_and_show("Could not create game!", $Host)

	_back_to_play_menu()
	_back_button_pressed()

func _on_join_menu_pressed():
	var username_val = username.text 
	if username_val == "":
		set_input_invalid(username)
		return
	
	Network.playername = username_val
	
	var ip = $JoinMenu/IpField.text
	if ip == "": 
		set_input_invalid($JoinMenu/IpField)
		return 
		
	var port = $JoinMenu/PortField.text
	if port == "":
		set_input_invalid($JoinMenu/PortField)
		return 

	if !Network._on_join_pressed(ip, port):
		set_notification_and_show("Could not join game", $Join)
	
	_back_to_play_menu()
	_back_button_pressed()

func _on_settings_button_pressed():
	$StartMenu.visible = false
	settings.set_process(true)
	settings.visible = true
	Audiocontroller.play_ui_press_sfx()

func _on_settings_back_button_down():
	$StartMenu.visible = true
	settings.visible = false


var last_parent
func set_notification_and_show(text, parent):
	#$DialogMessage/Text.text = text
	#$DialogMessage.visible = true
	#parent.visible = false
	last_parent = parent

func _on_quit_button_pressed():
	Audiocontroller.play_ui_press_sfx()
	get_tree().quit()
