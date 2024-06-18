extends Node3D

@export var interactable : Node

var customRooms : GridMap = null
var player : CharacterBody3D = null
var activate_text: bool = false
@export var activate: bool = false

var inverse : bool = false
var start : bool = true

# Detect when body entered the area

func _on_area_3d_body_entered(body) -> void:
	if body.is_in_group("Players") \
	and body.name == str(multiplayer.get_unique_id()):
		$ButtonText.show()
		player = body
		activate_text = true

# Detect when body exited the area
func _on_area_3d_body_exited(body) -> void:
	if activate_text and body.is_in_group("Players") \
	and body.name == str(multiplayer.get_unique_id()):
		$ButtonText.hide()
		player = null
		activate_text = false

# Activate switch and call the interactable activation.
func _activate_switch():
	if !inverse:
		interactable.activated()
	else:
		handle_inverse_activation()
	activate = true
	update_mesh.rpc(customRooms.WALLSWITCHON)

# Deactivate the switch and call the interactable deactivation.
func _deactivate_switch():
	if !inverse:
		interactable.deactivated()
	else:
		handle_inverse_deactivation()
	activate = false
	update_mesh.rpc(customRooms.WALLSWITCHOFF)

@rpc("any_peer", "call_local", "reliable")
func _interact_pressed_on_button():
	if not multiplayer.is_server():
		return
	if !activate:
		_activate_switch()
	else:
		_deactivate_switch()

# Update button mesh based on current state
@rpc("authority", "call_local", "reliable")
func update_mesh(state : int) -> void:
	if customRooms:
		$Button/MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(state)

# Handle activation logic in inverse mode
func handle_inverse_activation() -> void:
	if start:
		interactable.activation_count -= 1
		start = false
	interactable.deactivated()

# Handle deactivation logic in inverse mode
func handle_inverse_deactivation() -> void:
	interactable.activated()

# Update button mesh based on current state
func update_button_mesh(state : int):
	if customRooms:
		$Button/MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(state)

# Activate when button is pressed. Change the mesh to activate or deactivate.
func _input(event):
	if event.is_action_pressed("interact") and activate_text:
		if player != null and interactable != null:
			_interact_pressed_on_button.rpc()

# Called when button is placed in world. Sets the mesh instance to off.
func _ready() -> void:
	customRooms = get_parent().get_parent()
	update_mesh.rpc(customRooms.WALLSWITCHOFF)
