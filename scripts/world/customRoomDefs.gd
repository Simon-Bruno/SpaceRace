extends Node

@onready var customRooms = preload("res://scenes/world/customRooms.tscn").instantiate()

var rooms = ["Room1", "Room2"]
var roomNodes = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for room in rooms:
		roomNodes.append(customRooms.get_node(room))
	
	for i in roomNodes:
		print(i.get_child(0).get_used_cells())



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
