extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		var world = preload("res://scenes/world/worldGeneration.tscn").instantiate()
		world.name = "world"
		add_child(world)
		# Spawn all connected player nodes
		for id in Network.player_names.keys():
			$PlayerSpawner.add_player_character(id)
