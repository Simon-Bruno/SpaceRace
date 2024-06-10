extends CharacterBody3D

@export var speed = 7
@export var acceleration = 2
@export var fall_acceleration = 60.0
@export var stopping_distance = 1.5

var knockback_strength = 25.0

var player_chase = false
var targeted_player = null
var last_damaged_by = null

var health = 100
var max_health: int = 100
var player_in_attack_zone = false

@onready var HpBar = $SubViewport/HpBar

func _enter_tree():
	if multiplayer.is_server():
		$MultiplayerSynchronizer.set_multiplayer_authority(multiplayer.get_unique_id())

func _process(delta):
	if player_chase and targeted_player:
		var target_direction = (targeted_player.global_transform.origin - global_transform.origin).normalized()
		velocity.x = lerp(velocity.x, target_direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, target_direction.z * speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, acceleration * delta)
		
	if player_in_attack_zone and targeted_player.getHitCooldown:
		targeted_player.take_damage(20)
	
	if health <= 0:
		die() 

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= fall_acceleration * delta
	else:
		velocity.y = 0.0

	if player_chase and targeted_player:
		var distance_to_player = global_transform.origin.distance_to(targeted_player.global_transform.origin)
		if distance_to_player > stopping_distance:
			var target_direction = (targeted_player.global_transform.origin - global_transform.origin).normalized()
			velocity.x = lerp(velocity.x, target_direction.x * speed, acceleration * delta)
			velocity.z = lerp(velocity.z, target_direction.z * speed, acceleration * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
			velocity.z = lerp(velocity.z, 0.0, acceleration * delta)

	move_and_slide()

func _on_detection_area_body_entered(body):
	if body.is_in_group("Players"):
		targeted_player = body
		player_chase = true

func _on_detection_area_body_exited(body):
	if body == targeted_player:
		targeted_player = null
		player_chase = false

func _on_enemy_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		player_in_attack_zone = true

func _on_enemy_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		player_in_attack_zone = false
		
# Used in player script when attacking an enemy, apply_damage_to_enemy
func take_damage(damage, source):
	health = max(0, health - damage)
	last_damaged_by = source
	HpBar.value = float(health) / max_health * 100

	var knockback_direction = (global_transform.origin - source.global_transform.origin).normalized()
	velocity.x += knockback_direction.x * knockback_strength
	velocity.z += knockback_direction.z * knockback_strength

func die():
	print(last_damaged_by)
	if last_damaged_by.get_parent().is_in_group("Players"):
		last_damaged_by.get_parent().points += 5
	queue_free()
