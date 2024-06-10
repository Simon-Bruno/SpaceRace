extends GridMap

enum {FLOOR1, FLOOR2, FLOOR3, FLOOR4, FLOOR5, FLOORVENT, FLOORWATER, DOORCLOSEDL, DOORCLOSEDR, DOOROPENL, 
	  DOOROPENR, WALL, WALLBUTTON, WALLCORNER, WALLDESK, WALLFAN, WALLFUSE, WALLLIGHT, WALLSWITCHOFF, WALLSWITCHON, WALLTERMINAL, WINDOWL, WINDOWR}


# At what y level is the floor
const HEIGHT : int = 0
const ROTATIONS : Array = [0, 16, 10, 22]

# Defines what blocks are associated together.
const PAIRS = {DOOROPENL: DOOROPENR, DOOROPENR: DOOROPENL, DOORCLOSEDL: DOORCLOSEDR, DOORCLOSEDR:DOORCLOSEDL, WINDOWR: WINDOWL, WINDOWL: WINDOWR}

@export var room_amount : int = 15
@export var room_width  : int = 10
@export var room_height : int = 10
@export var room_margin : int = 7

# How much the room size can variate in incraments of 2. e.g 10 with variation 1
# can return 8, 10, or 12.
var room_variation_x : int = 1
var room_variation_y : int = 1

# Stores the locations of the rooms. Each entry is: [width, height, startX]
@export var rooms : Array = [] 

# Stores game seed, which will be randomized at start of game, can be set to 
# a custom value useing set_seed()
@export var game_seed : int = 0


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
func set_seed(new_seed : int) -> void:
	seed(new_seed)
	build_map()


# Main function that builds the map. Clears the map first to stop overlap.
# TODO: Expand with all generation layers.
func build_map() -> void:
	self.clear()
	define_rooms()
	draw_rooms()
	draw_walls()
	draw_windows()
	
	mirror_world()


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


# Draws windows with 2 normal walls in between and centers it on the middle of the wall.
# Only works on the connecting walls.
func draw_windows() -> void:
	for room in rooms:
		var start = room[2] + 1 if (room[0] / 2) % 2 == 0 else room[2] + 2

		self.set_cell_item(Vector3i(start, 1, 0), WINDOWL)
		self.set_cell_item(Vector3i(start + 1, 1, 0), WINDOWR)
		while start < room[2] + room[0] - 4:
			start += 4
			self.set_cell_item(Vector3i(start, 1, 0), WINDOWL)
			self.set_cell_item(Vector3i(start + 1, 1, 0), WINDOWR)


# Summs all x values in an array based on the rooms variable.
static func sumXValues(rooms : Array) -> int:
	if rooms.is_empty():
		return 0
	var sum = 0
	for i in rooms:
		sum += i[0]
	return sum


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


# Draws the full floorplan by:
# 1. Place first room of x * z size.
# 2. Place a path between the first room and a random point at an x offset.
# 3. Place second room on same x-axis
func draw_rooms() -> void:
	var xstart
	var zstart
	var xend
	var zend
	for i in room_amount:
		make_room(rooms[i])
		
		if i == room_amount - 1:
			break
		
		zstart = randi_range(1, rooms[i][1] - 3)
		zend = randi_range(1, rooms[i + 1][1] - 3)
		
		xstart = rooms[i][2] + rooms[i][0] - 1
		xend = rooms[i + 1][2]
		
		#print("zend: "+  str(zend) + "xend" +  str(xend))ds   s d
			
		make_path(Vector3i(xstart, HEIGHT, zstart), Vector3i(xend, HEIGHT, zend))
			
			
	make_endroom(Vector3i(xend, HEIGHT, zend))
	make_path(Vector3i(xstart, HEIGHT, zstart), Vector3i(xend, HEIGHT, zend))


func make_endroom(start_location : Vector3i) -> void:
	var startroom = start_location
	make_room(startroom)


# Places floor grid of x * z size based on room array
func make_room(room : Array) -> void:
	var start = Vector3i(room[2], 0, 0)
	print(room[2])
	for h in room[1]:
		for w in room[0]:
			self.set_cell_item(start + Vector3i(w, HEIGHT, h), FLOOR1)


# Draws a 2 wide path between two given vectors, the given point will be the top
# of the path.
func make_path(start_location : Vector3i, end_location : Vector3i) -> void:
	#print("making wall between:" + str(start_location) + str(end_location))
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

	place_doors(start_location, end_location)


func place_doors(start_location : Vector3i, end_location : Vector3i) -> void:
	self.set_cell_item(start_location + Vector3i(0, 1, 0), DOOROPENL, 22)
	self.set_cell_item(start_location + Vector3i(0, 1, 1), DOOROPENR, 22)
	
	self.set_cell_item(end_location + Vector3i(0, 1, 0), DOOROPENR, 16)
	self.set_cell_item(end_location + Vector3i(0, 0, 1), DOOROPENL, 16)

# Sums the integers in an array
static func sum_array(array):
	var sum = 0
	for element in array:
		sum += element
	return sum


func random_floor(floor : Vector3i) -> void:
	var walls = [FLOOR1, FLOOR2, FLOOR3, FLOOR4, FLOOR5]
	var special = [FLOORVENT, FLOORWATER]
	
	var rotation = ROTATIONS[randi() % ROTATIONS.size()]

	if randi_range(1, 100) < 96:
		self.set_cell_item(floor, walls[randi() % walls.size()], rotation)
	else:
		self.set_cell_item(floor, special[randi() % special.size()], rotation)


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
		if sum_array(surround) == 3:
			idx = walls.find(surround)
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
