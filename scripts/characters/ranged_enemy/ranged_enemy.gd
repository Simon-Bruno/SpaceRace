extends CharacterBody3D

@export var speed : int = 7
@export var acceleration : int = 2
@export var fall_acceleration : float = 60.0
@export var stopping_distance : float = 1.5
@export var health : int = Global.ranged_enemy_max_health
@export var projectile_scene : PackedScene

@onready var HpBar = $SubViewport/HpBar

var knockback_strength : float = 25.0
var player_chase : bool  = false
var targeted_player : Node = null
var last_damaged_by : Node = null
var max_health: int = Global.ranged_enemy_max_health
var player_in_attack_zone : bool = false
var closest_target_node : Node = null
var nodes_in_area : Array = []
var fire_cooldown : float = 4.0 
var time_since_last_fire : float = 0.0

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
	time_since_last_fire += delta
	if player_in_attack_zone and time_since_last_fire >= fire_cooldown:
		fire_projectile()
		time_since_last_fire = 0.0 
	

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= fall_acceleration * delta
		move_and_slide()

func fire_projectile():
	if closest_target_node and multiplayer.is_server():
		var projectile_instance = projectile_scene.instantiate()
		var direction_to_player = (closest_target_node.global_position - global_position).normalized()
		var spawn_offset = direction_to_player * 1
		get_node("/root/Main/SpawnedItems/World/ProjectileSpawner").add_child(projectile_instance, true)
		projectile_instance.global_transform.origin = global_transform.origin + spawn_offset
		projectile_instance.direction = direction_to_player
		
func _on_detection_area_body_entered(body):
	if body.is_in_group("Players"):
		nodes_in_area.append(body)
		player_in_attack_zone = true
		fire_projectile()

func _on_detection_area_body_exited(body):
	if body.is_in_group("Players"):
		if body == closest_target_node:
			closest_target_node = null
		nodes_in_area.erase(body)
		
# Used in player script when attacking an enemy, apply_damage_to_enemy
func take_damage(damage, source):
	#if not multiplayer.is_server():
		#return
		
	health = max(0, health - damage)
	last_damaged_by = source
	HpBar.value = float(health) / max_health * 100
	
	print("ranged_enemy took damage on peer:  " + str(multiplayer.get_unique_id()) + "  health:  " + str(health))
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
