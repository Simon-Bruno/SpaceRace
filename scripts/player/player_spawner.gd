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
	Network._update_player_node_dict.rpc(Network.player_nodes)
	
	#TODO: Remove hardcode enemy
	var enemy = preload("res://scenes/enemy/enemy.tscn").instantiate()
	enemy.position = Vector3(2,20,4)
	add_child(enemy, true)

var player = null
func player_died(dead_player):
	player = dead_player
	self.remove_child(dead_player)
	$RespawnTimer.start()
	
func respawn_player():
	player.health = 40
	add_child(player)


func _on_respawn_timer_timeout():
	respawn_player()
