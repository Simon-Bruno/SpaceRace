extends StaticBody3D

var switch_open_r: Mesh = load('res://assets/CustomBlocks/doors/doorOpenL.obj')
var switch_open_l: Mesh = load('res://assets/CustomBlocks/doors/doorOpenR.obj')
var switch_closed_r: Mesh = load('res://assets/CustomBlocks/doors/doorClosedL.obj')
var switch_closed_l: Mesh = load('res://assets/CustomBlocks/doors/doorClosedR.obj')

func activated():
	$AnimationPlayer.play("Door Sliding")
	$MeshInstance3DL.mesh = switch_open_l
	$MeshInstance3DR.mesh = switch_open_r
	
func deactivated():
	$AnimationPlayer.play_backwards("Door Sliding")
	$MeshInstance3DL.mesh = switch_closed_l
	$MeshInstance3DR.mesh = switch_closed_r
