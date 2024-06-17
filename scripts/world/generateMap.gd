extends GridMap

enum {FLOOR1, FLOOR2, FLOOR3, FLOOR4, FLOOR5, FLOORVENT, FLOORWATER, DOORCLOSEDL, DOORCLOSEDR, DOOROPENL, 
	  DOOROPENR, WALL, WALLBUTTON, WALLCORNER, WALLDESK, WALLFAN, WALLFUSE, WALLLIGHT, WALLSWITCHOFF,
	  WALLSWITCHON, WALLTERMINAL, WINDOWL, WINDOWR, CUSTOMEND, CUSTOMSTART, LARGEBOX, REDBOX, 
	  SMALLBOX, PRESSUREPLATEOFF, PRESSUREPLATEON, TERMINAL, COMPUTER}

# The room types.
enum {CUSTOM, STARTROOM, ENDROOM, TYPE1, TYPE2, TYPE3, TYPE4, TYPE5}

@onready var customRooms : GridMap = get_node("../CustomRooms")

var boss_spawned = false # Currently for debugging purposesd
# At what y level is the floor
const HEIGHT : int = 0
const ROTATIONS : Array = [0, 16, 10, 22]

# Defines what blocks are associated together.
const PAIRS : Dictionary = {DOOROPENL: DOOROPENR, DOOROPENR: DOOROPENL, DOORCLOSEDL: DOORCLOSEDR, 
							DOORCLOSEDR:DOORCLOSEDL, WINDOWR: WINDOWL, WINDOWL: WINDOWR}

# What percentage of the rooms should be custom.
const CUSTOMROOMPERCENTAGE : float = 1

# General room parameters
const room_amount : int = 5
const room_width  : int = 10
const room_height : int = 10
const room_margin : int = 4

# How much the room size can variate in incraments of 2. e.g 10 with variation 1
# can return 8, 10, or 12.
var room_variation_x : int = 1
var room_variation_y : int = 1


# Stores the locations of the rooms. Each entry is: [width, height, startX]
@export var rooms : Array = []
@export var roomTypes : Array = []
@export var room : Array = []

# Stores game seed, which will be randomized at start of game, can be set to 
# a custom value useing set_seed()
@export var game_seed : int = 0

@export var start_pos : Vector3i = Vector3i(0, 0, 0)
@export var generate_room : bool = true

var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
var laser_scene = preload("res://scenes/interactables/laser.tscn")
var item_scene = preload("res://scenes/item/item.tscn")
var box_scene = preload("res://scenes/interactables/moveable_object.tscn")
var button_scene = preload("res://scenes/interactables/button.tscn")
var pressure_plate_scene = preload("res://scenes/interactables/pressure_plate.tscn")
var door_scene = preload("res://scenes/interactables/door.tscn")

# Called when the object is created in the scene
func _enter_tree():
	if multiplayer.is_server():
		$"../MultiplayerSynchronizer".set_multiplayer_authority(multiplayer.get_unique_id())


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if game_seed == 0:
		new_seed()
		build_map()
	else:
		set_seed(game_seed)


# Generates a news seed that is stored in the game_seed variable.
func new_seed() -> void:
	randomize()
	var random_seed = randi()
	seed(random_seed)	
	game_seed = random_seed


# Sets seed, and builds a new map based on that seed.
func set_seed(given_seed : int) -> void:
	seed(given_seed)
	build_map()


# Main function that builds the map. Clears the map first to stop overlap.
# TODO: Expand with all generation layers.
func build_map() -> void:
	self.clear()
	
	define_rooms()
	var pairs : Array = get_custom_rooms()
	
	draw_rooms()
	place_custom_room(pairs)
	draw_paths()
	
	draw_windows()
	draw_walls()
	
	#print(roomTypes)
	mirror_world()


# Randomly picks n unique indexes.
func random_picks(total_picks : int, min_value : int, max_value : int) -> Array:
	var all_options = []
	for i in range(min_value, max_value):
		all_options.append(i)

	var picks = []
	for i in total_picks:
		picks.append(all_options.pop_at(randi_range(0, all_options.size() - 1)))

	return picks


# Forces room margins.
func reset_room_spacing() -> void:
	for i in range(1, room_amount):
		rooms[i][2] = rooms[i - 1][0] + rooms[i - 1][2] + room_margin


