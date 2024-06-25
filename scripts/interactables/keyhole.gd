extends Node3D

@export var interactable : Node
@export var key : Node

var customRooms : GridMap = null
var bodies_on_plate: Array = []
var has_player = null
var has_item = null
var fixed = false

# Called when keyhole is placed in world. Sets the mesh instance.
func _ready() -> void:
	var target_node_name = "WorldGeneration"
	var root_node = get_tree().root
	customRooms = find_node_by_name(root_node, target_node_name)
	update_mesh.rpc(customRooms.KEYHOLEGREEN)

#Search the gridmap of the world and returns it.
func find_node_by_name(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node

	for child in node.get_children():
		var found_node = find_node_by_name(child, target_name)
		if found_node:
			return found_node
	return null

func _on_area_3d_body_entered(body):
	if not multiplayer.is_server():
		return

	if body.is_in_group("Players"):
		has_player = true
	if body is RigidBody3D:
		has_item = true
		key = body.get_parent()
	if has_player and has_item and not fixed:
		activate()

func _on_area_3d_body_exited(body):
	if not multiplayer.is_server():
		return

	if body.is_in_group("Players"):
		has_player = false
	if body is RigidBody3D:
		has_item = false

func activate():
	interactable.activated()
	key.delete.rpc()
	fixed = true

# Update keyhole mesh based on current state
@rpc("authority", "call_local", "reliable")
func update_mesh(state : int) -> void:
	if customRooms:
		$MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(state)
