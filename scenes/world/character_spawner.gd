extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	print("test")
	Network.player_added.connect(add_player_character)

func add_player_character(id):
	print("Added")
	var character = preload("res://scenes/player/player.tscn").instantiate()
	var camera = preload("res://scenes/camera.tscn").instantiate()
	character.add_child(camera)
	character.position += Vector3(0, 10, 0)
	character.name = str(id)
	add_child(character)
