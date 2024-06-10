extends Node3D

var player = null
var activates = null

func activate(act):
	activates = act

# Detect when body entered the area
func _on_area_3d_body_entered(body):
	if body is CharacterBody3D and player == null:
		player = body
		if activates == "Door":
			player.activate_door_open()
		elif activates == "Finish":
			print('Game is finsihed')
		else:
			print("Geef activate functie aan in initialisatie")

# Detect when body exited the area
func _on_area_3d_body_exited(body):
	if body is CharacterBody3D and player != null:
		player = null
		if activates == "Door":
			player.activate_door_close()
		elif activates == "Finish":
			print('Game finish')
		else:
			print("Geef activate functie aan in initialisatie")

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
