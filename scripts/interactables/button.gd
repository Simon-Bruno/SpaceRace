extends Node3D

@export var interactable : Node

var customRooms : GridMap = null
var player : CharacterBody3D = null
var activate_text: bool = false
var activate: bool = false
var inverse : bool = false
var start : bool = true

# Detect when body entered the area
func _on_area_3d_body_entered(body):
	if body.is_in_group("Players"):
		$ButtonText.show()
		player = body
		activate_text = true

# Detect when body exited the area
func _on_area_3d_body_exited(body):
	if body.is_in_group("Players") and activate_text:
		$ButtonText.hide()
		player = null
		activate_text = false

# Activate switch and call the interactable activation.
func _activate_switch():
	update_mesh(customRooms.WALLSWITCHON)
	if !inverse:
		interactable.activated()
	else:
		handle_inverse_activation()
	activate = true

# Deactivate the switch and call the interactable deactivation.
func _deactivate_switch():
	update_mesh(customRooms.WALLSWITCHOFF)
	if !inverse:
		interactable.deactivated()
	else:
		handle_inverse_deactivation()
	activate = false

# Update button mesh based on current state
func update_mesh(state : int):
	if customRooms:
		$Button/MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(state)

# Handle activation logic in inverse mode
func handle_inverse_activation():
	if start:
		interactable.activation_count -= 1
		start = false
	interactable.deactivated()

# Handle deactivation logic in inverse mode
func handle_inverse_deactivation():
	interactable.activated()

# Activate when button is pressed. Change the mesh to activate or deactivate.
func _process(delta):
	if Input.is_action_just_pressed("interact") and activate_text:
		if player != null and interactable != null:
			if !activate:
				_activate_switch()
			else:
				_deactivate_switch()

# Called when button is placed in world. Sets the mesh instance to off.
func _ready():
	customRooms = get_parent().get_parent()
	update_mesh(customRooms.WALLSWITCHOFF)
