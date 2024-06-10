extends Node3D

var player = null

# Detect when body entered the area
func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		$ButtonText.show()
		player = body

# Detect when body exited the area
func _on_area_3d_body_exited(body):
	if body is CharacterBody3D:
		$ButtonText.hide()

# Change the scale of the button
func scale_button(scaling_factor):
	$Button.scale *= scaling_factor

# Change to position of the button
func transform_button(x, y, z):
	$Button.position = Vector3(x, y, z)

# Activate when button is pressed
func _process(delta):
	if Input.is_action_just_pressed("object") and $ButtonText.is_visible():
		if player != null:
			player.activate_door_open()