extends Node3D

@export var interactable : Node

var customRooms : GridMap = null
var player = null

func _ready():
	var target_node_name = "WorldGeneration"
	var root_node = get_tree().root
	customRooms = find_node_by_name(root_node, target_node_name)
	if multiplayer.is_server():
		await get_tree().create_timer(1.5).timeout
		update_mesh(customRooms.TELEPORTER)
		set_interactable_on_clients.rpc(interactable.get_path())

@rpc("authority", "call_remote", "reliable")
func set_interactable_on_clients(path):
	interactable = get_node(path)

# Detect when body entered the area
func _on_area_3d_body_entered(body) -> void:
	if body.is_in_group("Players") and str(multiplayer.get_unique_id()) == body.name \
	  and not player and interactable:
		player = body
		body.position = interactable.position
		interactable.player = body

func _update_player_position(body, new_position: Vector3) -> void:
	player = body
	body.position = new_position
	interactable.player = body

# Detect when body exited the area
func _on_area_3d_body_exited(body) -> void:
	if body != player:
		return
	player = null

# Updates the portal mesh according to the current state
@rpc("authority", "call_local", "reliable")
func update_mesh(state : int) -> void:
	if customRooms:
		$Portal/MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(state)

#Search the gridmap of the world and returns it.
func find_node_by_name(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node

	for child in node.get_children():
		var found_node = find_node_by_name(child, target_name)
		if found_node:
			return found_node
	return null
