extends Node3D

var activated = false

func _on_area_3d_body_entered(body):
	if body is CharacterBody3D and !activated:
		$Door/AnimationPlayer.play("Door Sliding")
		activated = true


func _on_area_3d_body_exited(body):
	if body is CharacterBody3D and activated:
		$Door/AnimationPlayer.play_backwards("Door Sliding")
		activated = false
