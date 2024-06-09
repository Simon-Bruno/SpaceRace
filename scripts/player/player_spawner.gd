extends Node3D	
		
func _ready():
	print(Network.player_nodes)
	for id in Network.player_nodes:
		add_player_character(id)
		
func add_player_character(id):
	print("player_spawner script add player character id: ", id)
	var character = preload("res://scenes/player/player.tscn").instantiate()
	character.name = str(id)
	add_child(character)

	
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
