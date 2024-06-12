extends Node3D

# the player that is in the laser
var player = null

var damage = 10
var damage_delay = 0.2 # dmg delay in seconds
var damage_time = damage_delay # keep track of time, first dmg tick should be instant

func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		if body.is_in_group("Players"):
			player = body

func _on_area_3d_body_exited(body):
	if body is CharacterBody3D:
		player = null
		damage_time = damage_delay

func _process(delta):
	if player:
		damage_time += delta
		while damage_time > damage_delay:
			print(player)
			damage_time -= damage_delay
			player.take_damage(player.name, damage)
		
