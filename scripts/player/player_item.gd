extends Node3D

# Keep track of which item node is held
var holding = null
# Vertical velocity which is applied to items when dropped
const item_pop_velocity = 5

# Find the closest item which is not owned and return it
func _find_best_candidate():
	# Get all candidates in the area
	var candidates = $DetectionArea.get_overlapping_bodies()

	var smallest_distance = INF
	var best_candidate = null

	# Find item with smallest distance which is not owned
	for candidate in candidates:
		if candidate.get_parent().owned:
			continue

		# Get the distance between player and candidate item
		var d = global_position.distance_to(candidate.global_position)
		if d < smallest_distance:
			smallest_distance = d
			best_candidate = candidate

	return best_candidate

# Set item to be held
func _hold_item(item):
	# Make the server freeze the rigid body
	_freeze.rpc(item.get_path(), true)

	holding = item
	# Make the server set the new owner of the item
	_set_this_player_to_hold_item.rpc(multiplayer.get_unique_id(), item.get_path())

# Freeze the rigid body, since the position is updated to place the item
# above the player, which means no forces have to be calculated.
# This prevents jittery item movement on clients.
@rpc("any_peer", "call_local", "reliable")
func _freeze(path, f):
	if multiplayer.is_server():
		get_node(path).freeze = f

# Calls the "use" function of the item the player is holding, if it has one.
func _use_item():
	if holding and is_instance_valid(holding):
		var node = holding.get_parent()
		if node.has_method("use"):
			node.use()

# Make the server set the new owner of an item.
@rpc("any_peer", "call_local", "reliable")
func _set_this_player_to_hold_item(id, item_path):
	if multiplayer.is_server():
		var item = get_node(item_path)
		if item:
			item.get_parent().owned = true
			item.get_parent().owned_node = Network.get_player_node_by_id(id)
			item.get_parent().owned_id = str(id)
			Audiocontroller.play_item_pickup_sfx()

# Drop the item, forgetting the item in the player, and forgetting the owner in
# in the item.
func _drop_item():
	if holding and is_instance_valid(holding):
		_freeze.rpc(holding.get_path(), false)

		_set_this_player_to_drop_item.rpc(multiplayer.get_unique_id(), holding.get_path())
		holding = null

# Make the server make an item forget it's owner.
@rpc("any_peer", "call_local", "reliable")
func _set_this_player_to_drop_item(id, item_path):
	if multiplayer.is_server():
		var item = get_node(item_path)
		item.get_parent().owned = false
		item.get_parent().owned_node = null
		# Make the item pop up
		item.set_axis_velocity(Vector3(0, item_pop_velocity, 0))

func _process(_delta):
	if get_parent().name != str(multiplayer.get_unique_id()):
		return

	# Upon interact
	if Input.is_action_just_pressed("interact"):
		# Drop item if held
		if holding and is_instance_valid(holding):
			_drop_item()
		# Find a new item to pick up, if any
		else:
			var candidate = _find_best_candidate()
			if candidate:
				_hold_item(candidate)

	# Upon use, call the use function
	if Input.is_action_just_pressed("use_item"):
		if not holding:
			return
		if holding and is_instance_valid(holding):
			_use_item()
