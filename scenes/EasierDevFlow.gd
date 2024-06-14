extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(randf() + 0.1).timeout 
	AudioServer.set_bus_mute(0, false)
	Network.playername = "~DEV~"
	if not await Network._on_host_pressed(9999):
		Network._on_join_pressed("localhost", 9999)
	await get_tree().create_timer(0.5).timeout
	if multiplayer.is_server():
		
		var i = 0
		for id in Network.player_names.keys():
			if i < 2:
				$"../SpawnedItems/Lobby".team1.append(get_node("/root/Main/SpawnedItems/Lobby").get_node(str(id)))
			else:
				$"../SpawnedItems/Lobby".team2.append(get_node("/root/Main/SpawnedItems/Lobby").get_node(str(id)))
		$"../SpawnedItems/Lobby"._on_start_timer_timeout()
	
	
