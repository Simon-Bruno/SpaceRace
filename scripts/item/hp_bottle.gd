extends "res://scripts/item/item.gd"

# This code is used to increase the health of player by a certain value.

# Health increase
var health_potion_value = 30


# Called when the player actually uses the item by pressing KEY 'Q'
func use():
	var player = Network.get_player_node_by_id(owned_id)
	if player:
		player.rpc("increase_health", health_potion_value)
	super.consume_item()
