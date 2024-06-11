extends GridMap

# Defines the room types
enum {ROOM1, ROOM2, ROOM3, ROOM4}

# Define the widths of the rooms.
@export var room_types = {ROOM1:[0]}
@export var rooms = [[8, 8, 0], [8, 8, 0], [8, 8, 0], [8, 8, 0], [8, 8, 0]]


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
