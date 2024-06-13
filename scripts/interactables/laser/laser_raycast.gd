extends RayCast3D

var laser = null
var init_pos = null
var init_scale = null

func _ready():
	laser = $"../Origin"
	init_pos = laser.position
	init_scale = laser.scale

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if is_colliding():
		var pos = global_position
		var target_pos = get_collision_point()
		
		var dist = pos.distance_to(target_pos) * 5
		
		laser.position.x = init_pos.x * dist
		laser.scale.x = init_scale.x * dist
