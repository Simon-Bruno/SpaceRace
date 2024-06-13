extends Node3D

# the target that is in the laser
var target = null

var damage = 10
var damage_delay = 0.2 # dmg delay in seconds
var damage_time = damage_delay # keep track of time, first dmg tick should be instant
var active = true

# beam
var ray = null
var beam = null
var beam_init_pos = null
var beam_init_scale = null
var beam_size = null

func _ready():
	ray = $Origin/RayCast3D
	beam = $Origin/Beam
	beam_init_pos = beam.position
	beam_init_scale = beam.scale
	beam_size = $Origin/Beam/DamageArea/CollisionShape3D.shape.get_size().x

func _on_area_3d_body_entered(body):
	if body.is_in_group("Players"):
		target = body

func _on_area_3d_body_exited(body):
	if body.is_in_group("Players"):
		target = null
		# make sure first tick always does dmg
		damage_time = damage_delay

func activated():
	active = true
	ray.enabled = true
	beam.visible = true
	
func deactivated():
	active = false
	ray.enabled = false
	beam.visible = false
	
func _process(delta):
	if target and active:
		damage_time += delta
		while damage_time > damage_delay:
			damage_time -= damage_delay
			target.take_damage(damage)
		
	if ray.is_colliding():
		var pos = ray.global_position
		var target_pos = ray.get_collision_point()
		
		var dist = pos.distance_to(target_pos) / beam_size
		
		beam.position.x = beam_init_pos.x * dist
		beam.scale.x = beam_init_scale.x * dist
