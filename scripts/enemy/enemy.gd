extends CharacterBody3D

@export var speed = 7
@export var acceleration = 2
@export var fall_acceleration = 60.0
@export var stopping_distance = 1.5 

var targeted_player = null
var last_damaged_by = null

var health = 100
var player_in_attack_zone = false

var closest_target_node = null
var nodes_in_area : Array = []

# Function to find the closest node from an array of nodes
func find_closest_player_in_range(nodes_array: Array):
	var min_distance = 0
	
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
	
	if targeted_player:
		var target_direction = (targeted_player.global_transform.origin - global_transform.origin).normalized()
		velocity.x = lerp(velocity.x, target_direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, target_direction.z * speed, acceleration * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, acceleration * delta)
		
	if player_in_attack_zone and targeted_player.getHitCooldown:
		if !targeted_player.respawn_immunity:
			targeted_player.take_damage(20)
	

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= fall_acceleration * delta
	else:
		velocity.y = 0.0

	if targeted_player:
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
		nodes_in_area.append(body)
		#print("body entered: ", body)
		#print("array:", nodes_in_area)

func _on_detection_area_body_exited(body):
	print(targeted_player)
	if body.is_in_group("Players"):
		#nodes_in_area.erase(body)
		var index = nodes_in_area.find(body)
		#print("index:", index)
		if index:
			nodes_in_area.remove_at(index)
		#print("body exited: ", body)
		#print("array:", nodes_in_area)

func _on_enemy_hitbox_body_entered(body):
	if body.is_in_group("Players"):
		player_in_attack_zone = true

func _on_enemy_hitbox_body_exited(body):
	if body.is_in_group("Players"):
		player_in_attack_zone = false
		
func take_damage(damage, source):
	health = max(0, health-damage)
	last_damaged_by = source
		
	if health <= 0:
		die() 

func die():
	print(last_damaged_by)
	if last_damaged_by.get_parent().is_in_group("Players"):
		last_damaged_by.get_parent().points += 5
	queue_free()
