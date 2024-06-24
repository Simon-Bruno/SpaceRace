extends GridMap

enum {FLOOR1, FLOOR2, FLOOR3, FLOOR4, FLOOR5, FLOORVENT, FLOORWATER, DOORCLOSEDL, DOORCLOSEDR, DOOROPENL,
	  DOOROPENR, WALL, WALLBUTTON, WALLCORNER, WALLDESK, WALLFAN, WALLFUSE, WALLLIGHT, WALLSWITCHOFF,
	  WALLSWITCHON, WALLTERMINAL, WINDOWL, WINDOWR, CUSTOMEND, CUSTOMSTART, LARGEBOX, REDBOX,
	  SMALLBOX, PRESSUREPLATEOFF, PRESSUREPLATEON, TERMINAL, COMPUTER, BUTTONBLUE, BUTTONGREEN,
	  BUTTONORANGE, BUTTONPURPLE, BUTTONRED, BUTTONYELLOW, DOORBLUE, DOORGREEN, DOORORANGE, DOORPURPLE,
	  DOORRED, DOORYELLOW, HOLEBLUE, HOLEGREEN, HOLEORANGE, HOLEPURPLE, HOLERED, HOLEYELLOW, KEYBLUE,
	  KEYGREEN, KEYORANGE, KEYPURPLE, KEYRED, KEYYELLOW, LASERBLUE, LASERGREEN, LASERORANGE, LASERPURPLE,
	  LASERRED, LASERYELLOW, PRESSUREMULTIBLUE, PRESSUREMULTIGREEN, PRESSUREMULTIORANGE, PRESSUREMULTIPURPLE,
	  PRESSUREMULTIRED, PRESSUREMULTIYELLOW, PRESSUREPLATEOFF2, PRESSUREPLATEON2, PRESSURESINGLEBLUE,
	  PRESSURESINGLEGREEN, PRESSURESINGLEORANGE, PRESSURESINGLEPURPLE, PRESSURESINGLERED, PRESSURESINGLEYELLOW,
	  SWITCHOFFBLUE, SWITCHOFFGREEN, SWITCHOFFORANGE, SWITCHOFFPURPLE, SWITCHOFFRED, SWITCHOFFYELLOW,
	  SWITCHONBLUE, SWITCHONGREEN, SWITCHONORANGE, SWITCHONPURPLE, SWITCHONRED, SWITCHONYELLOW, ENEMY,
	  RANGEDENEMY, WELDER, BOSS, SPAWNERMELEE, SPAWNERRANGED, LASERTIMER, TELEPORTER, KEYHOLEBLUE,
	  KEYHOLEGREEN, KEYHOLEORANGE, KEYHOLEPURPLE, KEYHOLERED, KEYHOLEYELLOW, TELEPORTERBLUE, TELEPORTERGREEN,
	  TELEPORTERORANGE, TELEPORTERPURPLE, TELEPORTERRED, TELEPORTERYELLOW, TERMINALBLUE, TERMINALGREEN,
	  TERMINALORANGE, TERMINALPURPLE, TERMINALRED, TERMINALYELLOW, BOSSBLUE, BOSSGREEN, BOSSORANGE,
	  BOSSPURPLE, BOSSRED, BOSSYELLOW, ENEMYBLUE, ENEMYGREEN, ENEMYORANGE, ENEMYPURPLE, ENEMYRED, ENEMYYELLOW,
	  ENEMYRANGEDBLUE, ENEMYRANGEDGREEN, ENEMYRANGEDORANGE, ENEMYRANGEDPURPLE, ENEMYRANGEDRED, EMPTY=-1}

# The room types.
enum {CUSTOM, STARTROOM, ENDROOM, TYPE1, TYPE2, TYPE3, TYPE4, TYPE5}

@onready var roomLink : Node = get_node("../roomLink")
@onready var entityGeneration : GridMap = get_node("../EntityGeneration")

# At what y level is the floor
const HEIGHT : int = 0
const ROTATIONS : Array = [0, 16, 10, 22]

# Defines what blocks are associated together.
const PAIRS : Dictionary = {DOOROPENL: DOOROPENR, DOOROPENR: DOOROPENL, DOORCLOSEDL: DOORCLOSEDR,
							DOORCLOSEDR:DOORCLOSEDL, WINDOWR: WINDOWL, WINDOWL: WINDOWR}

