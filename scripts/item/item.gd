extends RigidBody3D

# make sure only one person holds the item
var owned = false

# animation vars
var rotation_speed = 0.5
var bob_frequency = 0.25
var bob_amplitude = 0.25
var bob_offset = 0.25
var bob_time = 0.0

var initial_position = Vector3()

func _ready():
	initial_position = $MeshOrigin.position

func _animate(delta):
	"""Makes the item rotate and bob up and down"""
	
	# rotate by rotating the origin
	$MeshOrigin.rotate_y(rotation_speed * delta)
	
	# bobbing by translating the origin
	bob_time += delta
	# TAU is 2*PI
	var new_y = bob_offset + initial_position.y + bob_amplitude * sin(bob_time * bob_frequency * TAU)
	$MeshOrigin.position = Vector3(initial_position.x, new_y, initial_position.z)

func _process(delta):
	_animate(delta)
