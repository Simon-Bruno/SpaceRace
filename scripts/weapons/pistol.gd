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

func _process(delta):
	find_closest_enemy_in_range(enemies_in_weapon_range)

func attack():
	var player_node = get_parent().get_parent()
	print(closest_target_node)
	if closest_target_node:
		closest_target_node.take_damage(damage, player_node)

func _on_range_body_entered(body):
	if body.is_in_group("Enemies"):
		enemies_in_weapon_range.append(body)

func _on_range_body_exited(body):
	if body.is_in_group("Enemies"):
		enemies_in_weapon_range.erase(body)
