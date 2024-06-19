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
				target.take_damage(bomb_damage, player_history)
	super.delete()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
#


