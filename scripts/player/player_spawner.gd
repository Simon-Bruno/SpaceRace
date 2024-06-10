extends Node3D


func add_player_character(id):
	var character = preload("res://scenes/player/player.tscn").instantiate()
	character.name = str(id)
	add_child(character)


var dead_player = null
func player_died(player_to_die):
	dead_player = player_to_die
	player_to_die.queue_free()
	$RespawnTimer.start()

func respawn_player():
	var player = dead_player.instantiate()
	player.health = Global.player_max_health
	print(player.health)
	add_child(player)

func _on_respawn_timer_timeout():
	respawn_player()
