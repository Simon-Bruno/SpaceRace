extends CharacterBody3D

@export var speed = 7
@export var acceleration = 2
@export var fall_acceleration = 60.0
@export var stopping_distance = 1.5
var rotation_speed: int = 7

var knockback_strength = 15

var player_chase = false
var targeted_player = null
var last_damaged_by = null

@export var health = 100
var max_health: int = 100
var player_in_attack_zone = false

var closest_target_node = null
var nodes_in_area : Array = []

var AttackAnim: bool = false
var alive: bool = true
var direction = Vector2.ZERO

# Function to find the closest node from an array of nodes
func find_closest_player_in_range(nodes_array: Array):
	var min_distance = INF

	for node in nodes_in_area:
		var distance = (self.global_transform.origin - node.global_transform.origin).length()
		if distance < min_distance:
			min_distance = distance
			closest_target_node = node


@onready var HpBar = $SubViewport/HpBar

func _ready():
	self.add_to_group("Enemies")
	set_physics_process(false)
	set_process(false)

func _enter_tree():
	$MultiplayerSynchronizer.set_multiplayer_authority(1)

func _process(delta):
	if not multiplayer.is_server():
		return

	find_closest_player_in_range(nodes_in_area)

	if player_in_attack_zone and closest_target_node.get_node("./PlayerCombat/GetHitCooldown"):
		if !closest_target_node.respawn_immunity:
			if not AttackAnim and alive:  # animation logic
				AttackAnim = true
				$enemy_textures/AnimationPlayer.stop()			
				$enemy_textures/AnimationPlayer.play("zombie_attack")
				await get_tree().create_timer(0.8).timeout  # wait for animation to finish
				if alive:
					$enemy_textures/AnimationPlayer.stop()
				if closest_target_node:  # make sure node still exists
					if player_in_attack_zone:  # make sure player is still in range of attack
						closest_target_node.take_damage.rpc(closest_target_node.name, 20)
				AttackAnim = false

	if closest_target_node:
		var target_direction = (closest_target_node.global_transform.origin - global_transform.origin).normalized()
		var target_direction_2d = Vector2(target_direction.x, target_direction.z).normalized()
		velocity.x = lerp(velocity.x, target_direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, target_direction.z * speed, acceleration * delta)
		direction = lerp(direction, target_direction_2d, rotation_speed * delta)
		if velocity.x > 0 or velocity.z > 0 and not AttackAnim and alive:
			if not $enemy_textures/AnimationPlayer.is_playing():
				$enemy_textures/AnimationPlayer.play("zombie_walk")
		basis = $enemy_textures.basis.looking_at(Vector3(direction[0], 0, direction[1]))
	else:
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, acceleration * delta)
		if not AttackAnim and alive:
			$enemy_textures/AnimationPlayer.stop()

	if health <= 0:
		die()

func _physics_process(delta):
	if not multiplayer.is_server():
		return

	if not is_on_floor():
		velocity.y -= fall_acceleration * delta
	else:
		velocity.y = 0.0

	if closest_target_node:
		var distance_to_player = global_transform.origin.distance_to(closest_target_node.global_transform.origin)
		if distance_to_player > stopping_distance:
			var target_direction = (closest_target_node.global_transform.origin - global_transform.origin).normalized()
			velocity.x = lerp(velocity.x, target_direction.x * speed, acceleration * delta)
			velocity.z = lerp(velocity.z, target_direction.z * speed, acceleration * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
			velocity.z = lerp(velocity.z, 0.0, acceleration * delta)

	move_and_slide()

func add_target(body):
	if body.is_in_group("Players"):
		nodes_in_area.append(body)

func _on_detection_area_body_entered(body):
	if body.is_in_group("Players"):
		nodes_in_area.append(body)
		set_physics_process(true)
		set_process(true)

func _on_detection_area_body_exited(body):
	if body.is_in_group("Players"):
		if body == closest_target_node:
			closest_target_node = null
		nodes_in_area.erase(body)
		if nodes_in_area.is_empty():
			set_process(false)
			set_physics_process(false)

func _on_enemy_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		player_in_attack_zone = true

func _on_enemy_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		player_in_attack_zone = false

# Used in player script when attacking an enemy, apply_damage_to_enemy
@rpc("any_peer", "call_local", "reliable")
func take_damage(damage, player_pos):
	if not multiplayer.is_server():
		return
	health = max(0, health - damage)
	HpBar.value = float(health) / max_health * 100

	if health <= 0:
		die()

	var knockback_direction = (global_transform.origin - player_pos).normalized()
	velocity.x += knockback_direction.x * knockback_strength
	velocity.z += knockback_direction.z * knockback_strength

func die():
	if not multiplayer.is_server():
		return
	rotation_speed = 0
	speed = 0
	if alive:
		alive = false
		$enemy_textures/AnimationPlayer.stop()
		$enemy_textures/AnimationPlayer.play("death")
	await get_tree().create_timer(2).timeout  # wait for anim
	queue_free()

func chase_player(body):
	if is_instance_valid(body) and body.is_in_group("Players"):
		closest_target_node = body
		if not nodes_in_area.has(body):
			nodes_in_area.append(body)
	else:
		print("Invalid body")
