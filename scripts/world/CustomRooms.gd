extends GridMap

# Defines the room types
enum {ROOM1, ROOM2, ROOM3, ROOM4}

static var START = 24
static var END = 23

# Defines the rooms.
@export var rooms = []


# Sorts vectors based on x value.
func sort_vector(a : Vector3i, b : Vector3i):
	if a.x < b.x:
		return true
	return false


func generate_dimensions():
	var starts = self.get_used_cells_by_item(START)
	var ends = self.get_used_cells_by_item(END)
	
	starts.sort_custom(sort_vector)
	ends.sort_custom(sort_vector)
	
	for i in starts.size():
		var start = starts[i].x + 1
		var width = ends[i].x - starts[i].x - 1
		var height = ends[i].z - starts[i].z + 1
		rooms.append([width, height, start])


# Called when the node enters the scene tree for the first time.
func _ready():
	print("start")
	self.clear()
