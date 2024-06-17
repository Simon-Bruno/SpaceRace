extends StaticBody3D

var customRooms: GridMap = null
@export var activation_count: int = 1

# Called when door is placed in world. Sets the mesh instance to closed.
func _ready() -> void:
	customRooms = get_parent().get_parent()
	if customRooms is GridMap:
		_set_door_mesh.rpc(customRooms.DOORCLOSEDR, customRooms.DOORCLOSEDL, false)

# Activates the door and opens it. Change in collision shape and meshinstance is changed to open.
func activated() -> void:
	if not multiplayer.is_server():
		return 
	activation_count -= 1
	if activation_count == 0:
		if customRooms is GridMap:
			_set_door_mesh.rpc(customRooms.DOOROPENR, customRooms.DOOROPENL, true)

# Deactivates the door and closes it. Change in collision shape and meshinstance is changed to closed.
func deactivated() -> void:
	if not multiplayer.is_server():
		return 
	activation_count += 1
	if customRooms is GridMap:
		_set_door_mesh.rpc(customRooms.DOORCLOSEDR, customRooms.DOORCLOSEDL, false)

# Helper function to set the door mesh
@rpc("authority", "call_local", "reliable")
func _set_door_mesh(right_mesh: int, left_mesh: int, anim_dir: bool) -> void:
	if anim_dir:
		$AnimationPlayer.play("Door Sliding")
	else:
		$AnimationPlayer.play_backwards("Door Sliding")
	$MeshInstance3DR.mesh = customRooms.mesh_library.get_item_mesh(right_mesh)
	$MeshInstance3DL.mesh = customRooms.mesh_library.get_item_mesh(left_mesh)
