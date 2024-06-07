extends GridMap

enum {GFLOOR, LDOORO, RDOORO, LDOOR, RDOOR, WALLSOFF, WALLSON, WALLB, WFLOOR, FLOOR, WALLFA, WALLD, WALLC, WINDOWL, WALL, WALLT, WALLL, WALLFU, WINDOWR, EMPTY=-1}

# At what y level is the floor
const HEIGHT : int = 0

@export var room_amount : int = 15
@export var room_width  : int = 20
@export var room_height : int = 20
@export var room_margin : int = 7

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
	draw_rooms()
	draw_walls()


# Draws the full floorplan by:
# 1. Place first room of x * z size.
# 2. Place a path between the first room and a random point at an x offset.
# 3. Place second room on same x-axis
func draw_rooms() -> void:
	for i in room_amount:
		var room_start = (room_width + room_margin) * i - 1
		make_room(Vector3i(room_start, 0, 0))
		
		var zstart = randi_range(1, room_height - 2)
		var zend = randi_range(1, room_height - 3)
		
		var xstart = room_start + room_width - 1
		var xend = xstart + room_margin + 1
		
		if i != room_amount - 1:
			make_path(Vector3i(xstart, HEIGHT, zstart), Vector3i(xend, HEIGHT, zend))

# Places floor grid of x * z size
func make_room(start : Vector3i) -> void:
	for h in room_height:
		for w in room_width:
			self.set_cell_item(start + Vector3i(h, HEIGHT, w), FLOOR)


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
		self.set_cell_item(start_location + Vector3i(i + 1, HEIGHT, 1), FLOOR)
		
	for i in vertical_start_secondary:
		self.set_cell_item(start_location + Vector3i(i + 1, HEIGHT, 0), FLOOR)
		
	for i in opposite + direction - 1:
		self.set_cell_item(end_location - Vector3i(i + 1, HEIGHT, 0), FLOOR)
		
	for i in opposite - direction:
		self.set_cell_item(end_location - Vector3i(i + 1, HEIGHT, -1), FLOOR)
	
	for i in abs(relative_distance.z):
		i = i * (-1 if direction == 0 else 1)
		var offset = 2 if direction == 0 else 0
		self.set_cell_item(start_location - Vector3i(0, 0, i) + Vector3i(vertical_start_main + offset, 0, 0), FLOOR)
		self.set_cell_item(start_location - Vector3i(0, 0, i) + Vector3i(vertical_start_main + 1, 0, 1), FLOOR)


# Sums the integers in an array
static func sum_array(array):
	var sum = 0
	for element in array:
		sum += element
	return sum


# Draws all walls by finding all floors and check if a wall needs to be added.
func draw_walls() -> void:
	var neighbors = [Vector3i(0, 0, -1), Vector3i(1, 0, 0), Vector3i(0, 0, 1), Vector3i(-1, 0, 0)]
	
	# Defining the different floor layouts, and their corresponding orientation.
	var walls = [[0, 1, 1, 1], [1, 0, 1, 1], [1, 1, 0, 1], [1, 1, 1, 0]]
	var corner = [[0, 1, 1, 0], [0, 0, 1, 1], [1, 0, 0, 1], [1, 1, 0, 0]]
	var orientations = [0, 22, 10, 16]
	
	# Get all floors in grid.
	var floors = self.get_used_cells_by_item(FLOOR)
	
	# Go trough all floor items, and check if wall is needed.
	for floor_item in floors:
		var surround = []
		for i in neighbors:
			var neighbor = floor_item + i
			surround.append((1 if self.get_cell_item(neighbor) != -1 else 0))

		var idx = -1
		var type = WALL
		
		# Checks which type of wall, then finds the needed orientation.
		if sum_array(surround) == 3:
			idx = walls.find(surround)
		elif sum_array(surround) == 2:
			idx = corner.find(surround)
			type = WALLC

		# If unknown orientation, skip.
		if idx == -1:
			continue

		# Place wall.
		var orientation = orientations[idx]
		self.set_cell_item(floor_item + Vector3i(0, 1, 0), type, orientation)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