# What percentage of the rooms should be custom.
const CUSTOMROOMPERCENTAGE : float = 0.3

# General room parameters
const room_amount : int = 10
const room_width  : int = 10
const room_height : int = 8
const room_margin : int = 4

# How much the room size can variate in increments of 2. e.g 10 with variation 1
# can return 8, 10, or 12.
var room_variation_x : int = 1
var room_variation_y : int = 1


# Stores the locations of the rooms. Each entry is: [width, height, startX, leftDoor, rightDoor]
@export var rooms : Array = []
@export var roomTypes : Array = []
@export var room : Array = []

# Stores game seed, which will be randomized at start of game, can be set to
# a custom value useing set_seed()
@export var game_seed : int = 0

@export var start_pos : Vector3i = Vector3i(0, 0, 0)
@export var end_pos : Vector3i = Vector3i(0, 0, 0)
@export var generate_room : bool = true
@export var last_room : bool = false
@export var absolute_position : Vector3i = Vector3i(0, 3, 0)


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
	roomLink._ready()

	define_rooms()
	var pairs : Array = get_custom_rooms()
	draw_rooms()
	
	place_custom_room(pairs)
	add_finish()
	add_start()
	
	draw_paths()
	draw_windows()
	draw_walls()
	
	add_finish()
	mirror_world()

	convert_static_to_entities()


func add_start():
	write_room(rooms[0], 1, 0, true)
	write_room(rooms[0], 1, 1, true)


# Adds the pressureplate in the last room
func add_finish():
	write_room(rooms[-1], 0, 0, true)
	write_room(rooms[-1], 0, 1, true)

	var plate = preload("res://scenes/interactables/pressure_plate.tscn").instantiate()
	plate.position = map_to_local(Vector3i((start_pos[2]+18), 1, 0))
	plate.position.y = 2
	plate.is_finish_plate = true
	add_child(plate, true)


# Calls the convert functionality and removes all static items that have overlap.
func convert_static_to_entities() -> void:
	entityGeneration.replace_entities(rooms)


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
	var total_picks = int(min((room_amount - 2) * CUSTOMROOMPERCENTAGE, roomLink.total_rooms()))

	var originals = random_picks(total_picks, 1, room_amount - 1)
	var customs = random_picks(total_picks, 0, roomLink.total_rooms())

	# Creates index pairs between the generated floorplan and the custom floorplan.
	var pairs = []
	for i in total_picks:
		pairs.append([originals[i], customs[i]])

	for i in pairs:
		var customRoom = roomLink.get_room_size(i[1], false)
		rooms[i[0]][0] = customRoom[0]
		rooms[i[0]][1] = customRoom[1]
		roomTypes[i[0]] = CUSTOM

	var endroom = roomLink.get_room_size(0, true)
	rooms[-1][0] = endroom[0]
	rooms[-1][1] = endroom[1]
	roomTypes[-1] = CUSTOM
	
	var startroom = roomLink.get_room_size(1, true)
	rooms[0][0] = startroom[0]
	rooms[0][1] = startroom[1]
	roomTypes[0] = CUSTOM

	reset_room_spacing()

	return pairs


func place_item(scene, orientation, location):
	var item = scene.instantiate()
	item.position = location
	item.scale = Vector3i(1.5, 1.5, 1.5)
	item.rotation = Vector3i(0, orientation, 0)
	add_child(item, true)
	return item


func write_room(orig : Array, new : int, layer : int, special=false) -> void:
	for y in range(0, 3):
		for x in orig[0]:
			for z in orig[1]:
				var item = roomLink.get_room_item(Vector3i(x, y, z), new, layer, special)
				var orientation = roomLink.get_room_item_orientation(Vector3i(x, y, z), new, layer, special)

				if layer == 0:
					self.set_cell_item(Vector3i(x, y, z) + Vector3i(orig[2], 0, 0), item, orientation)
				else:
					entityGeneration.set_cell_item(Vector3i(x, y, z) + Vector3i(orig[2], 0, 0), item, orientation)


