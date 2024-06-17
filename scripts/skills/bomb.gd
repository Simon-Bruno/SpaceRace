extends RigidBody3D

var speed : float = 300.0
var direction : Vector3 = Vector3()

func _ready():
	contact_monitor = true
	max_contacts_reported = 1
	set_physics_process(true)

func set_direction(dir : Vector3):
	direction = dir.normalized()
	apply_impulse(Vector3.ZERO, direction * speed)

func _integrate_forces(state):
	# Check for collision and explode
	if get_colliding_bodies().size() > 0:
		explode()

func explode():
	# Add explosion logic here
	print("Boom!")
	queue_free()
