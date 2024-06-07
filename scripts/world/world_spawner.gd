extends Node3D


func _ready():
	if multiplayer.is_server():
		var world = preload("res://scenes/world/worldGeneration.tscn").instantiate()
		add_child(world)
		world.name = "world"
		
		#TODO: Remove hardcode enemy
		var enemy = preload("res://scenes/enemy/enemy.tscn").instantiate()
		enemy.position = Vector3(2,20,4)
		add_child(enemy, true)
		Network.player_added.connect(add_player_character)


func add_player_character(id):
	var character = preload("res://scenes/player/player.tscn").instantiate()
	character.name = str(id)
	add_child(character)

