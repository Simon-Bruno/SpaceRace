extends Node3D

# the target that is in the laser
var target = null

var damage = 10
var damage_delay = 0.2 # dmg delay in seconds
var damage_time = damage_delay # keep track of time, first dmg tick should be instant

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

func _ready():
	if timer_active:
		laser_timer = laser_on_duration

func _on_area_3d_body_entered(body):
	if body.is_in_group("Players"):
		target = body

func _on_area_3d_body_exited(body):
	if body.is_in_group("Players"):
		target = null
		# make sure first tick always does dmg
		damage_time = damage_delay

@rpc("any_peer", "call_local", "reliable")
func activated():
	if not multiplayer.is_server():
		return

	activation_count -= 1
	if activation_count == 0:
		active = true
		ray.enabled = true
		beam.visible = true

@rpc("any_peer", "call_local", "reliable")
func deactivated():
	if not multiplayer.is_server():
		return
	activation_count += 1
	if activation_count == 1:
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

# Apply damage to the target
func apply_damage(delta):
	damage_time += delta
	while damage_time > damage_delay:
		damage_time -= damage_delay
		target.take_damage(target.name, damage)

# Update the laser beam
func update_beam():
	if ray.is_colliding():
		var pos = ray.global_position
		var target_pos = ray.get_collision_point()
		var dist = pos.distance_to(target_pos) / beam_size
		beam.position.x = beam_init_pos.x * dist
		beam.scale.x = beam_init_scale.x * dist


func _process(delta):
	if timer_active:
		handle_timer(delta)

	if target != null and active:
		apply_damage(delta)

	if not multiplayer.is_server():
		return

	update_beam()



