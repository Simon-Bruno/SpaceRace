extends Node3D

var activated = false

# Detect when body entered the area
func _on_area_3d_body_entered(body):
	if body is CharacterBody3D and !activated:
		$Door/AnimationPlayer.play("Door Sliding")
		activated = true

# Detect when body exited the area
func _on_area_3d_body_exited(body):
	if body is CharacterBody3D and activated:
		$Door/AnimationPlayer.play_backwards("Door Sliding")
		activated = false

# Change the scale of the pressure plate
func scale_pressure_plate(scaling_factor):
	$PressurePlate.scale *= scaling_factor

# Change to position of the pressure plate
func transform_pressure_plate(x, y, z):
	$PressurePlate.position = Vector3(x, y, z)
	
# Change the scale of the door
func scale_door(scaling_factor):
	$Door.scale *= scaling_factor

# Change to position of the door
func transform_door(x, y, z):
	$Door.position = Vector3(x, y, z)
