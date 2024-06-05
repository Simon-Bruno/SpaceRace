extends Node3D

var multiplayer_peer = ENetMultiplayerPeer.new()

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected

# Excluding host
var max_client_connections = 1

#Username van de speler, moet veranderbaar zijn in game
@export var playername = "Piet"

var players_connected = 0 
var players = {}

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_connection_failed():
	remove_multiplayer_peer()

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = playername
	player_connected.emit(peer_id, playername)

# Called when the host button is pressed
func _on_host_pressed(port):
	port = str(port).to_int()
	if multiplayer_peer.create_server(port, max_client_connections) == OK:
		multiplayer.multiplayer_peer = multiplayer_peer
		get_tree().change_scene_to_file("res://scenes/main.tscn")
		add_player_character()
		players[1] = playername
		player_connected.emit(1, playername)
	else:
		return false
	return true
	

func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null

func _on_player_connected(id):
	_register_player.rpc_id(id, playername)
	add_player_character(id)

@rpc("any_peer", "reliable")
func _register_player(new_player_info):
	var new_player_id = multiplayer.get_remote_sender_id()
	players[new_player_id] = new_player_info
	player_connected.emit(new_player_id, new_player_info)

func _on_player_disconnected(id):
	players.erase(id)
	player_disconnected.emit(id)
	if has_node(str(id)):
		var player_node = get_node(str(id))
		remove_child(player_node)
		player_node.queue_free()
	
func _on_leave_button_pressed():
	print("Leaving")
	var id = multiplayer_peer.get_unique_id()
	_on_player_disconnected(id)
	multiplayer_peer.disconnect_peer(id, true)
	remove_multiplayer_peer()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	
	
func _on_server_disconnected():
	remove_multiplayer_peer()
	players.clear()
	server_disconnected.emit()

# Called when the join button is pressed
func _on_join_pressed(ip, port):
	port = str(port).to_int()
	multiplayer_peer.create_client(ip, port)
	multiplayer.multiplayer_peer = multiplayer_peer

# Function to add a new player character to the scene
func add_player_character(id=1):
	var character = preload("res://scenes/camera.tscn").instantiate()
	character.name = str(id)
	add_child(character)
