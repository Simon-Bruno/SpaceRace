extends StaticBody3D

func activated():
	$AnimationPlayer.play("Door Sliding")
	
func deactivated():
	$AnimationPlayer.play_backwards("Door Sliding")
