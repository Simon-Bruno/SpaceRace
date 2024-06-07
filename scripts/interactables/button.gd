extends Node3D

# Detect when body entered the area
func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		$ButtonText.show()

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

# Change the scale of the door
func scale_door(scaling_factor):
	$Door.scale *= scaling_factor

# Change to position of the door
func transform_door(x, y, z):
	$Door.position = Vector3(x, y, z)

func _process(delta):
	if Input.is_action_just_pressed("object") and $ButtonText.is_visible():
		print('Nu kan er iets gebeuren... Voeg hiervoor de betreffende scene toe als subnode van ButtonActivate')
		$Door/AnimationPlayer.play("Door Sliding")
		scale_door(2)
		transform_door(2, 2, 2)
