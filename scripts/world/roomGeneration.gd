extends Node3D

@onready var world = get_parent()

enum {HORIZONTAL, VERTICAL}

var parser = preload("res://scripts/world/rms_parser.gd").new()

var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
var laser_scene = preload("res://scenes/interactables/laser_beam.tscn")
var item_scene = preload("res://scenes/item/item.tscn")
var box_scene = preload("res://scenes/interactables/moveable_object.tscn")

func _ready():
	if world.generate_room:
		var filename = "res://files/random_map_scripts/test.rms"
		var world_dict : Dictionary = parser.parse_file(filename)
		fill_room(world_dict)

func add_walls(wall_list : Array, width : int, height : int, start : Vector3i):
	for wall in wall_list:
		var length : int = int(wall['length'])
		var variation : int = int(wall['length_variation'])
		length += randi_range(-variation, variation)
		var orientation = randi() % 2
		var x : int = 0
		var z : int = 0
		if orientation == HORIZONTAL and width > length:
			x = randi_range(length / 2, width * 2 - length / 2)
			z = randi_range(2, height * 2 - 2)
		else:
			x = randi_range(2, width * 2 - 2)
			z = randi_range(length / 2, height * 2 - length / 2)
			orientation = VERTICAL
		for i in range(-length / 2, length / 2):
			var wall_block = box_scene.instantiate()
			if orientation == HORIZONTAL:
				wall_block.position = Vector3i(x + i, 2, z)
			else:
				wall_block.position = Vector3i(x, 2, z + i)
			add_child(wall_block, true)
		
		
func add_objects(objects_list):
	pass
	

func fill_room(world_dict: Dictionary):
	var room = world.room
	var width : int = room[0]
	var height : int = room[1]
	add_walls(world_dict['walls'], width, height, Vector3i(1, 2, 1))
	
	#var enemy = enemy_scene.instantiate()
	#enemy.position = Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(5, 30), randi_range(1, room[1] * 2 - 1))
	#add_child(enemy, true)
	#
	#var laser = laser_scene.instantiate()
	#laser.position = Vector3i(2, 3, 5)
	#add_child(laser, true)
	#
	#var item = item_scene.instantiate()
	#item.position = Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(3, 10), randi_range(1, room[1] * 2 - 1))
	#add_child(item, true)
	#
	#var box = box_scene.instantiate()
	#box.position = Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(3, 10), randi_range(1, room[1] * 2 - 1))
	#add_child(box, true)

#func _process(delta):
	#pass
