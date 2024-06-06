extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	Network.player_added.connect(add_player_character)

func add_player_character(id):
	var character = preload("res://scenes/player/player.tscn").instantiate()
	character.name = str(id)
	add_child(character)
	
	#TODO: Remove hardcode enemy
	var enemy = preload("res://scenes/enemy/enemy.tscn").instantiate()
	enemy.position = Vector3(2,20,4)
	add_child(enemy)
	
