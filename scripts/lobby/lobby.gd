extends Node

var world = preload("res://scenes/world.tscn")

func _ready():
	if multiplayer.is_server():
		Network.player_added.connect(add_player_character)

func _process(_delta):
	if Input.is_action_just_pressed("attack"):
		_on_game_start()

func add_player_character(id):
	var character = preload("res://scenes/player/player.tscn").instantiate()
	character.name = str(id)
	add_child(character)

# Called when the node enters the scene tree for the first time.
func _on_game_start():
	get_node("/root/Main").add_child(world.instantiate())
	queue_free()
