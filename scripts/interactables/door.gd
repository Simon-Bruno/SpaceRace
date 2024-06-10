extends StaticBody3D

func open_door():
	$AnimationPlayer.play("Door Sliding")
	
func close_door():
	$AnimationPlayer.play_backwards("Door Sliding")
