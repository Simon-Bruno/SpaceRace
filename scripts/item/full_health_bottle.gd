extends "res://scripts/item/item.gd"

# Called when the player actually uses the item by pressing KEY 'Q'
func use():
	var player = owned_node
	if player:
		player.full_health()
	super.consume_item()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
