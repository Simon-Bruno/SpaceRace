extends Node3D

func _enter_tree():
	if multiplayer.is_server():
		$MultiplayerSpawner.set_multiplayer_authority(multiplayer.get_unique_id())

func _ready():
	if multiplayer.is_server():
		var world = preload("res://scenes/world/worldGeneration.tscn").instantiate()
		add_child(world)
		world.name = "world"
		
		for id in Network.player_names.keys():
			add_player_character(id)

func add_player_character(id):
	var character = preload("res://scenes/player/player.tscn").instantiate()
	character.name = str(id)
	add_child(character)

