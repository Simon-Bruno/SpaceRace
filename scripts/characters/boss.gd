extends CharacterBody3D

@export var speed = 7
@export var acceleration = 2
@export var fall_acceleration = 60.0
@export var stopping_distance = 1.5

var knockback_strength = 15

var player_chase = false
var targeted_player = null
var last_damaged_by = null

@export var health = 1000
var max_health: int = 1000
var player_in_attack_zone = false

var closest_target_node = null
var nodes_in_area : Array = []

# Boss-specific variables
@export var enemy_scene : PackedScene
@export var projectile_scene : PackedScene

var spawn_thresholds = [0.75, 0.5, 0.25]
var spawned_enemies = false
var charging = false
var shooting = false
var spin_speed = 90.0
var charge_time = 2.0
var charge_speed = 20.0

@onready var HpBar = $SubViewport/HpBar

func _enter_tree():
	print("Boss spawned")
	$MultiplayerSynchronizer.set_multiplayer_authority(1)

func _process(delta):
	if not multiplayer.is_server():
		return

	find_closest_player_in_range()
	
	if closest_target_node:
		var target_direction = (closest_target_node.global_transform.origin - global_transform.origin).normalized()
		velocity.x = lerp(velocity.x, target_direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, target_direction.z * speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, acceleration * delta)
		
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
	if last_damaged_by.get_parent().is_in_group("Players"):
		last_damaged_by.get_parent().points += 5
	queue_free()

# Boss-specific functions
func check_health():
	var health_percentage = float(health) / float(max_health)
	for threshold in spawn_thresholds:
		if health_percentage <= threshold:
			spawn_enemies()
			spawn_thresholds.erase(threshold)
			break

func spawn_enemies():
	print("Spawning enemies!")
	for i in range(4):
		var pos = self.global_transform.origin + Vector3(randf() * 10 - 5, 0, randf() * 10 - 5)
		var enemy = GlobalSpawner.spawn_melee_enemy(pos)


func start_charge():
	if closest_target_node:
		charging = true
		await get_tree().create_timer(charge_time).timeout
		move_towards_player()

func move_towards_player():
	charging = false
	if closest_target_node:
		var direction = (closest_target_node.global_transform.origin - self.translation).normalized()
		velocity = direction * charge_speed

func start_spinning():
	shooting = true
	await get_tree().create_timer(5.0).timeout
	shooting = false

func handle_shooting_and_spinning(delta):
	if shooting:
		rotate_y(deg_to_rad(spin_speed) * delta)
		shoot_projectile()

func shoot_projectile():
	var projectile = projectile_scene.instance()
	projectile.translation = self.translation
	projectile.rotation = self.rotation
	get_parent().add_child(projectile)

func find_closest_player_in_range():
	var min_distance = INF
	
	for node in nodes_in_area:
		var distance = (self.global_transform.origin - node.global_transform.origin).length()
		if distance < min_distance:
			min_distance = distance
			closest_target_node = node
