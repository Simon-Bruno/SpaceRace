extends StaticBody3D

var customRooms = null

# Activates the door and opens it. Change in collision shape and meshinstance is changed to open.
func activated():
	$AnimationPlayer.play("Door Sliding")
	if customRooms is GridMap:
		$MeshInstance3DL.mesh = customRooms.mesh_library.get_item_mesh(customRooms.DOOROPENL)
		$MeshInstance3DR.mesh = customRooms.mesh_library.get_item_mesh(customRooms.DOOROPENR)

# Deactivates the door and closes it. Change in collision shape and meshinstance is changed to closed.
func deactivated():
	$AnimationPlayer.play_backwards("Door Sliding")
	if customRooms is GridMap:
		$MeshInstance3DL.mesh = customRooms.mesh_library.get_item_mesh(customRooms.DOORCLOSEDL)
		$MeshInstance3DR.mesh = customRooms.mesh_library.get_item_mesh(customRooms.DOORCLOSEDR)

# Called when door is placed in world. Sets the mesh instance to closed.
func _ready():
	customRooms = get_parent().get_parent()
	if customRooms is GridMap:
		$MeshInstance3DR.mesh = customRooms.mesh_library.get_item_mesh(customRooms.DOORCLOSEDR)
		$MeshInstance3DL.mesh = customRooms.mesh_library.get_item_mesh(customRooms.DOORCLOSEDL)