# Function gets an Array containing the custom rooms that have been assigned,
# and places their content on the correct location in the grid.
func place_custom_room(pairs : Array) -> void:
	for pair in pairs:
		var orig = rooms[pair[0]]
		write_room(orig, pair[1], 0)
		write_room(orig, pair[1], 1)


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

	for x in entityGeneration.get_used_cells():
		var item = entityGeneration.get_cell_item(x)
		var orientation = entityGeneration.get_cell_item_orientation(x)

		orientation = new_orientation(item, orientation)
		item = new_item(item)

		var new_location = (x +  Vector3i(0, 0, 1)) * Vector3i(1, 1, -1)
		entityGeneration.set_cell_item(new_location, item, orientation)


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
	var widthMax = room_width + room_variation_x
	var widthMin = room_width - room_variation_x

	#var heightMax = room_height + room_variation_y
	var heightMax = 8
	var heightMin = room_height - room_variation_y
	for i in room_amount:
		var width = randi_range(widthMin / 2, widthMax / 2 + 1) * 2
		var height = randi_range(heightMin / 2, ceil(heightMax / 2)) * 2
		var start = sumXValues(rooms) + room_margin * i

		var leftDoor = 0 if i == 0 else randi_range(1, height - 3)
		var rightDoor = height / 2 if i == room_amount - 1 else randi_range(1, height - 3)

		rooms.append([width, height, start, leftDoor, rightDoor])
		roomTypes.append(pick_random_type())


# Draws the full floorplan by:
# 1. Place first room of x * z size.
# 2. Place a path between the first room and a random point at an x offset.
# 3. Place second room on same x-axis
func draw_rooms() -> void:
	var start = true
	for i in room_amount:
		room = rooms[i]

		# Get the variables of the room
		var rightDoor = room[4]
		var leftDoor = room[3]

		# Set some global variables for the generateRoom script
		absolute_position.x = room[2] * 2
		start_pos = Vector3i(0, 10, leftDoor * 2)
		end_pos = Vector3i(room[0] * 2 - 1, 10, rightDoor * 2 - 1)

		make_room(room)
		if roomTypes[i] != CUSTOM:
			fill_room(room)
		else:
			start = false
			continue
		# Place the corridors between the current and next room
		if i == room_amount - 1:
			last_room = true

		var xstart = rooms[i][2]
		var xend = rooms[i][2] + rooms[i][0] - 1
		place_doors(Vector3i(xstart, HEIGHT, leftDoor), Vector3i(xend, HEIGHT, rightDoor), start, last_room)
		start = false



func fill_room(room_dim: Array) -> void:
	var room_scene = preload("res://scenes/world/roomGeneration.tscn").instantiate()
	room_scene.position = Vector3i(room_dim[2] * 2, 0, 0)
	add_child(room_scene, true)



# Places floor grid of x * z size based on room array
func make_room(room : Array) -> void:
	var start = Vector3i(room[2], 0, 0)
	for h in room[1]:
		for w in room[0]:
			self.set_cell_item(start + Vector3i(w, HEIGHT, h), FLOOR1)


# Sorts vectors on x axis.
func sort_vector(a : Vector3i, b : Vector3i):
	return a.x < b.x


# Draws paths between the doors.
func draw_paths() -> void:
	var right = self.get_used_cells_by_item(DOOROPENL)
	var ends = self.get_used_cells_by_item(DOOROPENR)

	right.sort_custom(sort_vector)
	ends.sort_custom(sort_vector)
	
	assert(right.size() == ends.size())
	for i in range(right.size() - 1, -1, -1):
		if get_cell_item_orientation(right[i]) != 22:
			right.pop_at(i)
		if get_cell_item_orientation(ends[i]) != 16:
			ends.pop_at(i)
	assert(right.size() == ends.size())
		
	for i in right.size():
		make_path(right[i] - Vector3i(0, 1, 0), ends[i] - Vector3i(0, 1, 0))


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
func place_doors(start_location : Vector3i, end_location : Vector3i, start, end) -> void:
	if not start:
		self.set_cell_item(start_location + Vector3i(0, 1, 1), DOOROPENL, 16)
		self.set_cell_item(start_location + Vector3i(0, 1, 0), DOOROPENR, 16)
	if not end:
		self.set_cell_item(end_location + Vector3i(0, 1, 1), DOOROPENR, 22)
		self.set_cell_item(end_location + Vector3i(0, 1, 0), DOOROPENL, 22)

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

	
	
