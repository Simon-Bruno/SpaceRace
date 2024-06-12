extends Node3D

# dictionary as set using dummy  values
var candidates = {}
var holding = null

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
	holding = item
	_set_this_player_to_hold_item.rpc(multiplayer.get_unique_id(), item.get_path())
	
@rpc("any_peer", "call_local", "reliable")
func _set_this_player_to_hold_item(id, item_path):
	if multiplayer.is_server():
		var item = get_node(item_path) 
		item.get_parent().owned = true
		item.get_parent().owned_node = Network.get_player_node_by_id(id)
	
func _drop_item():
	""" Drop the item """
	_set_this_player_to_drop_item.rpc(multiplayer.get_unique_id(), holding.get_path())
	holding = null	

@rpc("any_peer", "call_local", "reliable")
func _set_this_player_to_drop_item(id, item_path):
	if multiplayer.is_server():
		var item = get_node(item_path)
		item.get_parent().owned = false
		item.get_parent().owned_node = null		

func _process(delta):
	if Input.is_action_just_pressed("interact"):
		if holding:
			_drop_item()
		else:
			var candidate = _find_best_candidate()
			if candidate and not candidate.get_parent().owned: _hold_item(candidate)

