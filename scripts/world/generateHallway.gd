@tool
extends Node3D

const FLOOR = 2

@onready var grid_map  : GridMap = $GridMap

@export var start_location : Vector3i = Vector3i(0, 0, 0) : set = change_start
@export var end_location : Vector3i = Vector3i(10, 0, 4) : set = change_end

func change_start(val : Vector3i) -> void:
	start_location = val
	generate()
	
func change_end(val : Vector3i) -> void:
	end_location = val
	generate()

func generate():
	grid_map.clear()
	var relative_distance = end_location - start_location
	
	if relative_distance.x < 3:
		print("x distance to small, make sure to leave 2 empty spaces")
		return

	draw_path(relative_distance)

func draw_path(relative_distance : Vector3i) -> void:
	var direction = 0 if relative_distance.z > 0 else 1

	var middle = (relative_distance.x - 1) / 2
	var opposite = relative_distance.x - middle
	
	var vertical_start_main = middle + direction - 1
	var vertical_start_secondary = middle - direction
	
	for i in vertical_start_main:
		grid_map.set_cell_item(start_location + Vector3i(i + 1, 0, 1), FLOOR)
		
	for i in vertical_start_secondary:
		grid_map.set_cell_item(start_location + Vector3i(i + 1, 0, 0), FLOOR)
		
	for i in opposite + direction - 1:
		grid_map.set_cell_item(end_location - Vector3i(i + 1, 0, 0), FLOOR)
		
	for i in opposite - direction:
		grid_map.set_cell_item(end_location - Vector3i(i + 1, 0, -1), FLOOR)
	
	for i in abs(relative_distance.z):
		i = i * (-1 if direction == 0 else 1)
		var offset = 2 if direction == 0 else 0
		grid_map.set_cell_item(start_location - Vector3i(0, 0, i) + Vector3i(vertical_start_main + offset, 0, 0), FLOOR)
		grid_map.set_cell_item(start_location - Vector3i(0, 0, i) + Vector3i(vertical_start_main + 1, 0, 1), FLOOR)
