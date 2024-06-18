extends "res://scripts/item/item.gd"

func use():
	var player = owned_node
	print(player)
	
	super.delete()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)
