extends Node3D

@onready var world = get_parent()

enum {HORIZONTAL, VERTICAL}

var parser = preload("res://scripts/world/rms_parser.gd").new()

var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
var laser_scene = preload("res://scenes/interactables/laser.tscn")
var item_scene = preload("res://scenes/item/item.tscn")
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

func wall_check_vertical(floor_plan : Array, x : int, z : int, max_x : int, orientation):
	if x > 0 and floor_plan[x - 1][z + 2 * orientation]:
		return false
	if floor_plan[x][z + 2 * orientation]:
		return false
	if x + 1 < max_x and floor_plan[x + 1][z + 2 * orientation]:
		return false
	return true


func wall_check_horizontal(floor_plan : Array, x : int, z : int, max_z : int, orientation : int):
	if z > 0 and floor_plan[x + 2 * orientation][z - 1]:
		return false
	if floor_plan[x + 2 * orientation][z]:
		return false
	if z + 1 < max_z and floor_plan[x + 2 * orientation][z + 1]:
		return false
	return true


func check_wall_placement(floor_plan: Array, x: int, z: int):
	var max_x : int = floor_plan.size()
	var max_z : int = floor_plan[0].size()
	if x < 0 or x >= max_x:
		return false
	if z < 0 or z >= max_z:
		return false
	if z > 1 and not floor_plan[x][z - 1]:
		if not wall_check_vertical(floor_plan, x, z, max_x, max_z, -1):
			return false
	if x > 1 and not floor_plan[x-1][z]:
		if not wall_check_horizontal(floor_plan, x, z, max_z, -1):
			return false
	if x + 2 < max_x and not floor_plan[x + 1][z]:
		if not wall_check_horizontal(floor_plan, x, z, max_z, 1):
			return false
	if z + 2 < max_z and not floor_plan[x][z + 1]:
		if not wall_check_vertical(floor_plan, x, z, max_x, max_z, 1):
			return false
	return true

func place_wall(x: int, z: int, i: int, orientation: int, floor_plan: Array):
	var wall_block = wall_scene.instantiate()
	var new_x = x
	var new_z = z
	if orientation == HORIZONTAL:
		new_x += i
	else:
		new_z += i
	if not check_wall_placement(floor_plan, new_x - 1, new_z - 1):
		return
	wall_block.position = Vector3i(new_x, 3, new_z)
	floor_plan[new_x - 1][new_z - 1] = 1
	add_child(wall_block, true)

func add_walls(wall_list : Array, width : int, height : int, start : Vector3i):
	var floor_plan : Array[Array] = []
	for i in width * 2:
		var row : Array = []
		for j in height * 2:
			row.append(0)
		floor_plan.append(row)
	for wall in wall_list:
		var min_dist : int  = wall['set_min_distance']
		var max_dist : int = wall['set_max_distance']
		var length : int = wall['length']
		var variation : int = wall['length_variation']
		length += randi_range(-variation, variation)
		var orientation = randi() % 2
		var x : int = 0
		var z : int = 0
		var xmin : int = 0
		var xmax : int = 0
		var zmin : int = 0
		var zmax : int = 0
		if orientation == HORIZONTAL and width > length:
			zmin = max(1, start[2] - max_dist)
			zmax = min(height * 2 - 2, start[2] + max_dist)
			z = randi_range(zmin, zmax)
			if abs(start[2] - z) >= min_dist:
				xmin = length / 2
			else:
				xmin = start[0] + min_dist
			xmax = min(width * 2 - length / 2 - 2, start[0] + max_dist)
			x = randi_range(xmin, xmax)
		elif height > length:
			zmin = max(length / 2, start[2] - max_dist)
			zmax = min(height * 2 - length / 2, start[2] + max_dist)
			z = randi_range(zmin, zmax)
			if abs(start[2] - z) >= min_dist:
				xmin = 1
			else:
				xmin = start[0] + min_dist
			xmax = min(width * 2 - 2, start[0] + max_dist)
			x = randi_range(xmin, xmax)
		else:
			continue
		for i in range(-length / 2, length / 2):
			place_wall(x, z, i, orientation, floor_plan)
		# If length / 2 == 0, the upper loop places nothing.
		if length / 2 == 0:
			place_wall(x, z, 0, orientation, floor_plan)


func add_objects(objects_list):
	pass


func fill_room(world_dict: Dictionary, start : Vector3i):
	var room = world.room
	var width : int = room[0]
	var height : int = room[1]
	add_walls(world_dict['walls'], width, height, start)
	
	var door = door_scene.instantiate()
	door.position = Vector3i(randi_range(1, room[0] * 2 - 1), 2, randi_range(1, room[1] * 2 - 1))
	add_child(door)
	door.activation_count = 2
	
	var button = button_scene.instantiate()
	button.position = Vector3i(randi_range(1, room[0] * 2 - 1), 2, randi_range(1, room[1] * 2 - 1))
	add_child(button)
	button.interactable = door
	
	var button2 = button_scene.instantiate()
	button2.position = Vector3i(randi_range(1, room[0] * 2 - 1), 2, randi_range(1, room[1] * 2 - 1))
	add_child(button2)
	button2.interactable = door

#func _process(delta):
	#pass
