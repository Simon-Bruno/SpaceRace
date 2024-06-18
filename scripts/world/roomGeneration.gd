extends Node3D

@onready var world = get_parent()

enum {HORIZONTAL, VERTICAL}

var parser = preload("res://scripts/world/rms_parser.gd").new()

var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
var laser_scene = preload("res://scenes/interactables/laser.tscn")
var key_scene = preload("res://scenes/item/key.tscn")
var bomb_scene = preload("res://scenes/item/bomb.tscn")
var hp_bottle_scene = preload("res://scenes/item/hp_bottle.tscn")
var box_scene = preload("res://scenes/interactables/moveable_object.tscn")
var button_scene = preload("res://scenes/interactables/button.tscn")
var pressure_plate_scene = preload("res://scenes/interactables/pressure_plate.tscn")
var door_scene = preload("res://scenes/interactables/door.tscn")
var wall_scene = preload("res://scenes/world/intern_wall.tscn")

func _ready():
	if world.generate_room:
		var start : Vector3i = world.start_pos
		var filename = "res://files/random_map_scripts/test.rms"
		var world_dict : Dictionary = parser.parse_file(filename)
		fill_room(world_dict, start)
		
func place_wall(x: int, z: int, i: int, orientation: int):
	var wall_block = wall_scene.instantiate()
	if orientation == HORIZONTAL:
		wall_block.position = Vector3i(x + i, 3, z)
	else:
		wall_block.position = Vector3i(x, 3, z + i)
	add_child(wall_block, true)

func add_walls(wall_list : Array, width : int, height : int, start : Vector3i):
	for wall in wall_list:
		var min_dist : int  = wall['set_min_distance']
		var max_dist : int = wall['set_max_distance']
		var length : int = wall['length']
		var variation : int = wall['length_variation']
		length += randi_range(-variation, variation)
		var orientation = randi() % 2
		var x : int = 0
		var z : int = 0
		if orientation == HORIZONTAL and width > length:
			x = randi_range(max(length / 2, start[0] + min_dist), min(width * 2 - length / 2, start[0] + max_dist))
			z = randi_range(max(2, start[2] + min_dist), min(height * 2 - 2, start[2] + max_dist))
		else:
			var xmin = max(2, start[0] - min_dist)
			var xmax = min(width * 2 - 2, start[0] + max_dist)
			var ymin = max(length / 2, start[2] - min_dist)
			var ymax = min(height * 2 - length / 2, start[2] + max_dist)
			x = randi_range(xmin, xmax)
			z = randi_range(ymin, ymax)
			orientation = VERTICAL
		for i in range(-length / 2, length / 2):
			place_wall(x, z, i, orientation)
		if length / 2 == 0:
			place_wall(x, z, 0, orientation)


func add_objects(objects_list):
	pass
	

func fill_room(world_dict: Dictionary, start : Vector3i):
	var room = world.room
	GlobalSpawner.spawn_melee_enemy(
		Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(5, 30), randi_range(1, room[1] * 2 - 1)))

	var laser = laser_scene.instantiate()
	laser.position = Vector3i(2, 3, 5)
	add_child(laser, true)
	
	var key = key_scene.instantiate()
	key.position = Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(3, 10), randi_range(1, room[1] * 2 - 1))
	add_child(key, true)
	
	
	var bomb = bomb_scene.instantiate()
	bomb.position = Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(3, 10), randi_range(1, room[1] * 2 - 1))
	add_child(bomb, true)
	
	var hp_bottle = hp_bottle_scene.instantiate()
	hp_bottle.position = Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(3, 10), randi_range(1, room[1] * 2 - 1))
	add_child(hp_bottle, true)
	
	var box = box_scene.instantiate()
	box.position = Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(3, 10), randi_range(1, room[1] * 2 - 1))
	add_child(box, true)
	
	var width : int = room[0]
	var height : int = room[1]
	add_walls(world_dict['walls'], width, height, start)
	
	var door = door_scene.instantiate()
	door.position = Vector3i(randi_range(1, room[0] * 2 - 1), 2, randi_range(1, room[1] * 2 - 1))
	add_child(door, true)
	door.activation_count = 2
	
	var button = button_scene.instantiate()
	button.position = Vector3i(randi_range(1, room[0] * 2 - 1), 2, randi_range(1, room[1] * 2 - 1))
	add_child(button, true)
	button.interactable = door
	
	var button2 = button_scene.instantiate()
	button2.position = Vector3i(randi_range(1, room[0] * 2 - 1), 2, randi_range(1, room[1] * 2 - 1))
	add_child(button2, true)
	button2.interactable = door
