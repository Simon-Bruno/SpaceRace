extends Node3D

@export var interactable : Node

var customRooms = null
var bodies_on_plate: Array = []

# Detect when body entered the area
func _on_area_3d_body_entered(body):
	if body.is_in_group("Players"):
		if bodies_on_plate.is_empty():
			update_mesh(customRooms.PRESSUREPLATEON)
			if interactable != null:
				interactable.activated()
		bodies_on_plate.append(body)

# Detect when body exited the area
func _on_area_3d_body_exited(body):
	if body.is_in_group("Players"):
		bodies_on_plate.erase(body)
		if bodies_on_plate.is_empty():
			update_mesh(customRooms.PRESSUREPLATEOFF)
			if interactable != null:
				interactable.deactivated()

# Updates the pressureplate mesh according to the current state
func update_mesh(state : int):
	if customRooms:
		$PressurePlate/MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(state)

# Called when button is placed in world. Sets the mesh instance to off.
func _ready():
	customRooms = get_parent().get_parent()
	update_mesh(customRooms.PRESSUREPLATEOFF)
