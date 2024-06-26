extends Node

var loaded_item = preload("res://scenes/item/item.tscn")
@onready var pause_menu = $PauseMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	if multiplayer.is_server():
		var world = preload("res://scenes/world/worldGeneration.tscn").instantiate()
		world.name = "world"
		add_child(world)
		# Spawn all connected player nodes
		for id in Network.player_names.keys():
			$PlayerSpawner.add_player_character(id)

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		pause_menu.handle_esc_input()
