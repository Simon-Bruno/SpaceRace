extends "res://scripts/item/item.gd"

@onready var timer = $FuseTimer
@onready var blast_radius_visual = $RigidBody3D/Radius/VisualBlastRadius

var bomb_damage = 50


func _on_ready():
	# Hide the blast radius in the beginning
	blast_radius_visual.visible = false


func use():
	# Start timer after pressing "Q" when holding the bomb item
	timer.start()
	# When bomb is used, show the area that it will impact
	blast_radius_visual.visible = true


@rpc("any_peer", "call_local", "reliable")
func _bomb_explode():
	var player = Network.get_player_node_by_id(owned_id)
	var blast_radius = $RigidBody3D/Radius
	# Loop over the bodies that are within the blast radius and give damage
	for target in blast_radius.get_overlapping_bodies():
		if target.has_method("take_damage"):
			if target.is_in_group("Players"):
				# id, damage
				target.take_damage(target.name, bomb_damage)
			elif target.is_in_group("Enemies"):
				# damage, player position
				if player:
					target.take_damage(bomb_damage, player.global_transform.origin)
				else:
					print("Error: player is null during explosion")
			#elif target.is_in_group("Boss"):
				# TODO: Doesn't work for now, since the boss isn't available for testing yet
				#target.take_damage(bomb_damage, player.global_transform.origin)		
	super.delete()


# The bomb will explode after three seconds
func _on_fuse_timer_timeout():
	_bomb_explode.rpc()
	blast_radius_visual.visible = false
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
#


