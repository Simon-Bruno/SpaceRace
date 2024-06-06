@tool
extends GridMap

@export var exit : Vector3i = Vector3i(15, 0, 4)
@export var start : Vector3i = Vector3i(-1, 0, 3)

@onready var parentNode = get_parent()

var room_tiles : Array[PackedVector3Array] = []
var room_positions : PackedVector3Array = []

enum {BANNER, BARREL, CHEST, COIN, COLUMN, DIRT, FLOOR, FLOOR_DETAIL, ROCKS, STAIRS, STONES, TRAP, WALL=15, EMPTY=-1}


# Called when the node enters the scene tree for the first time.
func _ready():
	make_room(parentNode.room_width, parentNode.room_height)

func _process(_delta):
	pass

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


func make_room(width, height):
	self.clear()
	var wall_thickness = 1

	var z: int = randi_range(1, height - 1)
	exit = Vector3i(-1, 0, z)
	z = randi_range(1, height - 1)
	start = Vector3i(width+wall_thickness-1, 0, z)

	for r in height:
		for c in width:
			var pos : Vector3i = Vector3i(c,0,r)
			self.set_cell_item(pos, FLOOR_DETAIL)

	make_walls(width, height, wall_thickness)

	self.set_cell_item(exit, EMPTY)
	self.set_cell_item(exit - Vector3i(0, 0, 1), EMPTY)
	self.set_cell_item(start, EMPTY)
	self.set_cell_item(start - Vector3i(0, 0, 1), EMPTY)
