extends "res://scripts/item/item.gd"

var speed_boost = 1.5 # Player walk speed multiplier
var duration = 10 # Duration in seconds

# Called when the player actually uses the item by pressing the use key
# Sets the speed of the player to 1.5 its normal speed for 10 seconds.
func use():
	var player = Network.get_player_node_by_id(owned_id)
	var node = player.get_node("PlayerEffects")

	var timer = node.get_node("SpeedTimer")
	timer.start(duration)

	if player:
		player.speed_boost = speed_boost

	# Remove the item
	super.consume_item()
