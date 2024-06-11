extends Node3D

@export var interactable : Node
var player = null
var activate_text: bool = false
var activate: bool = false
var switch_on: Mesh = load('res://assets/CustomBlocks/walls/wallSwitchOn.obj')
var switch_off: Mesh = load('res://assets/CustomBlocks/walls/wallSwitchOff.obj')

# Detect when body entered the area
func _on_area_3d_body_entered(body):
	if body is CharacterBody3D and body.is_in_group("Players"):
		$ButtonText.show()
		player = body
		activate_text = true

# Detect when body exited the area
func _on_area_3d_body_exited(body):
	if body is CharacterBody3D and activate_text and body.is_in_group("Players"):
		$ButtonText.hide()
		player = null
		activate_text = false

# Activate switch
func _activate_switch():
	$Button/MeshInstance3D.mesh = switch_on
	interactable.activated()
	activate = true

# Deactivate the switch
func _deactivate_switch():
	$Button/MeshInstance3D.mesh = switch_off
	interactable.deactivated()
	activate = false

# Activate when button is pressed
func _process(delta):
	if Input.is_action_just_pressed("interact") and activate_text:
		if player != null and interactable != null:
			if !activate:
				_activate_switch()
			else:
				_deactivate_switch()
