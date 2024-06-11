extends Node3D

var enemies_in_weapon_range : Array = []
var closest_target_node : Node = null

var damage = 20

# Function to find the closest enemy from an array of nodes
func find_closest_enemy_in_range(nodes_array: Array):
	var min_distance = INF
	
	for enemy in enemies_in_weapon_range:
		var distance = (self.global_transform.origin - enemy.global_transform.origin).length()
		print(distance)
		if distance < min_distance:
			min_distance = distance
			closest_target_node = enemy

@export var projectile_scene : PackedScene
func attack():
	var projectile_instance = projectile_scene.instantiate()
	var direction_to_shoot = -global_transform.basis.z.normalized()
	var spawn_offset = direction_to_shoot * 1
	get_parent().get_parent().get_parent().add_child(projectile_instance)
	projectile_instance.global_transform.origin = global_transform.origin + spawn_offset
	projectile_instance.direction = direction_to_shoot

func _on_range_body_entered(body):
	if body.is_in_group("Enemies"):
		enemies_in_weapon_range.append(body)

func _on_range_body_exited(body):
	if body.is_in_group("Enemies"):
		enemies_in_weapon_range.erase(body)
