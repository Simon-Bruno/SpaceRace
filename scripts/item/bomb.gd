extends "res://scripts/item/item.gd"

@onready var timer = $FuseTimer
@onready var blast_radius_visual = $RigidBody3D/Radius/VisualBlastRadius

var bomb_damage = 50

var vel_y = 10
var vel_multiplier = 1.8

func use():
	var player = Network.get_player_node_by_id(owned_id)
	player.get_node("PlayerItem")._drop_item()
	
	# Set blast animation
	_ignite.rpc()
	
	# Set timer if not running
	if timer.is_stopped():
		timer.start()

	var v = player.velocity
	v.y = vel_y
	v *= vel_multiplier
	_set_velocity_on_object.rpc($RigidBody3D.get_path(), v)
	
@rpc("any_peer", "call_local", "reliable")
func _set_velocity_on_object(path, v):
	get_node(path).set_axis_velocity(v)
	
@rpc("any_peer", "call_local", "reliable")
func _ignite():
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
				target.take_damage.rpc(target.name, bomb_damage)
			elif target.is_in_group("Enemies"):
				# damage, player position
				if player:
					target.take_damage.rpc(bomb_damage, player.global_transform.origin)
			elif target.is_in_group("Boss"):
				target.take_damage.rpc(bomb_damage, player.global_transform.origin)		
	super.delete()


# The bomb will explode after three seconds
func _on_fuse_timer_timeout():
	_bomb_explode.rpc()
	blast_radius_visual.visible = false
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
#


