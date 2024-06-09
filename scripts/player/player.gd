extends CharacterBody3D

@export var walk_speed = 15
@export var walk_acceleration = 40
@export var walk_deceleration = 50
@export var fall_acceleration = 60
@export var jump_impulse = 20
var getHitCooldown = true
var health = Global.player_max_health
var points = 0

var speed = 0
var direction = Vector2.ZERO

func _enter_tree():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

func _ready():
	position += Vector3(randf()*4 + 1, 10, randf()*4+1)
	$FloatingName.text = Network.playername

func _horizontal_movement(delta):
	var vel = Vector3.ZERO
	var current_direction = Input.get_vector("move_left","move_right","move_forward","move_back")

	if current_direction != Vector2.ZERO:	# accelerate if moving
		speed = min(walk_speed, speed + walk_acceleration * delta)
	else: 	# decelerate
		speed = max(0, speed - walk_deceleration  * delta)

	direction = (direction + current_direction).normalized()
	$Pivot.basis = Basis.looking_at(Vector3(direction[0] or 0.001, 0, direction[1]))

	vel.x = direction.x * speed
	vel.z = direction.y * speed
	return vel
	
func _vertical_movement(delta):
	var vel = Vector3.ZERO
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		vel.y = jump_impulse
	if not is_on_floor():
		vel.y = velocity.y - (fall_acceleration * delta)	
	return vel
		
func _player_movement(delta):
	var h = _horizontal_movement(delta)
	var v = _vertical_movement(delta)
	velocity = h + v

func _physics_process(delta):
	if $MultiplayerSynchronizer.is_multiplayer_authority():
		_player_movement(delta)
		move_and_slide()

# Lowers health by certain amount, cant go lower then 0. Starts hit cooldawn timer
func take_damage(damage):
	health = max(0, health-damage)
	getHitCooldown = false
	$PlayerCombat/GetHitCooldown.start()
