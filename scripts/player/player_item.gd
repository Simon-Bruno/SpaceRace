extends Node3D

# dictionary as set using dummy  values
var candidates = {}
var holding = null

# how fast the item should follow the player
var item_follow_speed = 15

func _on_area_3d_body_entered(body):
	"""Add item to candidate list"""
	# null as dummy value
	candidates[body] = null


func _on_area_3d_body_exited(body):
	"""Remove item from candidate list"""
	candidates.erase(body)


func _find_best_candidate():
	""" Find the closest item and return it"""
	
	var smallest_distance = INF
	var best_candidate = null
	
	# find item with smallest distance
	for candidate in candidates:
		var d = global_position.distance_to(candidate.global_position)
		if d < smallest_distance:
			smallest_distance = d
			best_candidate = candidate
			
	return best_candidate


func _hold_item(item):
	""" Hold item """
	
	item.get_parent().owned = true
	holding = item
	
	
func _drop_item():
	""" Drop the item """
	
	holding.get_parent().owned = false
	holding = null	


func _item_follow_player(delta):
	""" Stick item to the player """
	
	var destination = global_position
	destination.y += get_parent_node_3d().get_node("Pivot/MeshInstance3D").get_aabb().size.y
	
	holding.global_position = holding.global_position.lerp(destination, item_follow_speed * delta)


func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if holding:
			_drop_item()
		else:
			var candidate = _find_best_candidate()
			if candidate and not candidate.get_parent().owned: _hold_item(candidate)
		
	if holding:
		_item_follow_player(delta)

