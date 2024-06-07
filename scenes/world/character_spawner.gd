extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		Network.player_added.connect(add_player_character)
		var world = preload("res://scenes/world/worldGeneration.tscn").instantiate()
		add_child(world)
		world.name = "world"
		

func add_player_character(id):
	var character = preload("res://scenes/player/player.tscn").instantiate()
	character.name = str(id)
	add_child(character)
	Network.player_nodes[id] = character
	Network.player_spawned.emit(character, id)
	Network.player_nodes_changed.emit()
	Network._update_player_node_dict.rpc(Network.player_nodes)
	
	#TODO: Remove hardcode enemy
	var enemy = preload("res://scenes/enemy/enemy.tscn").instantiate()
	enemy.position = Vector3(2,20,4)
	add_child(enemy, true)
	
