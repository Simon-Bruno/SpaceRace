extends StaticBody3D

var customRooms = null

func activated():
	$AnimationPlayer.play("Door Sliding")
	if customRooms is GridMap:
		$MeshInstance3DL.mesh = customRooms.mesh_library.get_item_mesh(customRooms.DOOROPENL)
		$MeshInstance3DR.mesh = customRooms.mesh_library.get_item_mesh(customRooms.DOOROPENR)
	
func deactivated():
	$AnimationPlayer.play_backwards("Door Sliding")
	if customRooms is GridMap:
		$MeshInstance3DL.mesh = customRooms.mesh_library.get_item_mesh(customRooms.DOORCLOSEDL)
		$MeshInstance3DR.mesh = customRooms.mesh_library.get_item_mesh(customRooms.DOORCLOSEDR)

func _ready():
	customRooms = get_parent().get_parent()
	if customRooms is GridMap:
		$MeshInstance3DR.mesh = customRooms.mesh_library.get_item_mesh(customRooms.DOORCLOSEDR)
		$MeshInstance3DL.mesh = customRooms.mesh_library.get_item_mesh(customRooms.DOORCLOSEDL)
