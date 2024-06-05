extends GridMap


var locationRoom = Vector3i(20, 0, 0)
enum {BANNER, BARREL, CHEST, COIN, COLUMN, DIRT, FLOOR, FLOOR_DETAIL, ROCKS, STAIRS, STONES, TRAP, WALL=15, EMPTY=-1}


@export var room_amount = 15
@export var room_width = 20
@export var room_height = 20
@export var room_margin = 7

# Called when the node enters the scene tree for the first time.
func _ready():
	var room = load("res://scenes/world/generateRoom.tscn")
	var hallway = load("res://scenes/world/generateHallway.tscn")
	
	var prevroom = room.instantiate()
	add_child(prevroom)
	var start1 = prevroom.start
	var exit1 = prevroom.exit
	
	for i in room_amount - 1:
		var nextroom = room.instantiate()
		add_child(nextroom)
		var start2 = nextroom.start +  i * Vector3i(room_width, 0, 0) + i * Vector3i(room_margin, 0, 0)
		var exit2 = nextroom.exit +  i * Vector3i(room_width, 0, 0) + i * Vector3i(room_margin, 0, 0)
		nextroom.position = i * Vector3i(room_width, 0, 0) + i * Vector3i(room_margin, 0, 0)
		
		var hallwayInstance = hallway.instantiate()
		add_child(hallwayInstance)
		hallwayInstance.generate(exit1, start2)
		print("start1: " + str(start1) + "exit1: " + str(exit1))
		print("start2: " + str(start2) + "exit2: " + str(exit2))
		
		prevroom = nextroom
		start1 = start2
		exit1 = exit2
		



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
