extends CharacterBody3D

var getHitCooldown: bool = true
@export var health: int = Global.player_max_health
var points: int = 0
@export var push_force: int = 1
@export var alive: bool = true
var respawn_immunity : bool = false

# movement variables
@export var walk_speed: int = 7
@export var fall_acceleration: int = 60
@export var jump_impulse: int = 20
var walk_acceleration: int = 40
var walk_deceleration: int = 50
var rotation_speed: int = 10
var rotation_smoothing: int = 10
var speed = 0
var direction = Vector2.ZERO
var max_dist: float = 25.0  # max distance between players

# animation variable
var AnimDeath: bool = false
var AnimJump: bool = false
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

	var current_direction = Input.get_vector("move_left","move_right","move_forward","move_back")

	if current_direction != Vector2.ZERO:	# accelerate if moving
		speed = min(walk_speed, speed + walk_acceleration * delta)
		direction = lerp(direction, current_direction, rotation_smoothing * delta)
		basis = $Pivot.basis.looking_at(Vector3(direction[0], 0, direction[1]))

	# decelerate
	else:
		speed = max(0, speed - walk_deceleration  * delta)

	vel.x = direction.x * speed
	vel.z = direction.y * speed * Network.inverted
	#Audiocontroller.play_walking_sfx()

	return vel


func _vertical_movement(delta):
	var vel = Vector3.ZERO

	if is_on_floor() and Input.is_action_just_pressed("jump") and not AnimDeath:
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

		var x_distance: float = abs(player_pos.x - player2_pos.x)
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


func play_animation(anim_player, animation):
	if anim_player == 1:  # anim speed 1
		$Pivot/AnimationPlayer.play(animation)
	else:  # anim speed 1.15 (default for walk)
		$Pivot/AnimationPlayer2.play(animation)


func stop_animations():
	$Pivot/AnimationPlayer.stop()
	$Pivot/AnimationPlayer2.stop()


# request other clients to play animation
func request_play_animation(anim_player, animation):
	rpc_id(0, "sync_play_animation", anim_player, animation)


# send animation update to other clients
@rpc("any_peer", "call_local", "reliable")
func sync_play_animation(anim_player, animation):
	if anim_player == 0:  # to stop animations
		stop_animations()
	else:  # to play animations
		play_animation(anim_player, animation)


func anim_handler():
	if is_on_floor() and Input.is_action_just_pressed("jump") and not AnimDeath:
		request_play_animation(0, "stop")
		request_play_animation(1, "jump")

		AnimJump = true
	else:
		if velocity != Vector3.ZERO && velocity.y == 0:
			if not $Pivot/AnimationPlayer.is_playing():
				request_play_animation(2, "walk")
		if velocity == Vector3.ZERO and not AnimJump and not AnimDeath:
			request_play_animation(0, "stop")
		if velocity.y == 0:
			AnimJump = false


func _physics_process(delta):
	if $MultiplayerSynchronizer.is_multiplayer_authority() and not Global.in_chat:
		var target_velocity = _player_movement(delta)
		target_velocity.x = check_distance(target_velocity)
		velocity = target_velocity
		anim_handler()
		#if velocity != Vector3.ZERO && velocity.y == 0:
			#Audiocontroller.play_walking_sfx()
		#if velocity == Vector3.ZERO:
			#Audiocontroller.stop_walking_sfx()
		if alive:
			move_and_slide()
	move_object()


func _input(event):
	if str(multiplayer.get_unique_id()) == name:
		if event.is_action_pressed("ability_1") and points > $Class.ability1_point_cost:
			$Class.ability1()
		if event.is_action_pressed("ability_2") and points > $Class.ability2_point_cost:
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

	if health <= 0 and alive and not AnimDeath:
		die()


func die():
	# assign globals
	AnimDeath = true
	var temp = walk_speed
	walk_speed = 0
	
	
	request_play_animation(1, "death")  # play anim
	await get_tree().create_timer(2).timeout  # wait for anim
	get_parent().player_died(self)  # die
	
	# reset globals
	AnimDeath = false
	walk_speed = temp
	request_play_animation(0, "stop")


func _on_respawn_immunity_timeout():
	respawn_immunity = false
