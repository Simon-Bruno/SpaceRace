extends CharacterBody3D

# Reference to the player nodes
var player: Node = null
var player2: Node = null

# How fast the player moves in meters per second.
@export var speed: float = 10.0
# The downward acceleration when in the air, in meters per second squared.
@export var fall_acceleration: float = 75.0
# Vertical impulse applied to the character upon jumping in meters per second.
@export var jump_impulse: float = 20.0
# Set powerup to true or false
@export var powerup: bool = false

var max_dist: float = 30.0  # max distance between players
var target_velocity = Vector3.ZERO


# set player name on enter
func _enter_tree():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())


# when a new node is added to the scene
func _ready():
	position += Vector3(randf()*4 + 1, 10, randf()*4+1)
	$FloatingName.text = Network.playername
	
	var players = get_tree().get_nodes_in_group("team")
	if not player:
		if len(players) > 1:
			player = players[1]
			player2 = players[0]
		else:
			player = players[0]


# Pivots character in moving direction
func rotate_character(direction):
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Setting the basis property will affect the rotation of the node.
		$Pivot.basis = Basis.looking_at(direction)


# Adjust the player's velocity
func adjust_velocity(direction, delta):
	# Ground Velocity
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed

	# Vertical Velocity
	if not is_on_floor(): # If in the air, fall towards the floor. Literally gravity
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)


# Actually move the character in the game
func move_character():
	velocity = target_velocity
	move_and_slide()


# Check how many players are present (in the team)
func check_players():
	var nodes_in_group = get_tree().get_nodes_in_group("team")
	var playercount: int = len(nodes_in_group)
	if playercount > 1 && not player2:
		player2 = nodes_in_group[1]
	return playercount

	

# Apply the given input to the direction
func apply_input(direction, move_speed):
	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("move_right"):
		direction.x += move_speed
	if Input.is_action_pressed("move_left"):
		direction.x -= move_speed
	if Input.is_action_pressed("move_back"):
		direction.z += move_speed
	if Input.is_action_pressed("move_forward"):
		direction.z -= move_speed
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
	return direction


# If multiple players, define a maximum distance in the x-axis that the two can be away from one
# another. If such maximum distance is exceeded, make it so that the players cannot move further
# away from each other.
func check_distance(player_count):
	if player_count == 2:
		var player_pos = player.global_transform.origin
		var player2_pos = player2.global_transform.origin
		
		var x_distance = abs(player_pos.x - player2_pos.x)
		if x_distance > max_dist:  # check distance
			if player_pos.x > player2_pos.x and target_velocity.x > 0:  # if player trying to walk further
				target_velocity.x = 0
			elif player_pos.x < player2_pos.x and target_velocity.x < 0:  # if player trying to walk further
				target_velocity.x = 0
	return target_velocity.x


# main loop
func _physics_process(delta):
	if $MultiplayerSynchronizer.is_multiplayer_authority():
		var player_count: int = check_players()
		# We create a local variable to store the input direction.
		var direction = Vector3.ZERO
		var move_speed: int = 1

		direction = apply_input(direction, move_speed)
		rotate_character(direction)
		adjust_velocity(direction, delta)
		target_velocity.x = check_distance(player_count)
		move_character()
