extends Node3D


var enemies_in_weapon_range : Array = []
var fist_damage : int = 50

func attack():
	var player_node = get_parent().get_parent()
	var damage = int(fist_damage * player_node.strength)
	
	# allow multiple enemies to be hit by one attack.
	for enemy in enemies_in_weapon_range:
		enemy.take_damage.rpc(damage, player_node.global_transform.origin)

# this function only gets called when a body enters the weapon range.
func _on_range_body_entered(body):
	if body.is_in_group("Enemies"):
		enemies_in_weapon_range.append(body)

# this function only gets called when a body leaves the weapon range.
func _on_range_body_exited(body):
	if body.is_in_group("Enemies"):
		enemies_in_weapon_range.erase(body)
