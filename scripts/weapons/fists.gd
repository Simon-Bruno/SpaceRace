extends Node3D


var enemies_in_weapon_range : Array = []
var fist_damage : int = 20

func attack():
	var player_node = get_parent().get_parent()
	var damage = int(fist_damage * player_node.strength)
	for enemy in enemies_in_weapon_range:
		enemy.take_damage(damage, player_node)

func _on_range_body_entered(body):
	if body.is_in_group("Enemies"):
		enemies_in_weapon_range.append(body)

func _on_range_body_exited(body):
	if body.is_in_group("Enemies"):
		enemies_in_weapon_range.erase(body)
