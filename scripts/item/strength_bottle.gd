extends "res://scripts/item/item.gd"


var strength_boost = 2
var duration = 10


# Called when the player actually uses the item by pressing KEY 'Q'
func use():
	var player = owned_node
	var timer = player.get_node("StrengthTimer")
	timer.start(duration) # Start timer for potion effect
	if player:
		player.strength = strength_boost
	print("Strength ", player.strength)
	super.delete()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)


