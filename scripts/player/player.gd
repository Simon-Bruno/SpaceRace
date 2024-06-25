extends CharacterBody3D

var walkspeed_multiplier : float = 1
@export var walk_speed = 12
@export var fall_acceleration = 60
@export var jump_impulse = 20
var getHitCooldown = true
@export var health = Global.player_max_health
var points = 100
@export var push_force = 1
@export var alive = true
var respawn_immunity : bool = false

var walk_acceleration = 40
var walk_deceleration = 50
var rotation_speed = 10
var rotation_smoothing = 10

var speed = 0
var direction = Vector2.ZERO

var max_dist: float = 25.0  # max distance between players

var strength : float = 1.0

@onready var HpBar = $PlayerCombat/SubViewport/HpBar

var lobby_spawn = Vector3(0, 10, 20)
var game_spawn = { 1: [Vector3(10, 5, 10), Vector3(10, 5, 20)], 2:[Vector3(10, 5, -10), Vector3(10, 5, -20)]}

func _enter_tree():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

func _ready():
	$FloatingName.text = Network.playername
	if Network.player_teams.size() == 0:
		position = lobby_spawn
	elif multiplayer.get_peers().size() > 0 and Network.other_team_member_id != null:
		var is_lower = 0 if multiplayer.get_unique_id() < int(Network.other_team_member_id) else 1
		position = game_spawn[Network.player_teams[str(multiplayer.get_unique_id())]][is_lower]
	else:
		position = game_spawn[1][0]

func _horizontal_movement(delta):
	var vel = Vector3.ZERO

	var current_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	if current_direction != Vector2.ZERO:  # Accelerate if moving
		speed = min(walk_speed * walkspeed_multiplier, speed + walk_acceleration * delta)
		direction = lerp(direction, current_direction, rotation_smoothing * delta)
		basis = $Pivot.basis.looking_at(Vector3(direction.x, 0, direction.y))

	else:  # Decelerate
		speed = max(0, speed - walk_deceleration * delta)

	vel.x = direction.x * speed 
	vel.z = direction.y * speed * Network.inverted

	return vel

	
func _vertical_movement(delta):
	var vel = Vector3.ZERO

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		vel.y = jump_impulse
		Audiocontroller.play_jump_sfx()

	if not is_on_floor():
		vel.y = velocity.y - (fall_acceleration * delta)

	return vel

func _player_movement(delta):
	var h = _horizontal_movement(delta)
	var v = _vertical_movement(delta)

	return h + v

func check_distance(target_velocity):
	if Network.other_team_member_node != null:
		var player_pos = global_transform.origin
		var player2_pos = Network.other_team_member_node.global_transform.origin

		var x_distance = abs(player_pos.x - player2_pos.x)
		if x_distance > max_dist:  # check distance
			if player_pos.x > player2_pos.x and target_velocity.x > 0:  # if player trying to walk further
				target_velocity.x = 0
			elif player_pos.x < player2_pos.x and target_velocity.x < 0:  # if player trying to walk further
				target_velocity.x = 0
	return target_velocity.x

# Lets the player moves object in the room.
func move_object():
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody3D:
			c.get_collider().apply_central_impulse(-c.get_normal()*push_force)


func _physics_process(delta):
	if $MultiplayerSynchronizer.is_multiplayer_authority() and not Global.in_chat:
		var target_velocity = _player_movement(delta)
		target_velocity.x = check_distance(target_velocity)
		velocity = target_velocity
		if velocity != Vector3.ZERO && velocity.y == 0:
			#Audiocontroller.play_walking_sfx()
			pass
		if velocity == Vector3.ZERO:
			pass
			#Audiocontroller.stop_walking_sfx()
		if alive:
			move_and_slide()
	move_object()

func _input(event):
	if str(multiplayer.get_unique_id()) == name:
		if event.is_action_pressed("ability_1"):# and points > $Class.ability1_point_cost:
			$Class.ability1()
		if event.is_action_pressed("ability_2"):# and points > $Class.ability2_point_cost:
			$Class.ability2()

# Lowers health by certain amount, cant go lower then 0. Starts hit cooldawn timer
@rpc("any_peer", "call_local", "reliable")
func take_damage(id, damage):
	if str(id) != str(multiplayer.get_unique_id()):
		return

	if !respawn_immunity and alive and getHitCooldown:
		health = max(0, health - damage)
		getHitCooldown = false
		$PlayerCombat/GetHitCooldown.start()
	HpBar.value = float(health) / Global.player_max_health * 100

	if health <= 0 and alive:
		die()

func die():
	get_parent().player_died(self)

func _on_respawn_immunity_timeout():
	respawn_immunity = false
