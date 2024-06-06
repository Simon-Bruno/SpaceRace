@tool
extends GridMap

@export var exit : Vector3i = Vector3i(15, 0, 4)
@export var start : Vector3i = Vector3i(-1, 0, 3)

@onready var parentNode = get_parent()

# An enum for all of the assets
enum {BANNER, BARREL, CHEST, COIN, COLUMN, DIRT, FLOOR, FLOOR_DETAIL, ROCKS, STAIRS, STONES, TRAP, WALL=15, EMPTY=-1}


# This function is called once the script is instantiated.
func _ready():
	make_room(parentNode.room_width, parentNode.room_height)

# A helper function for generating the walls around the room.
# Width and height correspond to the size of the room, not the room including
# the wall tiles
func make_walls(width, height, wall_thickness):
	for r in range(-wall_thickness, height + wall_thickness):
		var pos: Vector3i = Vector3i(-1, 0, r)
		self.set_cell_item(pos, WALL)
		pos = Vector3i(width + wall_thickness - 1, 0, r)
		self.set_cell_item(pos, WALL)

	for c in range(-wall_thickness, width + wall_thickness):
		var pos: Vector3i = Vector3i(c, 0, -1)
		self.set_cell_item(pos, WALL)
		pos = Vector3i(c, 0, height + wall_thickness - 1)
		self.set_cell_item(pos, WALL)

# The main function for creating the basis of the room.
# This will only spawn an empty room with floors, walls and an exit.
func make_room(width, height):
	self.clear()
	var wall_thickness = 1
	
	# Select a random entrance and exit.
	# Might need swapping for the final version.
	var z: int = randi_range(1, height - 1)
	exit = Vector3i(-1, 0, z)
	z = randi_range(1, height - 1)
	start = Vector3i(width+wall_thickness-1, 0, z)
	
	# Set every tile in the room to be a floor tile.
	for r in height:
		for c in width:
			var pos : Vector3i = Vector3i(c,0,r)
			self.set_cell_item(pos, FLOOR_DETAIL)
	
	# Create the walls around the room.
	make_walls(width, height, wall_thickness)

	# Create the entry and exit for the room.
	self.set_cell_item(exit, EMPTY)
	self.set_cell_item(exit - Vector3i(0, 0, 1), EMPTY)
	self.set_cell_item(start, EMPTY)
	self.set_cell_item(start - Vector3i(0, 0, 1), EMPTY)
