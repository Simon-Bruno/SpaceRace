extends Node

static var START = 24
static var END = 23

@onready var customRooms = preload("res://scenes/world/customRooms.tscn").instantiate()

var rooms = ["Plates1", "Button1", "Plates2", "Maze1", "Maze2", "Laser1", "Repair1", "Plates3", "Laser2", "Button2", "Plates4", "Portal1", "Portal2", "Portal3", "Button3", "Maze3", "Laser3", "Laser4", "Repair2"]
var special_rooms = ["EndRoom", "StartRoom"]
var roomNodes = []
var special_roomNodes = []


func get_room_item(location : Vector3i, room : int, layer : int, special : bool) -> int:
	var nodes = special_roomNodes if special else roomNodes
	return nodes[room].get_child(layer).get_cell_item(location)


func get_room_item_orientation(location : Vector3i, room : int, layer : int, special : bool) -> int:
	var nodes = special_roomNodes if special else roomNodes
	return nodes[room].get_child(layer).get_cell_item_orientation(location)


func get_room_size(room : int, special : bool) -> Array:
	var nodes = special_roomNodes if special else roomNodes
	var start = nodes[room].get_child(0).get_used_cells_by_item(START)[0]
	var end = nodes[room].get_child(0).get_used_cells_by_item(END)[0]

	return [end.x - start.x - 1, end.z - start.z + 1, start.x + 1]


func total_rooms() -> int:
	return rooms.size()


# Called when the node enters the scene tree for the first time.
func _ready():
	roomNodes = []
	for room in rooms:
		roomNodes.append(customRooms.get_node(room))

	for room in special_rooms:
		special_roomNodes.append(customRooms.get_node(room))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
