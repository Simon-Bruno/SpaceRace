extends StaticBody3D

var customRooms: GridMap = null
@export var activation_count: int = 1

# Called when door is placed in world. Sets the mesh instance to closed.
func _ready() -> void:
	customRooms = get_parent().get_parent()
	if customRooms is GridMap:
		_set_door_mesh(customRooms.DOORCLOSEDR, customRooms.DOORCLOSEDL)

# Activates the door and opens it. Change in collision shape and meshinstance is changed to open.
func activated() -> void:
	activation_count -= 1
	if activation_count == 0:
		$AnimationPlayer.play("Door Sliding")
		if customRooms is GridMap:
			_set_door_mesh(customRooms.DOOROPENR, customRooms.DOOROPENL)

# Deactivates the door and closes it. Change in collision shape and meshinstance is changed to closed.
func deactivated() -> void:
	activation_count += 1
	$AnimationPlayer.play_backwards("Door Sliding")
	if customRooms is GridMap:
		_set_door_mesh(customRooms.DOORCLOSEDR, customRooms.DOORCLOSEDL)

# Helper function to set the door mesh
func _set_door_mesh(right_mesh: int, left_mesh: int) -> void:
	$MeshInstance3DR.mesh = customRooms.mesh_library.get_item_mesh(right_mesh)
	$MeshInstance3DL.mesh = customRooms.mesh_library.get_item_mesh(left_mesh)
