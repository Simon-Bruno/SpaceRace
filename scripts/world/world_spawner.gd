extends Node3D


func _ready():
	if multiplayer.is_server():
		var world = preload("res://scenes/world/worldGeneration.tscn").instantiate()
		add_child(world)
		world.name = "world"
		
		for id in Network.player_names.keys():
			add_player_character(id)
		
		#TODO: Remove hardcode enemy
		var enemy = preload("res://scenes/enemy/enemy.tscn").instantiate()
		enemy.position = Vector3(2,20,4)
		add_child(enemy, true)
		
		#TODO: Remove hardcode item
		var item = preload("res://scenes/item/item.tscn").instantiate()
		item.position = Vector3(4,5,4)
		add_child(item, true)
		


func add_player_character(id):
	var character = preload("res://scenes/player/player.tscn").instantiate()
	character.name = str(id)
	add_child(character)
	Network.player_nodes[id] = character
	Network.player_spawned.emit(character, id)
	Network._update_player_node_dict.rpc(Network.player_nodes)

