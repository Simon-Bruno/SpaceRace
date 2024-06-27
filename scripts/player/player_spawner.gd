extends Node

func add_player_character(id):
	var character = preload("res://scenes/player/player.tscn").instantiate()
	character.add_to_group("Players")
	character.name = str(id)
	add_child(character)

var dead_player_y_value: int = 0
var dead_player = null
var fall_acceleration = 0

func player_died(player_to_die):
	player_to_die.alive = false
	player_to_die.visible = false
	dead_player_y_value = player_to_die.global_position.y
	player_to_die.global_position.y += 200
	fall_acceleration = player_to_die.fall_acceleration	
	player_to_die.fall_acceleration = 0
	$RespawnTimer.start()
	dead_player = player_to_die

func respawn_player():
	var player = dead_player
	player.health = Global.player_max_health
	player.get_node("PlayerCombat/SubViewport/HpBar").value = Global.player_max_health
	player.alive = true
	player.visible = true
	if dead_player_y_value != 0:
		player.global_position.y = dead_player_y_value + 1
	#player.global_position.y -= 199
	player.fall_acceleration = fall_acceleration
	player.get_node("./PlayerCombat/RespawnImmunity").start()
	player.respawn_immunity = true

func _on_respawn_timer_timeout():
	respawn_player()
