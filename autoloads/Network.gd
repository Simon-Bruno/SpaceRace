extends Node3D

var multiplayer_peer = ENetMultiplayerPeer.new()

signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal player_added(id)
signal on_fps_toggled(value : bool)

# Excluding host
var max_client_connections = 3

var loaded_world = preload("res://scenes/lobby/lobby.tscn")
var loaded_menu = preload("res://scenes/menu/menu.tscn")

var inverted = 1
var other_team_member_id = null
var other_team_member_node = null

#Username van de speler, moet veranderbaar zijn in game
var playername

var player_teams = {}

var players_connected = 0
var player_names = {}

func _ready():
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func emit_on_fps_toggled(value : bool):
	on_fps_toggled.emit(value)

func _on_connection_failed():
	remove_multiplayer_peer()

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	player_names[peer_id] = playername
	player_connected.emit(peer_id, playername)
	rpc_id(1, "_register_player_rpc", peer_id, playername)

# Called when the host button is pressed
func _on_host_pressed(port):
	port = str(port).to_int()
	if multiplayer_peer.create_server(port, max_client_connections) == OK:
		multiplayer.multiplayer_peer = multiplayer_peer
		var world = loaded_world.instantiate()
		get_node("/root/Main/SpawnedItems/Menu").queue_free()
		get_node("/root/Main/SpawnedItems").add_child(world)
		await get_tree().create_timer(0.4).timeout
		player_added.emit(1)
		player_names[1] = playername
		player_connected.emit(1, playername)
		Audiocontroller.play_lobby_music()
	else:
		return false
	return true


func remove_multiplayer_peer():
	multiplayer.multiplayer_peer = null

func _on_player_connected(id):
	if multiplayer.is_server():
		_send_player_info.rpc(playername)
		player_added.emit(id)
		rpc_id(id, "_sync_player_names", player_names) # Send updated player_names to new client

@rpc("any_peer", "reliable")
func _send_player_info(new_player_info):
	var id = multiplayer.get_unique_id()
	player_names[id] = new_player_info
	player_connected.emit(id, new_player_info)
	if multiplayer.is_server():
		rpc("_sync_player_names", player_names)

@rpc("any_peer", "reliable")
func _register_player_rpc(id, new_player_info):
	player_names[id] = new_player_info
	player_connected.emit(id, new_player_info)
	if multiplayer.is_server():
		rpc("_sync_player_names", player_names)

@rpc("any_peer", "reliable")
func _sync_player_names(names_dict):
	player_names = names_dict.duplicate()
	for id in player_names.keys():
		player_connected.emit(id, player_names[id])

@rpc("authority", "call_local", "reliable")
func _hard_reset_to_lobby():
	other_team_member_id = null
	other_team_member_node = null
	player_teams.clear()
	inverted = 1

func _on_player_disconnected(id):
	player_names.erase(id)
	if multiplayer.is_server():
		var world = get_node_or_null("/root/Main/SpawnedItems/World")
		if world != null:
			world.queue_free()
			get_node("/root/Main/SpawnedItems").remove_child(world)
			_hard_reset_to_lobby.rpc()
			get_node("/root/Main/SpawnedItems").add_child(loaded_world.instantiate())
			for player_id in player_names.keys():
				get_node("/root/Main/SpawnedItems/Lobby").add_player_character(player_id)
	player_disconnected.emit(id)

	player_disconnected.emit(id)

func _on_leave_button_pressed():
	var id = multiplayer.get_unique_id()
	_on_player_disconnected(id)
	multiplayer_peer.disconnect_peer(id, true)
	remove_multiplayer_peer()
	multiplayer_peer.close()
	var world = get_node("/root/Main/SpawnedItems/World")
	if world:
		world.queue_free()
	get_node("/root/Main/SpawnedItems").remove_child(world)
	get_node("/root/Main/SpawnedItems").add_child(loaded_menu.instantiate())



func _on_server_disconnected():
	print("Server disconnect")
	var world = get_node_or_null("/root/Main/SpawnedItems/World")
	if world:
		world.queue_free()
	var lobby = get_node_or_null("/root/Main/SpawnedItems/Lobby")
	if lobby:
		lobby.queue_free()
	get_node("/root/Main/SpawnedItems").add_child(loaded_menu.instantiate())
	remove_multiplayer_peer()
	player_names.clear()
	server_disconnected.emit()

# Called when the join button is pressed
func _on_join_pressed(ip, port):
	port = str(port).to_int()
	if multiplayer_peer.create_client(ip, port) == OK:
		multiplayer.multiplayer_peer = multiplayer_peer
		get_node("/root/Main/SpawnedItems/Menu").queue_free()
		Audiocontroller.play_lobby_music()
		return true
	return false


func get_player_node_by_id(id):
	return get_node("/root/Main/SpawnedItems/World/PlayerSpawner").get_node(str(id))
