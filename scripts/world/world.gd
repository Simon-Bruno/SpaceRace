extends Node3D

var loaded_item = preload("res://scenes/item/item.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		var world = preload("res://scenes/world/worldGeneration.tscn").instantiate()
		world.name = "world"
		add_child(world)
		# Spawn all connected player nodes
		for id in Network.player_names.keys():
			$PlayerSpawner.add_player_character(id)

		#BUG: Item currently isnt synced and floods console with errors (whywhywhy)
		#TODO: Remove hardcode item
		var item = loaded_item.instantiate()
		item.position = Vector3(4,5,4)
		add_child(item, true)
