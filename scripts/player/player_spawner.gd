extends Node3D	


func add_player_character(id):
	var character = preload("res://scenes/player/player.tscn").instantiate()
	character.name = str(id)
	add_child(character)

	
var dead_player = null
func player_died(player_to_die):
	dead_player = player_to_die
	self.remove_child(player_to_die)
	$RespawnTimer.start()
	
func respawn_player():
	dead_player.health = Global.player_max_health
	print(dead_player.health)
	add_child(dead_player)

func _on_respawn_timer_timeout():
	respawn_player()
