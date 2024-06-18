extends CharacterBody3D

@export var speed = 7
@export var acceleration = 2
@export var fall_acceleration = 60.0
@export var stopping_distance = 1.5

var knockback_strength = 0

var player_chase = false
var targeted_player = null
var last_damaged_by = null

@export var health = 1000
var max_health: int = 1000
var player_in_attack_zone = false

var closest_target_node = null
var nodes_in_area : Array = []

@export var enemy_scene : PackedScene

var spawn_thresholds = [0.75, 0.5, 0.25]
var spawned_enemies = false
var charging = false
var shooting = false
var spin_speed = 90.0 * 8
var charge_time = 2.0
var charge_speed = 35
@export var charge_duration = 2.0

@onready var HpBar = $SubViewport/HpBar

@onready var SpinTimer = $SpinTimer
@onready var ChargeTimer = $ChargeTimer
@onready var MeshInstance = $enemy_textures

enum State { IDLE, CHARGING, SPINNING }
var original_albedo_color = Color(1.0, 1.0, 1.0, 1.0)
var current_state = State.IDLE

func _ready():
	$MultiplayerSynchronizer.set_multiplayer_authority(1)
	reset_charge_timer()
	reset_spin_timer()
	
	if MeshInstance.material_override is StandardMaterial3D:
		original_albedo_color = MeshInstance.material_override.albedo_color

func reset_spin_timer():
	SpinTimer.wait_time = 8.0 + randf() * 5.0
	SpinTimer.start()

func _on_spin_timer_timeout():
	if current_state == State.IDLE:
		start_spinning()
	reset_spin_timer()

func reset_charge_timer():
	ChargeTimer.wait_time = 8.0 + randf() * 5.0
	ChargeTimer.start()

func _on_charge_timer_timeout():
	if current_state == State.IDLE:
		start_charge()
	reset_charge_timer()

func _process(delta):
	if not multiplayer.is_server():
		return

	find_closest_player_in_range()

	if player_in_attack_zone and closest_target_node.get_node("./PlayerCombat/GetHitCooldown"):
		if not closest_target_node.respawn_immunity:
			closest_target_node.take_damage(closest_target_node.name, 20)

	if health <= 0:
		die()

	check_health()
	handle_shooting_and_spinning(delta)

func _physics_process(delta):
	if not multiplayer.is_server():
		return

	if current_state == State.CHARGING:
		move_and_slide()
		return

	if not is_on_floor():
		velocity.y -= fall_acceleration * delta
	else:
		velocity.y = 0.0

	if closest_target_node and current_state == State.IDLE:
		var target_position = closest_target_node.global_transform.origin
		var target_direction = (closest_target_node.global_transform.origin - global_transform.origin).normalized()
		velocity.x = lerp(velocity.x, target_direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, target_direction.z * speed, acceleration * delta)
		
		var look_at_position = Vector3(target_position.x, global_transform.origin.y, target_position.z)
		look_at(look_at_position)
		rotate_y(PI)
	else:
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, acceleration * delta)

	move_and_slide()

func _on_detection_area_body_entered(body):
	if body.is_in_group("Players"):
		nodes_in_area.append(body)

func _on_detection_area_body_exited(body):
	if body.is_in_group("Players"):
		if body == closest_target_node:
			closest_target_node = null
		nodes_in_area.erase(body)

func _on_enemy_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		player_in_attack_zone = true

func _on_enemy_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		player_in_attack_zone = false

func take_damage(damage, source):
	if not multiplayer.is_server():
		return
	health = max(0, health - damage)
	if source.has_method("get_parent") and source.get_parent().is_in_group("Players"):
		last_damaged_by = source.get_parent()
	elif "shooter" in source and source.shooter.is_in_group("Players"):
		last_damaged_by = source.shooter
	else:
		last_damaged_by = source
		
	HpBar.value = float(health) / max_health * 100
		
	if health <= 0:
		die()

	var knockback_direction = (global_transform.origin - source.global_transform.origin).normalized()
	velocity.x += knockback_direction.x * knockback_strength
	velocity.z += knockback_direction.z * knockback_strength

func die():
	if not multiplayer.is_server():
		return
	if last_damaged_by.is_in_group("Players"):
		last_damaged_by.points += 5
	queue_free()

func check_health():
	var health_percentage = float(health) / float(max_health)
	for threshold in spawn_thresholds:
		if health_percentage <= threshold:
			spawn_enemies()
			spawn_thresholds.erase(threshold)
			break

func spawn_enemies():
	if not multiplayer.is_server():
		return
	for i in range(3):
		var pos = self.global_transform.origin + Vector3(randf() * 10 - 5, 0, randf() * 10 - 5)
		var enemy = GlobalSpawner.spawn_melee_enemy(pos)
		if enemy:
			enemy.call_deferred("chase_player", last_damaged_by)

func start_charge():
	if not multiplayer.is_server():
		return
	if last_damaged_by and current_state == State.IDLE:
		current_state = State.CHARGING
		look_at(last_damaged_by.global_transform.origin, Vector3.UP)
		rotate_y(PI)
		velocity = Vector3()
		if MeshInstance.material_override is StandardMaterial3D:
			var new_color = original_albedo_color.lerp(Color(1.0, 0.0, 0.0, 1.0), 0.5)
			MeshInstance.material_override.albedo_color = new_color
		await get_tree().create_timer(charge_duration).timeout
		move_towards_player()
		
func move_towards_player():
	if not multiplayer.is_server():
		return
	if last_damaged_by:
		var direction = (last_damaged_by.global_transform.origin - global_transform.origin).normalized()
		velocity = direction * charge_speed
		current_state = State.IDLE
		if MeshInstance.material_override is StandardMaterial3D:
			MeshInstance.material_override.albedo_color = original_albedo_color

func start_spinning():
	if not multiplayer.is_server():
		return
	if current_state == State.IDLE:
		print("Start spinning state")
		current_state = State.SPINNING
		shooting = true
		await get_tree().create_timer(5.0).timeout
		shooting = false
		current_state = State.IDLE
		print("Idle now")

func handle_shooting_and_spinning(delta):
	if not multiplayer.is_server():
		return
	if shooting:
		rotate_y(deg_to_rad(spin_speed) * delta)
		var transform_origin = global_transform.origin
		var spawn_offset = global_transform.basis.z.normalized() * 1.3
		spawn_offset.y -= 0.5
		var direction = global_transform.basis.z.normalized()
		GlobalSpawner.spawn_projectile(transform_origin, spawn_offset, direction, self)

func find_closest_player_in_range():
	var min_distance = INF
	
	for node in nodes_in_area:
		var distance = (self.global_transform.origin - node.global_transform.origin).length()
		if distance < min_distance:
			min_distance = distance
			closest_target_node = node
