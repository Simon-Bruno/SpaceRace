extends CharacterBody3D

@export var walk_speed = 8
@export var fall_acceleration = 30
@export var jump_impulse = 8.5
var getHitCooldown = true
@export var health = Global.player_max_health
var points = 500
@export var alive = true
var respawn_immunity: bool = false

var walk_acceleration = 40
var walk_deceleration = 50
var rotation_speed = 7.5

var speed = 0
var direction = Vector2.ZERO

var max_dist: float = 25.0 # max distance between players

var strength : float = 1.0
var speed_boost : float = 1.0
# animation variable
var AnimDeath: bool = false
var AnimJump: bool = false

@onready var HpBar = $PlayerCombat/SubViewport/HpBar

var lobby_spawn = Vector3(0, 10, 20)
var game_spawn = {1: [Vector3(10, 5, 5), Vector3(10, 5, 10)],2: [Vector3(10, 5, -5), Vector3(10, 5, -10)]}


func _enter_tree():
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())

@rpc("authority", "call_local", "reliable")
func set_params_for_player(id, new_scale, new_walk_speed, new_accel):
	if str(id) != str(multiplayer.get_unique_id()):
		return
	$Pivot.scale = new_scale
	$PlayerHitbox.scale = new_scale
	$CollisionShape3D.scale = new_scale
	walk_speed = new_walk_speed
	walk_acceleration = new_accel
	walk_deceleration = new_accel * 1.2

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
	if !alive:
		return Vector3.ZERO

	var vel = Vector3.ZERO

	var current_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	if current_direction != Vector2.ZERO:	# accelerate if moving
		speed = min(walk_speed * speed_boost, speed + walk_acceleration * delta)
		direction = lerp(direction, current_direction, rotation_speed * delta)
		basis = $Pivot.basis.looking_at(Vector3(direction[0], 0, direction[1]))

	# decelerate
	else:
		speed = max(0, speed - walk_deceleration * delta)

	vel.x = direction.x * speed
	vel.z = direction.y * speed * Network.inverted

	return vel


func _vertical_movement(delta):
	if !alive:
		return Vector3.ZERO

	var vel = Vector3.ZERO

	if is_on_floor() and Input.is_action_just_pressed("jump") and not AnimDeath:
		vel.y = jump_impulse

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
		if x_distance > max_dist: # check distance
			if player_pos.x > player2_pos.x and target_velocity.x > 0: # if player trying to walk further
				target_velocity.x = 0
			elif player_pos.x < player2_pos.x and target_velocity.x < 0: # if player trying to walk further
				target_velocity.x = 0
	return target_velocity.x

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

		if alive:
			move_and_slide()


func _input(event):
	if str(multiplayer.get_unique_id()) == name:
		#TODO: Not working in lobby, not allowed. Use cooldown
		if event.is_action_pressed("ability_1") and points > $Class.ability1_point_cost:
			$Class.ability1()
		#TODO: Not working in lobby, not allowed. Use cooldown
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


# Increases health/HP of the player
@rpc("any_peer", "call_local", "reliable")
func increase_health(value):
	health = min(Global.player_max_health, health + value)
	print("Increasing health to:", health)  # Debug statement
	HpBar.value = float(health) / Global.player_max_health * 100


# Sets the health to full HP of player
@rpc("any_peer", "call_local", "reliable")
func full_health():
	health = Global.player_max_health
	print("Increasing health to:", health)  # Debug statement	
	HpBar.value = Global.player_max_health


func die():
	# assign globals
	AnimDeath = true
	var temp = walk_speed
	walk_speed = 0
	alive = false

	request_play_animation(1, "death")  # play anim
	await get_tree().create_timer(2).timeout  # wait for anim
	get_parent().player_died(self)  # die

	# reset globals
	AnimDeath = false
	walk_speed = temp
	request_play_animation(0, "stop")


func _on_respawn_immunity_timeout():
	respawn_immunity = false


# Resets the player's speed to its normal speed
func _on_speed_timer_timeout():
	speed_boost = 1.0 # Reset the player's speed
	print("Speed end ", speed)
	$PlayerEffects/SpeedTimer.stop()


# Resets the boost value to its standard value after the timer ended
func _on_strength_timer_timeout():
	strength = 1.0 # Reset the player's strength
	print("Strength end ", strength)
	$PlayerEffects/StrengthTimer.stop()
