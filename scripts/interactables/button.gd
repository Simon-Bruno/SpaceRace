extends Node3D

@export var interactable : Node
@export var activate: bool = false

var customRooms : GridMap = null
var player : CharacterBody3D = null
var inverse : bool = false

# Called when button is placed in world. Sets the mesh instance to off.
func _ready() -> void:
	var target_node_name = "WorldGeneration"
	var root_node = get_tree().root
	customRooms = find_node_by_name(root_node, target_node_name)
	update_mesh.rpc(customRooms.WALLSWITCHOFF)
	if inverse:
		handle_inverse_deactivation()
	update_interact_key()

func update_interact_key():
	if InputMap.has_action("interact"):
		var action_list = InputMap.get_actions()
		for action in action_list:
			if action == 'interact':
				var event_list = InputMap.action_get_events(action)
				for event in event_list:
					var key = event.as_text()
					$ButtonText/SubViewport2/Label.text = "Press " + key

#Search the gridmap of the world and returns it.
func find_node_by_name(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node

	for child in node.get_children():
		var found_node = find_node_by_name(child, target_name)
		if found_node:
			return found_node
	return null

# Activate when button is pressed. Change the mesh to activate or deactivate.
func _input(event):
	if event.is_action_pressed("interact") and $ButtonText.visible:
		if player != null:
			_interact_pressed_on_button.rpc()

@rpc("any_peer", "call_local", "reliable")
func _interact_pressed_on_button():
	if not multiplayer.is_server() or not interactable:
		return
	if !activate:
		_activate_switch()
	else:
		_deactivate_switch()

# Detect when body entered the area
func _on_area_3d_body_entered(body) -> void:
	if body.is_in_group("Players") \
	and body.name == str(multiplayer.get_unique_id()):
		$ButtonText.show()
		player = body

# Detect when body exited the area
func _on_area_3d_body_exited(body) -> void:
	if $ButtonText.visible and body.is_in_group("Players") \
	and body.name == str(multiplayer.get_unique_id()):
		$ButtonText.hide()
		player = null

# Activate switch and call the interactable activation.
func _activate_switch():
	if !inverse:
		interactable.activated()
	else:
		handle_inverse_activation()
	activate = true
	update_mesh.rpc(customRooms.WALLSWITCHON)
	Audiocontroller.play_button_sfx()

# Deactivate the switch and call the interactable deactivation.
func _deactivate_switch():
	if !inverse:
		interactable.deactivated()
	else:
		handle_inverse_deactivation()
	activate = false
	update_mesh.rpc(customRooms.WALLSWITCHOFF)
	Audiocontroller.play_button_sfx()

# Handle activation logic in inverse mode
func handle_inverse_activation() -> void:
	interactable.deactivated()

# Handle deactivation logic in inverse mode
func handle_inverse_deactivation() -> void:
	interactable.activated()

# Update button mesh based on current state
@rpc("authority", "call_local", "reliable")
func update_mesh(state : int) -> void:
	if customRooms:
		$Button/MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(state)
