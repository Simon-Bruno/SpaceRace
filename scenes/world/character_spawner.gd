extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		Network.player_added.connect(add_player_character)
		var world = preload("res://scenes/world/worldGeneration.tscn").instantiate()
		add_child(world)
		world.name = "world"

func add_player_character(id):
	var character = preload("res://scenes/player/player.tscn").instantiate()
	character.name = str(id)
	add_child(character)
	
	#TODO: Remove hardcode enemy
	var enemy = preload("res://scenes/enemy/enemy.tscn").instantiate()
	enemy.position = Vector3(2,20,4)
	add_child(enemy, true)
	
	var button = preload("res://scenes/interactables/button.tscn").instantiate()
	button.position = Vector3(3,1,10)
	add_child(button, true)
	
	var item = preload("res://scenes/interactables/moveable_items.tscn").instantiate()
	item.position = Vector3(5,1.5,5)
	add_child(item,true)
