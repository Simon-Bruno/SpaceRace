extends Node3D

@export var interactable : Node

# Detect when body entered the area
func _on_area_3d_body_entered(body):
	if body is CharacterBody3D and body.is_in_group("Players"):
		interactable.activated()

# Detect when body exited the area
func _on_area_3d_body_exited(body):
	if body is CharacterBody3D and body.is_in_group("Players"):
		interactable.deactivated()

# Change the scale of the pressure plate
func scale_pressure_plate(scaling_factor):
	$PressurePlate.scale *= scaling_factor

# Change to position of the pressure plate
func transform_pressure_plate(x, y, z):
	$PressurePlate.position = Vector3(x, y, z)
