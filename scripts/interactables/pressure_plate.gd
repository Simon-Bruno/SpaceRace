extends Node3D

@export var interactable : Node

var customRooms = null

# Detect when body entered the area
func _on_area_3d_body_entered(body):
	if body is CharacterBody3D and body.is_in_group("Players"):
		interactable.activated()

# Detect when body exited the area
func _on_area_3d_body_exited(body):
	if body is CharacterBody3D and body.is_in_group("Players"):
		interactable.deactivated()

# Called when button is placed in world. Sets the mesh instance to off.
#func _ready():
	#customRooms = get_parent().get_parent()
	#if customRooms is GridMap:
		#$PressurePlate/MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(customRooms.PRESSUREPLATEOFF)
