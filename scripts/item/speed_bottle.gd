extends "res://scripts/item/item.gd"


var speed_boost = 1.5
var duration = 10


# Called when the player actually uses the item by pressing KEY 'Q'
func use():
	var player = Network.get_player_node_by_id(owned_id)
	var node = player.get_node("PlayerEffects")
	var timer = node.get_node("SpeedTimer")
	timer.start(duration) # Start timer for potion effect
	if player:
		player.speed_boost = speed_boost
	super.consume_item()
