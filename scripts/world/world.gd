extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		var world = preload("res://scenes/world/worldGeneration.tscn").instantiate()
		add_child(world)
		
	for id in Network.player_nodes:
		$PlayerSpawner.add_player_character(id)
	
