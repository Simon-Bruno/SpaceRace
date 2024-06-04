extends Node3D

var multiplayer_peer = ENetMultiplayerPeer.new()

# Excluding host
var max_client_connections = 1
var connecting = false

@onready var loadingText = $LoadingText
@onready var menu = $Menu
var timeout = 3.0 # Seconds
var time_elapsed = 0.0

# Called when the join button is pressed
func _on_join_pressed():
	var port = str($Menu/Port.text).to_int()
	multiplayer_peer.create_client("localhost", port)
	multiplayer.multiplayer_peer = multiplayer_peer
	menu.visible = false
	loadingText.text = "Loading..."
	connecting = true
	
func _process(_delta):
	if connecting:
		time_elapsed += _delta
		if multiplayer_peer.get_connection_status() == multiplayer_peer.CONNECTION_CONNECTED:
			loadingText.queue_free()
			connecting = false
		elif (multiplayer_peer.get_connection_status() == multiplayer_peer.CONNECTION_DISCONNECTED 
		or time_elapsed >= timeout):
			loadingText.text = "Couldn't connect to game, player limit reached"
			connecting = false
			menu.visible = true

# Called when the host button is pressed
func _on_host_pressed():
	var port = str($Menu/Port.text).to_int()
	if multiplayer_peer.create_server(port, max_client_connections) == OK:
		multiplayer.multiplayer_peer = multiplayer_peer
		multiplayer_peer.peer_connected.connect(func(id): add_player_character(id))
		menu.visible = false
		add_player_character()
	else:
		loadingText.text = "Failed to start server"
		loadingText.visible = true
	
# function to add a new player character to the scene
func add_player_character(id=1):
	var character = preload("res://player.tscn").instantiate()
	character.name = str(id)
	add_child(character)
