extends Node3D


func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		$ButtonText.show()

func _on_area_3d_body_exited(body):
	if body is CharacterBody3D:
		$ButtonText.hide()

func _process(delta):
	if Input.is_action_just_pressed("object") and $ButtonText.is_visible():
		print('Nu kan er iets gebeuren... Voeg hiervoor de betreffende scene toe als subnode van ButtonActivate')
		$Door/AnimationPlayer.play("Door Sliding")
