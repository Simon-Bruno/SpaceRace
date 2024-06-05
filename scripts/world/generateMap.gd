extends GridMap

var locationRoom = Vector3i(20, 0, 0)

@export var room_amount = 15
@export var room_width = 20
@export var room_height = 20
@export var room_margin = 7

# Called when the node enters the scene tree for the first time.
func _ready():
	var hallway = load("res://scenes/world/generateHallway.tscn")
	var hallwayInstance = hallway.instantiate()
	
	for i in room_amount:
		var room = load("res://scenes/world/generateRoom.tscn")
		var roomInstance = room.instantiate()
		add_child(roomInstance)
	
		var exit = roomInstance.exit * i * Vector3i(room_width, 0, 0) + i * Vector3i(room_margin, 0, 0)
		var start = roomInstance.start * i * Vector3i(room_width, 0, 0) + i * Vector3i(room_margin, 0, 0)
		hallwayInstance.generate(start, exit)
		roomInstance.position = i * Vector3i(room_width, 0, 0) + i * Vector3i(room_margin, 0, 0)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
