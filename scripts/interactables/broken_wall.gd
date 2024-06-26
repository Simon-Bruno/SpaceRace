extends Node3D

@export var interactable : Node

var customRooms : GridMap = null
var fixed = false

# Called when broken wall is placed in world. Sets the mesh instance to broken.
func _ready() -> void:
	var target_node_name = "WorldGeneration"
	var root_node = get_tree().root
	customRooms = find_node_by_name(root_node, target_node_name)
	update_mesh.rpc(customRooms.HOLEGREEN)

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
	if not multiplayer.is_server() or not body.is_in_group("Players"):
		return
		
	var item = body.get_node("PlayerItem").holding
	if not item:
		return

	if item.get_parent().is_in_group("Welder"):
		activate.rpc(item)

@rpc("any_peer", "call_local", "reliable")
func activate(item):
	if interactable != null:
		interactable.activated()
	item.get_parent().delete.rpc()
	update_mesh.rpc(customRooms.WALL)
	fixed = true

# Update mesh based on current state
@rpc("authority", "call_local", "reliable")
func update_mesh(state : int) -> void:
	if customRooms:
		$MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(state)
