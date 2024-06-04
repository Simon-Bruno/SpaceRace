extends Node3D

var multiplayer_peer = ENetMultiplayerPeer.new()
var max_client_connections = 3

@onready var menu = $Menu
@onready var ip_label = $Menu/IPLabel

var ip_address: String = "127.0.0.1"  # Default IP address

# Detect and set the local IP address
func _ready():
	var local_addresses = IP.get_local_addresses()
	for address in local_addresses:
		if address.split('.').size() == 4:  #TODO: Better IP format check (Regex?)
			ip_address = address
			break
	ip_label.text = "Your IP: " + ip_address 

# Called when the join button is pressed
func _on_join_pressed():
	var ip = $Menu/IP.text 
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
