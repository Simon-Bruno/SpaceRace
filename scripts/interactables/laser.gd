extends Node3D

# the target that is in the laser
var target = null

var damage = 100

@export var active = true
@export var activation_count = 1
@export var hinder = false
@export var timer_active = false

var laser_timer = 0.0
var laser_on_duration = 5.0
var laser_off_duration = 3.0

# beam
@onready var ray = $Origin/RayCast3D
@onready var beam = $Origin/Beam
@onready var beam_init_pos = beam.position
@onready var beam_init_scale = beam.scale
@onready var beam_size = $Origin/Beam/DamageArea/CollisionShape3D.shape.get_size().x

# Function is called when the laser is placed in the room. If the timer needs to be started it starts it.
func _ready():
	if not multiplayer.is_server():
		return
	if timer_active:
		laser_timer = randf_range(1.0, 5.0)
	if not active:
		activation_count = 0
		deactivated()

# Detect when body entered the area and sets the target to the player in the area.
func _on_area_3d_body_entered(body):
	if body.is_in_group("Players"):
		target = body

# # Detect when body exited the area and sets the target to null.
func _on_area_3d_body_exited(body):
	if body.is_in_group("Players"):
		target = null

# Activates the laser. it is shown in the world and the player can get damage.
@rpc("any_peer", "call_local", "reliable")
func activated():
	if not multiplayer.is_server():
		return

	activation_count -= 1
	if activation_count == 0 or timer_active:
		active = true
		ray.enabled = true
		beam.visible = true

# Deactivates the laser. It is not shown in the world and the player doesn't get damage of it.
@rpc("any_peer", "call_local", "reliable")
func deactivated():
	if not multiplayer.is_server():
		return
	activation_count += 1
	if activation_count == 1 or timer_active:
		active = false
		ray.enabled = false
		beam.visible = false

func set_laser():
	active = false
	ray.enabled = false
	beam.visible = false

# Handle the timer logic
func handle_timer(delta):
	laser_timer -= delta
	if active and laser_timer <= 0:
		deactivated.rpc()
		laser_timer = laser_off_duration
	elif not active and laser_timer <= 0:
		activated.rpc()
		laser_timer = laser_on_duration

# Update the laser beam
func update_beam():
	if ray.is_colliding():
		var pos = ray.global_position
		var target_pos = ray.get_collision_point()
		var dist = pos.distance_to(target_pos) / beam_size
		beam.position.x = beam_init_pos.x * dist
		beam.scale.x = beam_init_scale.x * dist

# Function is called every frame to apply damage to the player or handles the timer countdown.
func _process(delta):
	if timer_active and multiplayer.is_server():
		handle_timer(delta)
	if target != null and active:
		target.take_damage.rpc(target.name, 10000)

	if not multiplayer.is_server():
		return

	update_beam()