# Randomly picks some rooms and corresponding custom rooms, edits the floorplan
# and returns an array containing the pairs [original, new].
# TODO: Breaks room margins a bit, might need to be changed.
func get_custom_rooms() -> Array:
	customRooms.generate_dimensions( )
	var total_picks = int(min((room_amount - 2) * CUSTOMROOMPERCENTAGE, customRooms.rooms.size()))
	
	var originals = random_picks(total_picks, 1, room_amount - 1)
	var customs = random_picks(total_picks, 0, customRooms.rooms.size())
	
	# Creates index pairs between the generated floorplan and the custom floorplan.
	var pairs = []
	for i in total_picks:
		pairs.append([originals[i], customs[i]])

	for i in pairs:
		rooms[i[0]][0] = customRooms.rooms[i[1]][0]
		rooms[i[0]][1] = customRooms.rooms[i[1]][1]
		roomTypes[i[0]] = CUSTOM

	reset_room_spacing()

	return pairs

func place_item(scene, orientation, location):
	var item = scene.instantiate()
	item.position = location
	item.scale = Vector3i(1.5, 1.5, 1.5)
	item.rotation = Vector3i(0, orientation, 0)
	add_child(item, true)
	return item

func locate_items(item, orientation, x, y, z, ori_start):
	var location = 2*(Vector3i(x, y, z) + Vector3i(ori_start, 0, 0))
	if item == WALLSWITCHOFF:
		item = place_item(button_scene, orientation, location)
		#item.inverse = true
		#item.interactable = door
	elif item == WALLSWITCHON:
		item = place_item(button_scene, orientation, location)
		#item.interactable = door
	elif item == PRESSUREPLATEOFF:
		item = place_item(pressure_plate_scene, orientation, location)
		#item.interactable = door
	#elif item == DOOROPENL:
		#print('door left', item, Vector3i(x,y,z), Vector3i(x, y, z) + Vector3i(ori_start, 0, 0), orientation)
	#elif item == DOOROPENR:
		#print('door right', item, Vector3i(x,y,z), Vector3i(x, y, z) + Vector3i(ori_start, 0, 0), orientation)

	
# Function gets an Array containing the custom rooms that have been assigned, 
# and places their content on the correct location in the grid.
func place_custom_room(pairs : Array) -> void:
	var MAX_HEIGHT = 4

	for pair in pairs:
		var orig = rooms[pair[0]]
		var custom = customRooms.rooms[pair[1]]

		var ori_start = orig[2]
		var custom_start = custom[2]
		for y in range(1, MAX_HEIGHT):
			for x in orig[0]:
				for z in orig[1]:
					var item = customRooms.get_cell_item(Vector3i(x, y, z) + Vector3i(custom_start, 0, 0))
					var current = self.get_cell_item(Vector3i(x, y, z) + Vector3i(custom_start, 0, 0))
					var orientation = customRooms.get_cell_item_orientation(Vector3i(x, y, z) + Vector3i(custom_start, 0, 0))
					
					self.set_cell_item(Vector3i(x, y, z) + Vector3i(ori_start, 0, 0), item, orientation)
					locate_items(item, orientation, x, y, z, ori_start)

# Rotates function to new 
static func new_orientation(item : int, orientation : int) -> int:
	var new_rotation = []
	match item:
		WALLCORNER:
			new_rotation = [16, 0, 22, 10]
		_:
			new_rotation = [10, 16, 0, 22]

	return new_rotation[ROTATIONS.find(orientation)]


# Checks if item needs to be switched. For multi item tiles.
static func new_item(item : int) -> int:
	return PAIRS[item] if PAIRS.has(item) else item


# This function mirrors all item in the world and copies them to the -z axis.
# It checks if an item needs to be rotated and, in case of a multi-block item,
# if it needs to be swapped.
func mirror_world() -> void:
	for x in self.get_used_cells():
		var item = self.get_cell_item(x)
		var orientation = self.get_cell_item_orientation(x)

		orientation = new_orientation(item, orientation)
		item = new_item(item)

		var new_location = (x +  Vector3i(0, 0, 1)) * Vector3i(1, 1, -1)
		self.set_cell_item(new_location, item, orientation)


