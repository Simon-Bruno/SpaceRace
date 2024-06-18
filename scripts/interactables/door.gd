extends StaticBody3D

var customRooms: GridMap = null
@export var activation_count: int = 1

# Called when door is placed in world. Sets the mesh instance to closed.
func _ready() -> void:
	var target_node_name = "WorldGeneration"
	var root_node = get_tree().root
	customRooms = find_node_by_name(root_node, target_node_name)
	_set_door_mesh.rpc(customRooms.DOORCLOSEDR, customRooms.DOORCLOSEDL, false)

#Search the gridmap of the world and returns it.
func find_node_by_name(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node

	for child in node.get_children():
		var found_node = find_node_by_name(child, target_name)
		if found_node:
			return found_node
	return null

# Activates the door and opens it. Change in collision shape and meshinstance is changed to open.
func activated() -> void:
	if not multiplayer.is_server():
		return
	activation_count -= 1
	if activation_count == 0:
		_set_door_mesh.rpc(customRooms.DOOROPENR, customRooms.DOOROPENL, true)

# Deactivates the door and closes it. Change in collision shape and meshinstance is changed to closed.
func deactivated() -> void:
	if not multiplayer.is_server():
		return
	activation_count += 1
	_set_door_mesh.rpc(customRooms.DOORCLOSEDR, customRooms.DOORCLOSEDL, false)

# Helper function to set the door mesh
@rpc("authority", "call_local", "reliable")
func _set_door_mesh(right_mesh: int, left_mesh: int, anim_dir: bool) -> void:
	if anim_dir:
		$AnimationPlayer.play("Door Sliding")
	else:
		$AnimationPlayer.play_backwards("Door Sliding")
	if customRooms:
		$MeshInstance3DR.mesh = customRooms.mesh_library.get_item_mesh(right_mesh)
		$MeshInstance3DL.mesh = customRooms.mesh_library.get_item_mesh(left_mesh)
