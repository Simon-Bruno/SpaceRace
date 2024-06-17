extends Node

@onready var customRooms = preload("res://scenes/world/customRooms.tscn").instantiate()

var rooms = ["Room0", "Room1"]
var roomNodes = []


func get_room_item(location : Vector3i, room : int, layer : int):
	


# Called when the node enters the scene tree for the first time.
func _ready():
	for room in rooms:
		roomNodes.append(customRooms.get_node(room))
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
