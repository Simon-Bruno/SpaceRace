extends "res://scripts/item/item.gd"

var health_potion_value = 30

# Called when the player actually uses the item by pressing KEY 'Q'
func use():
	var player = owned_node
	if player:
		print("create full health")
		player.full_health()
	super.delete()
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
