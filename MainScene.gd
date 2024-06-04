extends Node3D

var multiplayer_peer = ENetMultiplayerPeer.new()
var max_client_connections = 3

@onready var menu = $Menu

var ip_address: String = "127.0.0.1"  # Default IP address

# Detect and set the local IP address based on the OS
func _ready():
	if OS.has_feature("windows"):
		if OS.has_environment("COMPUTERNAME"):
			ip_address = IP.resolve_hostname(str(OS.get_environment("COMPUTERNAME")), 1)
	elif OS.has_feature("x11"):
		if OS.has_environment("HOSTNAME"):
			ip_address = IP.resolve_hostname(str(OS.get_environment("HOSTNAME")), 1)
	elif OS.has_feature("OSX"):
		if OS.has_environment("HOSTNAME"):
			ip_address = IP.resolve_hostname(str(OS.get_environment("HOSTNAME")), 1)
	print("Resolved Local IP Address: ", ip_address)

# Called when the join button is pressed
func _on_join_pressed():
	var ip = $Menu/IP.text  # Use the IP address input by the user
	var port = str($Menu/Port.text).to_int()
	multiplayer_peer.create_client(ip, port)
	multiplayer.multiplayer_peer = multiplayer_peer
	menu.visible = false

# Called when the host button is pressed
func _on_host_pressed():
	var port = str($Menu/Port.text).to_int()
	print("Using Local IP Address for hosting: ", ip_address)
	multiplayer_peer.create_server(port, max_client_connections)
	multiplayer.multiplayer_peer = multiplayer_peer
	multiplayer_peer.peer_connected.connect(func(id): add_player_character(id))
	menu.visible = false
	add_player_character()

# Function to add a new player character to the scene
func add_player_character(id=1):
	var character = preload("res://player.tscn").instantiate()
	character.name = str(id)
	add_child(character)
