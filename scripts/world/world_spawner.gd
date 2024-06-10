extends Node3D

var loaded_enemy = preload("res://scenes/enemy/enemy.tscn") 
var loaded_item = preload("res://scenes/item/item.tscn")


func _enter_tree():
	if multiplayer.is_server():
		$MultiplayerSpawner.set_multiplayer_authority(multiplayer.get_unique_id())

func _ready():
	if multiplayer.is_server():
		var world = preload("res://scenes/world/worldGeneration.tscn").instantiate()
		add_child(world)
		world.name = "world"
		
		for id in Network.player_names.keys():
			add_player_character(id)
			
		#TODO: Remove hardcode enemy
		var enemy = loaded_enemy.instantiate()
		enemy.position = Vector3(2,20,4)
		add_child(enemy, true)
		
		#BUG: Item currently isnt synced and floods console with errors (whywhywhy)
		#TODO: Remove hardcode item
		var item = loaded_item.instantiate()
		item.position = Vector3(4,5,4)
		add_child(item, true)


func add_player_character(id):
	var character = preload("res://scenes/player/player.tscn").instantiate()
	character.name = str(id)
	add_child(character)

