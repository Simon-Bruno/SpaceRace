extends CharacterBody3D

@export var walk_speed = 15
@export var fall_acceleration = 60
@export var jump_impulse = 20

var walk_acceleration = 40
var walk_deceleration = 50
var rotation_smoothing = 10

var speed = 0
var direction = Vector2.ZERO

func _enter_tree():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

func _ready():
	position += Vector3(randf()*4 + 1, 10, randf()*4+1)
	$FloatingName.text = Network.playername

# KEEP! IMPORTANT TO IDENTIFY PLAYER
func player():
	pass
	
func _horizontal_movement(delta):
	var vel = Vector3.ZERO
	var current_direction = Input.get_vector("move_left","move_right","move_forward","move_back")

	# accelerate if moving
	if current_direction != Vector2.ZERO:
		speed = min(walk_speed, speed + walk_acceleration * delta)
		direction = lerp(direction, current_direction, rotation_smoothing * delta)
		$Pivot.basis = Basis.looking_at(Vector3(direction[0], 0, direction[1]))
		
	# decelerate
	else:
		speed = max(0, speed - walk_deceleration  * delta)

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
	if $MultiplayerSynchronizer.is_multiplayer_authority() and not Global.in_chat:
		_player_movement(delta)
		move_and_slide()
