extends "res://scripts/item/item.gd"

@onready var timer = $PotionTimer
var strength_boost = 2
var player : Node3D = null


# Called when the player actually uses the item by pressing KEY 'Q'
func use():
	# Start timer for potion effect
	timer.start() 
	player = owned_node
	if player:
		player.strength = strength_boost
		print("Strength taken ", player.strength)


func _on_potion_timer_timeout():
	if player:
		# Reset the strength to 1.0
		player.strength = 1.0
		print("Strength reset ", player.strength)
		player = null
	super.delete()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	super._process(delta)


