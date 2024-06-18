extends Node3D

@export var interactable : Node

var customRooms = null
var player = null

# Detect when body entered the area
func _on_area_3d_body_entered(body) -> void:
	if not multiplayer.is_server():
		return
	if body.is_in_group("Players") \
	and body.name == str(multiplayer.get_unique_id()) \
	and player == null:
		player = body
		body.position = interactable.position
		interactable.player = body

# Detect when body exited the area
func _on_area_3d_body_exited(body) -> void:
	if not multiplayer.is_server():
		return
	if body.is_in_group("Players"):
		player = null

# Updates the pressureplate mesh according to the current state
@rpc("authority", "call_local", "reliable")
func update_mesh(state : int) -> void:
	if customRooms:
		$PressurePlate/MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(state)

# Called when button is placed in world. Sets the mesh instance to off.
func _ready() -> void:
	var target_node_name = "WorldGeneration"
	var root_node = get_tree().root
	customRooms = find_node_by_name(root_node, target_node_name)
	#update_mesh.rpc(customRooms.PORTAL)

#Search the gridmap of the world and returns it.
func find_node_by_name(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node

	for child in node.get_children():
		var found_node = find_node_by_name(child, target_name)
		if found_node:
			return found_node
	return null
