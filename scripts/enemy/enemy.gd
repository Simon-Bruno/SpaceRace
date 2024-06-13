extends CharacterBody3D

@export var speed : int = 7
@export var acceleration : int = 2
@export var fall_acceleration : float = 60.0
@export var stopping_distance : float = 1.5
@export var health : int = 100

@onready var HpBar = $SubViewport/HpBar

var knockback_strength : float = 25.0
var targeted_player : Node = null
var last_damaged_by : Node = null
var max_health: int = Global.enemy_max_health
var player_in_attack_zone : bool = false
var closest_target_node : Node = null
var nodes_in_area : Array = []

func _ready():
	add_to_group("Enemies")

# Function to find the closest node from an array of nodes
func find_closest_player_in_range(nodes_array: Array):
	var min_distance = INF
	
	for node in nodes_in_area:
		var distance = (self.global_transform.origin - node.global_transform.origin).length()
		if distance < min_distance:
			min_distance = distance
			closest_target_node = node

func _enter_tree():
	if multiplayer.is_server():
		$MultiplayerSynchronizer.set_multiplayer_authority(multiplayer.get_unique_id())

func _process(delta):
	find_closest_player_in_range(nodes_in_area)
	
	if closest_target_node:
		var target_direction = (closest_target_node.global_transform.origin - global_transform.origin).normalized()
		velocity.x = lerp(velocity.x, target_direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, target_direction.z * speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, acceleration * delta)
		
	if player_in_attack_zone and closest_target_node.get_node("./PlayerCombat/GetHitCooldown"):
		if !closest_target_node.respawn_immunity:
			closest_target_node.take_damage(closest_target_node.name, 20)
	

func _physics_process(delta):
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
		
# Used in player script when attacking an enemy, apply_damage_to_enemy
@rpc("any_peer", "call_local", "reliable")
func take_damage(id, damage, source):
	#if not multiplayer.is_server():
		#return
	if id != str(multiplayer.get_unique_id()):
		return 
		
	health = max(0, health - damage)
	last_damaged_by = source
	HpBar.value = float(health) / max_health * 100
	
	print("enemy took damage on peer:  " + str(multiplayer.get_unique_id()) + "  health:  " + str(health))
	if health <= 0:
		die() 

	var knockback_direction = (global_transform.origin - source.global_transform.origin).normalized()
	velocity.x += knockback_direction.x * knockback_strength
	velocity.z += knockback_direction.z * knockback_strength

func enemy():
	pass

func die():
	#if not multiplayer.is_server():
		#return
	if last_damaged_by.get_parent().is_in_group("Players"):
		last_damaged_by.get_parent().points += 5
	queue_free()
