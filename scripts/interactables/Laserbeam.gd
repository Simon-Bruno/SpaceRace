extends Node3D

func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		print('geraakt door laserrr')
		if body.is_in_group("Player"):
			print('ja is idd in de groep')
			# dit moet vervangen worden door een functie die health van de player afhaalt.
		else:
			print("Entered body is not the player")


func _on_area_3d_body_exited(body):
	if body is CharacterBody3D:
		print('weer veilig')
