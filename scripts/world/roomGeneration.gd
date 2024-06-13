extends Node3D

@onready var world = get_parent()

enum {HORIZONTAL, VERTICAL}

enum {EMTPY, WALL, ITEM, LASER, ENEMY}

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

func wall_check(floor_plan: Array, x: int, z: int, max_x: int, max_z: int, orientation: int, is_vertical: bool) -> bool:
	if is_vertical:
		if x > 0 and floor_plan[x - 1][z + 2 * orientation]:
			return false
		if floor_plan[x][z + 2 * orientation]:
			return false
		if x + 1 < max_x and floor_plan[x + 1][z + 2 * orientation]:
			return false
	else:
		if z > 0 and floor_plan[x + 2 * orientation][z - 1]:
			return false
		if floor_plan[x + 2 * orientation][z]:
			return false
		if z + 1 < max_z and floor_plan[x + 2 * orientation][z + 1]:
			return false
	return true

func check_wall_placement(floor_plan: Array, x: int, z: int) -> bool:
	var max_x: int = floor_plan.size()
	var max_z: int = floor_plan[0].size()
	
	if x < 0 or x >= max_x or z < 0 or z >= max_z:
		return false

	if z > 1 and not floor_plan[x][z - 1]:
		if not wall_check(floor_plan, x, z, max_x, max_z, -1, true):
			return false
	if x > 1 and not floor_plan[x - 1][z]:
		if not wall_check(floor_plan, x, z, max_x, max_z, -1, false):
			return false
	if x + 2 < max_x and not floor_plan[x + 1][z]:
		if not wall_check(floor_plan, x, z, max_x, max_z, 1, false):
			return false
	if z + 2 < max_z and not floor_plan[x][z + 1]:
		if not wall_check(floor_plan, x, z, max_x, max_z, 1, true):
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
		return false
	wall_block.position = Vector3i(new_x, 3, new_z)
	floor_plan[new_x - 1][new_z - 1] = WALL
	add_child(wall_block, true)
	return true

func handle_wall(floor_plan : Array, wall : Dictionary, width : int, height: int, start : Vector3i):
	var placed : bool = false
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
		zmax = min(height - 2, start[2] + max_dist)
		z = randi_range(zmin, zmax)
		
		if abs(start[2] - z) >= min_dist:
			xmin = length / 2
		else:
			xmin = start[0] + min_dist
		
		xmax = min(width - length / 2 - 2, start[0] + max_dist)
	elif height > length:
		zmin = max(length / 2, start[2] - max_dist)
		zmax = min(height - length / 2, start[2] + max_dist)
		z = randi_range(zmin, zmax)
		
		if abs(start[2] - z) >= min_dist:
			xmin = 1
		else:
			xmin = start[0] + min_dist
		
		xmax = min(width - 2, start[0] + max_dist)
	else:
		return false
	x = randi_range(xmin, xmax)
	for i in range(-length / 2, length / 2):
		if place_wall(x, z, i, orientation, floor_plan):
			placed = true
	# If length / 2 == 0, the upper loop places nothing.
	if length / 2 == 0:
		if place_wall(x, z, 0, orientation, floor_plan):
			placed = true
	return placed

func add_walls(floor_plan : Array[Array], wall_list : Array, width : int, height : int, start : Vector3i) -> void:
	for wall in wall_list:
		if not handle_wall(floor_plan, wall, width, height, start):
			handle_wall(floor_plan, wall, width, height, start)

# This function takes the floor plan, an object and some parameters of the room
# and tries to fit the object in the room, while keeping the rules set in the
# object dictionary.
# If the object could be placed successfully, the floor plan will be updated
# and the function returns true. If the placement was unsuccessful, the floor
# plan will be unaltered and the function will return false.
func add_item(floor_plan : Array[Array], object : Dictionary, width: int, height : int, start : Vector3i) -> bool:
	var item = item_scene.instantiate()
	var min_dist : int = object['set_min_distance']
	var max_dist : int = object['set_max_distance']
	# Calculations to set the object between the minimum and maximum distance.
	# Distances are the Chebyshev distance, where distance between 2 points
	# is equal to the maximum of difference in x and y directions.
	var zmin = max(1, start[2] - max_dist)
	var zmax = min(height - 1, start[2] + max_dist)
	var z = randi_range(zmin, zmax)
	var xmin = 1
	var xmax = min(width - 1, start[0] + max_dist)
	if abs(start[2] - z) < min_dist:
		xmin = min(width - 1, start[0] + min_dist)
	var x = randi_range(xmin, xmax)
	# Check if there is not another object/wall already at that place.
	if floor_plan[x - 1][z - 1]:
		return false
	# Add the item and update the plan.
	floor_plan[x - 1][z - 1] = ITEM
	item.position = Vector3i(x, 3, z)
	add_child(item, true)
	return true

func add_objects(floor_plan : Array[Array], objects_list : Array, width : int, height: int, start: Vector3i):
	for object in objects_list:
		match object['type']:
			'ITEM':
				if not add_item(floor_plan, object, width, height, start):
					# If the placement was unsuccessful, try once more.
					add_item(floor_plan, object, width, height, start)
			_:
				print('The object is not an item')

# Generates a matrix of the size (width, height)
func generate_floor_plan(width : int, height : int) -> Array[Array]:
	var floor_plan : Array[Array] = []
	floor_plan.resize(width)
	for i in width:
		floor_plan[i].resize(height)
		for j in height:
			floor_plan[i][j] = 0
	return floor_plan

func fill_room(world_dict: Dictionary, start : Vector3i):
	var room = world.room
	var width : int = room[0] * 2
	var height : int = room[1] * 2
	var floor_plan : Array[Array] = generate_floor_plan(width, height)
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(5, 30), randi_range(1, room[1] * 2 - 1))
	add_child(enemy, true)
	var laser = laser_scene.instantiate()
	laser.position = Vector3i(2, 3, 5)
	add_child(laser, true)
	var box = box_scene.instantiate()
	box.position = Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(3, 10), randi_range(1, room[1] * 2 - 1))
	add_child(box, true)

	add_walls(floor_plan, world_dict['walls'], width, height, start)
	add_objects(floor_plan, world_dict['objects'], width, height, start)
	
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
