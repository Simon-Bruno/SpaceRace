extends "res://scripts/item/item.gd"

@onready var timer = $FuseTimer
@onready var blast_radius_visual = $RigidBody3D/Radius/VisualBlastRadius

var bomb_damage = 50 # The amount of dmg the bomb should deal

# What vertical velocity should be applied when throwing the bomb. This value
# should be quite high due to invisible walls.
var vel_y = 10
var vel_multiplier = 1.8 # Bomb speed is calculated according to player speed and the multiplier

func use():
	var player = Network.get_player_node_by_id(owned_id)
	# Make the player drop the item first
	player.get_node("PlayerItem")._drop_item()

	# Call all clients to displayed the blast radius
	_ignite.rpc()

	# Set timer if not it's not running to prevent resetting the timer
	# when the item is picked up again after ignition
	if timer.is_stopped():
		timer.start()

	# Set bomb velocity
	var v = player.velocity
	v.y = vel_y # Apply standard vertical velocity since the bomb should arc upwards
	v *= vel_multiplier
	# Apply the velocity on all clients to aid synchronization
	_set_velocity_on_object.rpc($RigidBody3D.get_path(), v)

# Apply velocity on an object
@rpc("any_peer", "call_local", "reliable")
func _set_velocity_on_object(path, v):
	get_node(path).set_axis_velocity(v)

# Displays the blast radius using a red sphere
@rpc("any_peer", "call_local", "reliable")
func _ignite():
	blast_radius_visual.visible = true

# Is called when the bomb timer runs out, applying damage to every entity near.
@rpc("any_peer", "call_local", "reliable")
func _bomb_explode():
	var player = Network.get_player_node_by_id(owned_id)
	var blast_radius = $RigidBody3D/Radius

	# Loop over the bodies that are within the blast radius and give damage,
	# applying specific parameters to specific entities
	for target in blast_radius.get_overlapping_bodies():
		if target.has_method("take_damage"):
			if target.is_in_group("Players"):
				target.take_damage.rpc(target.name, bomb_damage)
			elif target.is_in_group("Enemies"):
				if player:
					target.take_damage.rpc(bomb_damage, player.global_transform.origin)
			elif target.is_in_group("Boss"):
				target.take_damage.rpc(bomb_damage, player.global_transform.origin)

	# Delete the item from the scene
	super.delete()

# The bomb will explode after three seconds
func _on_fuse_timer_timeout():
	_bomb_explode.rpc()
	blast_radius_visual.visible = false

func _process(delta):
	super._process(delta)
