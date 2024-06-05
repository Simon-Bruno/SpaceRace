extends Node3D


func _on_area_3d_body_entered(body):
	print('entered')
	#$AnimationPlayer.play("Door Sliding")
	#$Door.AnimationPlayer.play('Door Sliding')


func _on_area_3d_body_exited(body):
	print('exited')
