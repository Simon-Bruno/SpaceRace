extends Node

static var START = 24
static var END = 23

@onready var customRooms = preload("res://scenes/world/customRooms.tscn").instantiate()

#var rooms = ["bas-1", "bas-2", "bas-3", "bas-4", "bas-5", "bas-7", "bas-8", "bas-9", "bas-10", "bas-11", "bas-12", "Plates1", "Button1", "Maze1" ]
var rooms = ["Plates1", "keyTest"]
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
	return roomNodes.size()


# Called when the node enters the scene tree for the first time.
func _ready():
	roomNodes = []
	for room in rooms:
		roomNodes.append(customRooms.get_node(room))

	for room in special_rooms:
		special_roomNodes.append(customRooms.get_node(room))
		
	test_rooms()
	

# Tests rooms on most occurring problems.
func test_rooms() -> void:
	for room in roomNodes:
		check_teleporters(room)
		check_doors(room)


# Tests room on an even amount of teleporters.
enum {TELEPORTB=102, TELEPORTG=103, TELEPORTO=104, TELEPORTP=105, TELEPORTR=106, TELEPORTY=107}
var teleporters = [TELEPORTB, TELEPORTG, TELEPORTO, TELEPORTP, TELEPORTR, TELEPORTY]
func check_teleporters(room) -> void:
	var found = []
	for teleporter in teleporters:
		found += room.get_child(1).get_used_cells_by_item(teleporter)
	
	if found.size() % 2 != 0:
		push_error("Room ", room.get_name(), " has uneven amount of teleporters. teleporters = ", found.size())
		roomNodes.remove_at(roomNodes.find(room))


# Tests room on correctly placed open doors.
enum {DOOROPENL=9, DOOROPENR=10}
func check_doors(room) -> void:
	var left = room.get_child(0).get_used_cells_by_item(DOOROPENL)
	var right = room.get_child(0).get_used_cells_by_item(DOOROPENR)

	if left.size() != 2 or right.size() != 2:
		push_error("Room ", room.get_name(), " has non-matching doors. left = ", left.size(), " right = ", right.size())
		roomNodes.remove_at(roomNodes.find(room))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
