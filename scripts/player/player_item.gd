extends Node3D

var holding = null

# Find the closest item and return it
func _find_best_candidate():
	var candidates = $DetectionArea.get_overlapping_bodies()
	
	var smallest_distance = INF
	var best_candidate = null

	# find item with smallest distance
	for candidate in candidates:
		if candidate.get_parent().owned:
			continue
			
		var d = global_position.distance_to(candidate.global_position)
		if d < smallest_distance:
			smallest_distance = d
			best_candidate = candidate
		
	return best_candidate

func _hold_item(item):
	# Hold item
	holding = item
	_set_this_player_to_hold_item.rpc(multiplayer.get_unique_id(), item.get_path())

func _use_item():
	if holding.has_method("use"):
		holding.use()

@rpc("any_peer", "call_local", "reliable")
func _set_this_player_to_hold_item(id, item_path):
	if multiplayer.is_server():
		var item = get_node(item_path)
		item.get_parent().owned = true
		item.get_parent().owned_node = Network.get_player_node_by_id(id)
		Audiocontroller.play_item_pickup_sfx()

func _drop_item():
	# Drop the item
	_set_this_player_to_drop_item.rpc(multiplayer.get_unique_id(), holding.get_path())
	holding = null

@rpc("any_peer", "call_local", "reliable")
func _set_this_player_to_drop_item(id, item_path):
	if multiplayer.is_server():
		var item = get_node(item_path)
		item.get_parent().owned = false
		item.get_parent().owned_node = null

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		if holding:
			_drop_item()
		else:
			var candidate = _find_best_candidate()
			if candidate: 
				_hold_item(candidate)

	if Input.is_action_just_pressed("use_item"):
		if not holding: return
		_use_item()
