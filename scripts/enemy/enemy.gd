extends CharacterBody3D

@export var speed = 7
@export var acceleration = 2
@export var fall_acceleration = 60.0
@export var stopping_distance = 1.5 

var player_chase = false
var player = null

var health = 100
var player_in_attack_zone = false

func _ready():
	$DetectionArea.body_entered.connect(Callable(self, "_on_detection_area_body_entered"))
	$DetectionArea.body_exited.connect(Callable(self, "_on_detection_area_body_exited"))

func _process(delta):
	if player_chase and player:
		var target_direction = (player.global_transform.origin - global_transform.origin).normalized()
		velocity.x = lerp(velocity.x, target_direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, target_direction.z * speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, acceleration * delta)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= fall_acceleration * delta
	else:
		velocity.y = 0.0

	if player_chase and player:
		var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)
		if distance_to_player > stopping_distance:
			var target_direction = (player.global_transform.origin - global_transform.origin).normalized()
			velocity.x = lerp(velocity.x, target_direction.x * speed, acceleration * delta)
			velocity.z = lerp(velocity.z, target_direction.z * speed, acceleration * delta)
		else:
			velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
			velocity.z = lerp(velocity.z, 0.0, acceleration * delta)

	move_and_slide()

func _on_detection_area_body_entered(body):
	if body.name == "Player":
		player = body
		player_chase = true

func _on_detection_area_body_exited(body):
	if body == player:
		player = null
		player_chase = false

func enemy():
	# Nodig om te identifien wat een enemy is
	pass

func _on_enemy_hitbox_body_entered(body):
	if body.has_method("player"):
		player_in_attack_zone = true

func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		player_in_attack_zone = false

func take_damage(damage):
	health -= damage
	print("Enemy health: ", health)
	if health <= 0:
		queue_free()
