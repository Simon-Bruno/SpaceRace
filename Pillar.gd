extends MeshInstance3D

var target_position = 0
var speed = 0.2

func _on_area_3d_area_entered(_area):
	target_position = -5
	
func _process(delta):
	if global_position.y > target_position:
		global_position.y -= speed * delta
		
