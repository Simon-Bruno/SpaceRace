extends Node3D

var player = null
@export var interactable : Node

# Detect when body entered the area
func _on_area_3d_body_entered(body):
	if body is CharacterBody3D and body.is_in_group("Players"):
		$ButtonText.show()
		player = body

# Detect when body exited the area
func _on_area_3d_body_exited(body):
	if body is CharacterBody3D and $ButtonText.is_visible() and body.is_in_group("Players"):
		$ButtonText.hide()
		player = null

# Change the scale of the button
func scale_button(scaling_factor):
	$Button.scale *= scaling_factor

# Change to position of the button
func transform_button(x, y, z):
	$Button.position = Vector3(x, y, z)

# Activate when button is pressed
func _process(delta):
	if Input.is_action_just_pressed("interact") and $ButtonText.is_visible():
		if player != null:
			interactable.activated()
