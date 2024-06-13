extends Node3D

@onready var world = get_parent()

enum {HORIZONTAL, VERTICAL}

enum {EMTPY, WALL, ITEM, LASER, ENEMY}

var parser = preload("res://scripts/world/rms_parser.gd").new()

# Some constant scenes to load.
const enemy_scene = preload("res://scenes/enemy/enemy.tscn")
const laser_scene = preload("res://scenes/interactables/laser.tscn")
const item_scene = preload("res://scenes/item/item.tscn")
const box_scene = preload("res://scenes/interactables/moveable_object.tscn")
const button_scene = preload("res://scenes/interactables/button.tscn")
const pressure_plate_scene = preload("res://scenes/interactables/pressure_plate.tscn")
const door_scene = preload("res://scenes/interactables/door.tscn")
const wall_scene = preload("res://scenes/world/intern_wall.tscn")

func _ready():
	if world.generate_room:
		var start : Vector3i = world.start_pos
		var filename = "res://files/random_map_scripts/test.rms"
		var world_dict : Dictionary = parser.parse_file(filename)
		fill_room(world_dict, start)

# This function is a check for a range of 3 tiles on two tiles distance of the given
# (x, z) coordinates.
# A small sketch:
# . c c c .
# c . . . c
# c . x . c
# c . . . c
# . c c c .
# If the given x needs to be checked, if any c is a wall, the function will
# return false.
# The vertical flag checks the upper and lower row, while setting it to false
# means the function will check the two columns.
# Setting the orientation to 1, will mean the function will check the
# positive side of the given direction (lower row if vertical flag, right if
# the flag is not set), while setting the orientation to
# -1 will result in the function checking the negative side (upper with flag,
# left without).
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

# This function checks if the wall that gets placed at the given (x, z)
# coordinates can be safely placed. Part of this is the check if it's inside
# the room. Another part is the check if it does not create a corridor that is
# too small for the player to navigate. Only if all the checks are fine, does
# this function return true.
# This function does not check if there exists a route from start to finish.
func check_wall_placement(floor_plan: Array, x: int, z: int) -> bool:
	var max_x: int = floor_plan.size()
	var max_z: int = floor_plan[0].size()
	
	if x < 0 or x >= max_x or z < 0 or z >= max_z:
		return false

	if floor_plan[x][z]:
		return false

	# If there is a hole next to the coordinates, only place the wall if there
	# is no wall on two tiles distance, since the player can't pass then.
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

# This function is a helper function for the handle_wall function.
# This function actually tries to place the wall at the x(+ i), z( + i)
# coordinates and will update the floor plan if the wall can be placed.
# The exact location depends on the given i and the orientation.
# This check is done by check_wall_placement. If the wall was placed this
# function returns true, and false if the wall could not be placed.
func place_wall(x: int, z: int, i: int, orientation: int, floor_plan: Array) -> bool:
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

# This function will try to fit a wall on the floor plan given the restrictions
# of the wall dictionary, room size and start position.
# If the operation is successful, the floor plan will be updated, but if not
# a single tile of the wall can be placed, this function will not update the
# floor plan, and will return false.
func handle_wall(floor_plan : Array, wall : Dictionary, width : int, height: int, start : Vector3i) -> bool:
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
		orientation = VERTICAL
		
		xmax = min(width - 2, start[0] + max_dist)
	else:
		# The length is too large to fit horizontally or vertically, so cancel the operation.
		return false

	# Get a random x coordinate inside the bounds.
	x = randi_range(xmin, xmax)
	for i in range(-length / 2, length / 2):
		if place_wall(x, z, i, orientation, floor_plan):
			placed = true
	# If length / 2 == 0, the upper loop places nothing.
	if length / 2 == 0:
		if place_wall(x, z, 0, orientation, floor_plan):
			placed = true
	return placed

# This is a small function that relies on the helper functions to place the walls.
# If the first try of placing a wall fails, it will give a second try,
# but no more than 2.
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


func object_matcher(object : Dictionary, floor_plan : Array[Array], width : int, height : int, start: Vector3i) -> bool:
	match object['type']:
		'ITEM':
			return add_item(floor_plan, object, width, height, start)
		_:
			print('The object is not an item')
			return true

# This function will eventually handle all the object placements. Currently it
# only support items and it will handle objects that failed to place.
func add_objects(floor_plan : Array[Array], objects_list : Array, width : int, height: int, start: Vector3i):
	for object in objects_list:
		if not object_matcher(object, floor_plan, width, height, start):
			# Try again if failed the first time.
			object_matcher(object, floor_plan, width, height, start)

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