# Places a window on the given coords, except for when there already is an item.
func place_window(location : Vector3i) -> void:
	if get_cell_item(location) != -1 or get_cell_item(location + Vector3i(1, 0, 0)) != -1:
		return

	self.set_cell_item(location, WINDOWL)
	self.set_cell_item(location + Vector3i(1, 0, 0), WINDOWR)


# Draws windows with 2 normal walls in between and centers it on the middle of the wall.
# Only works on the connecting walls.
func draw_windows() -> void:
	for room in rooms:
		var start = room[2] + 1 if (room[0] / 2) % 2 == 0 else room[2] + 2

		place_window(Vector3i(start, 1, 0))
		while start < room[2] + room[0] - 4:
			start += 4
			place_window(Vector3i(start, 1, 0))


# Summs all x values in an array based on the rooms variable.
static func sumXValues(the_rooms : Array) -> int:
	if the_rooms.is_empty():
		return 0
	var sum = 0
	for i in the_rooms:
		sum += i[0]
	return sum


func pick_random_type() -> int:
	var types = [TYPE1, TYPE2, TYPE3, TYPE4, TYPE5]
	return types[randi() % types.size()]
	
# Builds the rooms e.g: width, height, startX
func define_rooms() -> void:
	var xMax = room_width + room_variation_x
	var xMin = room_width - room_variation_x
	
	var yMax = room_width + room_variation_y
	var yMin = room_width - room_variation_y
	
	for i in room_amount:
		var x = randi_range(xMin / 2, xMax / 2 + 1) * 2
		var y = randi_range(yMin / 2, yMax / 2 + 1) * 2
		var start = sumXValues(rooms) + room_margin * i
		
		rooms.append([x, y, start])
		roomTypes.append(pick_random_type())
	
	roomTypes[0] = STARTROOM
	roomTypes[room_amount - 1] = ENDROOM


# Draws the full floorplan by:
# 1. Place first room of x * z size.
# 2. Place a path between the first room and a random point at an x offset.
# 3. Place second room on same x-axis
func draw_rooms() -> void:
	for i in room_amount:
		room = rooms[i]

		make_room(room)
		fill_room(room)

		if i == room_amount - 1:
			break

		var zstart = randi_range(1, rooms[i][1] - 3)
		var zend = randi_range(1, rooms[i + 1][1] - 3)

		var xstart = rooms[i][2] + rooms[i][0] - 1
		var xend = rooms[i + 1][2]
		
		start_pos = Vector3i(1, 10, zend * 2)

		place_doors(Vector3i(xstart, HEIGHT, zstart), Vector3i(xend, HEIGHT, zend))



func fill_room(room_dim: Array) -> void:
	var room_scene = preload("res://scenes/world/roomGeneration.tscn").instantiate()
	room_scene.position = Vector3i(room_dim[2] * 2, 0, 0)
	add_child(room_scene, true)
	generate_room = not generate_room
	room_scene = room_scene.duplicate(7)
	room_scene.scale.z = -1
	add_child(room_scene, true)
	generate_room = not generate_room


# Places floor grid of x * z size based on room array
func make_room(room : Array) -> void:
	var start = Vector3i(room[2], 0, 0)
	for h in room[1]:
		for w in room[0]:
			self.set_cell_item(start + Vector3i(w, HEIGHT, h), FLOOR1)


# Sorts vectors on x axis.
func sort_vector(a : Vector3i, b : Vector3i):
	if a.x < b.x:
		return true
	return false


# Draws paths between the doors.
func draw_paths() -> void:
	var starts = self.get_used_cells_by_item(DOOROPENL)
	var ends = self.get_used_cells_by_item(DOOROPENR)
	
	starts.sort_custom(sort_vector)
	ends.sort_custom(sort_vector)

	for i in range(starts.size() - 1, -1, -1):
		if get_cell_item_orientation(starts[i]) != 22:
			starts.pop_at(i)
		if get_cell_item_orientation(ends[i]) != 16:
			ends.pop_at(i)

	for i in starts.size():
		make_path(starts[i] - Vector3i(0, 1, 0), ends[i] - Vector3i(0, 1, 0))


