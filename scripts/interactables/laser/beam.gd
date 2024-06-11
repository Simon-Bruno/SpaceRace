extends RayCast3D

var beam = null
var init_pos = null
var init_scale = null

func _ready():
	beam = $"../Beam"
	init_pos = beam.position
	init_scale = beam.scale

func _physics_process(_delta):
	if is_colliding():
		var pos = global_position
		var target_pos = get_collision_point()
		
		var dist = pos.distance_to(target_pos) * 5
		
		beam.position.x = init_pos.x * dist
		beam.scale.x = init_scale.x * dist
	
