extends Node3D

# the target that is in the laser
var target = null

var damage = 10
var damage_delay = 0.2 # dmg delay in seconds
var damage_time = damage_delay # keep track of time, first dmg tick should be instant

func _on_area_3d_body_entered(body):
	if body.is_in_group("Players"):
		target = body

func _on_area_3d_body_exited(body):
	if body.is_in_group("Players"):	
		target = null
		# make sure first tick always does dmg
		damage_time = damage_delay

func _process(delta):
	if target:
		damage_time += delta
		while damage_time > damage_delay:
			damage_time -= damage_delay
			target.take_damage(damage)
		
