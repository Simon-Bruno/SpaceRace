extends "res://scripts/item/item.gd"

@onready var timer = $PotionTimer
var strength_boost = 2
var duration = 5
var player : Node3D = null


func _on_ready():
	timer.timeout.connect(_on_potion_timer_timeout)


# Called when the player actually uses the item by pressing KEY 'Q'
func use():
	# Start timer for potion effect
	timer.start(duration) 
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


