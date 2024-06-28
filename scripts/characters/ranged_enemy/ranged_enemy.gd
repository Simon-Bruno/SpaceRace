extends CharacterBody3D

@export var speed = 7
@export var acceleration = 2
@export var fall_acceleration = 60.0
@export var stopping_distance = 1.5

var knockback_strength = 25.0

var player_chase = false
var targeted_player = null
var last_damaged_by = null

@export var health = 100
var max_health: int = 100
var player_in_attack_zone = false

var closest_target_node = null
@export var projectile_scene : PackedScene
var nodes_in_area : Array = []

var fire_cooldown = 4.0 
var time_since_last_fire = 0.0

# Function to find the closest node from an array of nodes
func find_closest_player_in_range(nodes_array: Array):
	var min_distance = INF
	
	# for every node in the area compare the distance to the previous closest target node
	for node in nodes_in_area:
		var distance = (self.global_transform.origin - node.global_transform.origin).length()
		if distance < min_distance:
			min_distance = distance
			closest_target_node = node


@onready var HpBar = $SubViewport/HpBar

# this function only gets called once when the node enters the scene tree.
func _enter_tree():
	if multiplayer.is_server():
		$MultiplayerSynchronizer.set_multiplayer_authority(multiplayer.get_unique_id())

# this function gets called for every frame.
func _process(delta):
	if not multiplayer.is_server():
		return
	find_closest_player_in_range(nodes_in_area)
	time_since_last_fire += delta
	
	# if the enemy is able to shoot and there is a enemy to shoot at then fire.
	if player_in_attack_zone and time_since_last_fire >= fire_cooldown:
		fire_projectile()
		time_since_last_fire = 0.0 
	
# this function gets called for every frame.
func _physics_process(delta):
	if not multiplayer.is_server():
		return
	if not is_on_floor():
		velocity.y -= fall_acceleration * delta
		move_and_slide()

func fire_projectile():
	
	# only shoot when there is a node to target and make sure this code is only run on the 
	if closest_target_node and multiplayer.is_server():
		var projectile_instance = projectile_scene.instantiate()
		var direction_to_player = (closest_target_node.global_position - global_position).normalized()
		var spawn_offset = direction_to_player * 1
		get_node("/root/Main/SpawnedItems/World/ProjectileSpawner").add_child(projectile_instance, true)
		projectile_instance.global_transform.origin = global_transform.origin + spawn_offset
		projectile_instance.direction = direction_to_player
		projectile_instance.shooter_is_player = false
		
# this function gets called only when a body enters the ranged enemies detection area.
func _on_detection_area_body_entered(body):
	if not multiplayer.is_server():
		return
		
	# check if the body is a player.
	if body.is_in_group("Players"):
		nodes_in_area.append(body)
		player_in_attack_zone = true
		fire_projectile()


func _on_detection_area_body_exited(body):
	if not multiplayer.is_server():
		return
	if body.is_in_group("Players"):
		#print("Out of range")
		if body == closest_target_node:
			closest_target_node = null
		nodes_in_area.erase(body)
		
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
	if last_damaged_by.get_parent().is_in_group("Players"):
		last_damaged_by.get_parent().points += 5
	queue_free()
