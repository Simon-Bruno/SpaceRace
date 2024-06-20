extends Node


func add_player_character(id):
	var character = preload("res://scenes/player/player.tscn").instantiate()
	character.add_to_group("Players")
	character.name = str(id)
	add_child(character)


var dead_player = null
func player_died(player_to_die):
	player_to_die.alive = false
	player_to_die.visible = false
	player_to_die.global_position.y += 200
	player_to_die.fall_acceleration = 0
	$RespawnTimer.start()
	dead_player = player_to_die

func respawn_player():
	var player = dead_player
	player.health = Global.player_max_health
	player.get_node("PlayerCombat/SubViewport/HpBar").value = Global.player_max_health
	player.alive = true
	player.visible = true
	player.global_position.y -= 200
	player.fall_acceleration = 50
	player.get_node("./PlayerCombat/RespawnImmunity").start()

func _on_respawn_timer_timeout():
	respawn_player()
