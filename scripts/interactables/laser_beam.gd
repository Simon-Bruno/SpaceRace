extends Node3D

var damage_laser = 5
var in_laser = null

func _on_area_3d_body_entered(body):
	if body is CharacterBody3D:
		if body.is_in_group("Players"):
			#body.take_damage(damage_laser)
			print('damage')
			in_laser = body

func _on_area_3d_body_exited(body):
	if body is CharacterBody3D:
		print('weer veilig')
		in_laser = null

func _process(delta):
	if in_laser != null:
		in_laser.take_damage(damage_laser)
		
