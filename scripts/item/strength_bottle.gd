extends "res://scripts/item/item.gd"

var strength_boost = 2 # Attacked dmg multiplier
var duration = 10 # Duration in seconds

# Called when the player actually uses the item by pressing the use key
# Sets the damage of a player to a factor of 2 for a duration of 10 seconds.
func use():
	var player = Network.get_player_node_by_id(owned_id)
	var node = player.get_node("PlayerEffects")

	var timer = node.get_node("StrengthTimer")
	timer.start(duration)

	if player:
		player.strength = strength_boost

	# Remove the item
	super.consume_item()

func _process(delta):
	super._process(delta)