# Draws a 2 wide path between two given vectors, the given point will be the top
# of the path.
func make_path(start_location : Vector3i, end_location : Vector3i) -> void:
	var relative_distance = end_location - start_location
	var direction = 0 if relative_distance.z > 0 else 1

	var middle = (relative_distance.x - 1) / 2
	var opposite = relative_distance.x - middle
	
	var vertical_start_main = middle + direction - 1
	var vertical_start_secondary = middle - direction
	
	for i in vertical_start_main:
		self.set_cell_item(start_location + Vector3i(i + 1, HEIGHT, 1), FLOOR1)
		
	for i in vertical_start_secondary:
		self.set_cell_item(start_location + Vector3i(i + 1, HEIGHT, 0), FLOOR1)
		
	for i in opposite + direction - 1:
		self.set_cell_item(end_location - Vector3i(i + 1, HEIGHT, 0), FLOOR1)
		
	for i in opposite - direction:
		self.set_cell_item(end_location - Vector3i(i + 1, HEIGHT, -1), FLOOR1)
	
	for i in abs(relative_distance.z):
		i = i * (-1 if direction == 0 else 1)
		var offset = 2 if direction == 0 else 0
		self.set_cell_item(start_location - Vector3i(0, 0, i) + Vector3i(vertical_start_main + offset, 0, 0), FLOOR1)
		self.set_cell_item(start_location - Vector3i(0, 0, i) + Vector3i(vertical_start_main + 1, 0, 1), FLOOR1)


# Places doors on random begin and end spots to make it possible to generate the paths later.
func place_doors(start_location : Vector3i, end_location : Vector3i) -> void:
	self.set_cell_item(start_location + Vector3i(0, 1, 0), DOOROPENL, 22)
	self.set_cell_item(start_location + Vector3i(0, 1, 1), DOOROPENR, 22)
	self.set_cell_item(end_location + Vector3i(0, 1, 0), DOOROPENR, 16)
	self.set_cell_item(end_location + Vector3i(0, 1, 1), DOOROPENL, 16)

# Sums the integers in an array
func sum_array(array):
	var sum = 0
	for element in array:
		sum += element
	return sum


# Randomizes floor placement.
func random_floor(floor : Vector3i) -> void:
	var walls = [FLOOR1, FLOOR2, FLOOR3, FLOOR4, FLOOR5]
	var special = [FLOORVENT, FLOORWATER]
	
	var rotation = ROTATIONS[randi() % ROTATIONS.size()]

	if randi_range(1, 100) < 96:
		self.set_cell_item(floor, walls[randi() % walls.size()], rotation)
	else:
		self.set_cell_item(floor, special[randi() % special.size()], rotation)
		
func random_wall() -> int:
	var walls = [WALLDESK, WALLFAN, WALLFUSE, WALLLIGHT, WALLTERMINAL]
	
	if randi_range(1, 100) >= 96:
		return walls[randi() % walls.size()]
	return WALL


# Draws all walls by finding all floors and check if a wall needs to be added.
# It also randomised the floor grid.
func draw_walls() -> void:
	var neighbors = [Vector3i(0, 0, -1), Vector3i(1, 0, 0), Vector3i(0, 0, 1), Vector3i(-1, 0, 0)]
	
	# Defining the different floor layouts, and their corresponding orientation.
	var walls = [[0, 1, 1, 1], [1, 0, 1, 1], [1, 1, 0, 1], [1, 1, 1, 0]]
	var corner = [[0, 1, 1, 0], [0, 0, 1, 1], [1, 0, 0, 1], [1, 1, 0, 0]]
	var orientations = [0, 22, 10, 16]
	
	# Get all floors in grid.
	var floors = self.get_used_cells_by_item(FLOOR1)
	
	# Go trough all floor items, and check if wall is needed.
	for floor_item in floors:
		var surround = []
		for i in neighbors:
			var neighbor = floor_item + i
			surround.append((1 if self.get_cell_item(neighbor) != -1 else 0))

		random_floor(floor_item)

		var idx = -1
		var type = WALL
		
		# Checks which type of wall, then finds the needed orientation.
		if get_cell_item(floor_item + Vector3i(0, 1, 0)) != -1:
			idx = -1
		elif sum_array(surround) == 3:
			idx = walls.find(surround)
			# Get a random item to put on the wall
			type = random_wall()
		elif sum_array(surround) == 2:
			idx = corner.find(surround)
			type = WALLCORNER

		# If unknown orientation, skip.
		if idx == -1:
			continue

		# Place wall.
		var orientation = orientations[idx]
		self.set_cell_item(floor_item + Vector3i(0, 1, 0), type, orientation)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
