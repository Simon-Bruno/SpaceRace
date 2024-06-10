extends Control

func _ready():
	multiplayer.connection_failed.connect(_on_connection_failed)

func _on_connection_failed():
	set_notification_and_show("Could not connect to the game", $Holder)

# Called when the node enters the scene tree for the first time.
func _on_host_pressed():
	var username = $Holder/UsernameField.text 
	if username == "":
		set_notification_and_show("You need to choose a username before you can host a game!", $Holder)
		return
	
	$Host.visible = true
	$Holder.visible = false
	
func _on_host_menu_pressed():
	var username = $Holder/UsernameField.text 
	if username == "":
		set_notification_and_show("You need to choose a username before you can host a game!", $Host)
		return
	
	Network.playername = username
	
	var port = $Host/Holder/Port.text
	if port == "":
		set_notification_and_show("You need to fill in a port!", $Host)
		return 
		
	var hosting = await Network._on_host_pressed(port)
	if !hosting:
		set_notification_and_show("Could not create game!", $Host)
		
	$Host.visible = false
	$Holder.visible = true
	
func _on_join_pressed():
	var username = $Holder/UsernameField.text 
	if username == "":
		set_notification_and_show("You need to choose a username before you can join a game!", $Holder)
		return
	
	$Join.visible = true
	$Holder.visible = false
	
func _on_join_menu_pressed():
	var username = $Holder/UsernameField.text 
	if username == "":
		set_notification_and_show("You need to choose a username before you can join a game!", $Join)
		return
	
	Network.playername = username
	
	var ip = $Join/Holder/IP.text
	if ip == "": 
		set_notification_and_show("You need to fill in an ip address!", $Join)
		return 
		
	var port = $Join/Holder/Port.text
	if port == "":
		set_notification_and_show("You need to fill in a port!",$Join)
		return 

	if !Network._on_join_pressed(ip, port):
		set_notification_and_show("Could not join game", $Join)
		
	$Join.visible = false
	$Holder.visible = true

var last_parent
func set_notification_and_show(text, parent):
	$DialogMessage/Text.text = text
	$DialogMessage.visible = true
	parent.visible = false
	last_parent = parent

func _on_close_dialog_pressed():
	$DialogMessage.visible = false
	last_parent.visible = true
	 
func _on_close_host_button_pressed():
	$Host.visible = false
	$Holder.visible = true

func _on_close_join_button_pressed():
	$Join.visible = false
	$Holder.visible = true

func _on_quit_button_pressed():
	get_tree().quit()
