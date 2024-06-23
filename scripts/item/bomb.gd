extends "res://scripts/item/item.gd"


@onready var timer = $FuseTimer
var bomb_damage = 50
var player_history : Node3D = null


func use():
	# Start timer after pressing "Q" when holding the bomb item
	timer.start()
	player_history = owned_node


# The bomb will explode after three seconds
func _on_fuse_timer_timeout():
	var blast_radius = $RigidBody3D/Radius
	# Loop over the bodies that are within the blast radius and give damage
	for target in blast_radius.get_overlapping_bodies():
		if target.has_method("take_damage"):
			if target.is_in_group("Players"):
				# id, damage
				target.take_damage(target.name, bomb_damage)
			elif target.is_in_group("Enemies") or target.is_in_group("Boss"):
				# damage, source
				print("Enemy")
				# TODO: Error when enemy gets hit by bomb; in enemy.gd, see below
				# line 126 -> var knockback_direction = (global_transform.origin - player_pos).normalized()
				# Don't know if it also happens with the boss, isn't tested yet				
				#target.take_damage(bomb_damage, player_history)
	super.delete()
	
@rpc("any_peer", "call_local", "reliable")
func _bomb_explode():
	pass
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
#


