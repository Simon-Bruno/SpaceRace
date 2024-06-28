extends Node3D

@export var owned = false # Is the item owned
@export var owned_node: Node3D = null # The node of the owner
@export var owned_id: String = "" # The id of the owner

# How fast the item should follow the player
var item_follow_speed = 15

# Variables for animating the item bob and rotation
var rotation_speed = 0.5
var bob_frequency = 0.25
var bob_amplitude = 0.25
var bob_offset = 0.25
var bob_time = 0.0
var initial_position = Vector3() # Keep track of the initial animation origin

# Keep track of the global position of the item
@export var item_position: Vector3

# Keeps track if the item is a welder item
@export var welder: bool = false

func _enter_tree():
	if multiplayer.is_server():
		$MultiplayerSynchronizer.set_multiplayer_authority(multiplayer.get_unique_id())

# Save initial conditions to be used later
func _ready():
	initial_position = $RigidBody3D/MeshOrigin.position
	item_position = $RigidBody3D.global_position

# Makes the item mesh rotate and bob up and down
func _animate(delta):
	# Rotate by rotating the origin
	$RigidBody3D/MeshOrigin.rotate_y(rotation_speed * delta)

	# Bobbing by translating the origin
	bob_time += delta

	# Calculate the new y position and apply it to the mesh
	var new_y = bob_offset + initial_position.y + bob_amplitude * sin(bob_time * bob_frequency * TAU) # TAU is 2*PI
	$RigidBody3D/MeshOrigin.position = Vector3(initial_position.x, new_y, initial_position.z)

# Deletes the item from the world
@rpc("any_peer", "call_local", "reliable")
func delete():
	if not multiplayer.is_server():
		return

	# Deletes the bomb when activated and thrown away
	if not owned_node:
		queue_free()
		return

	var player = owned_node.get_node("PlayerItem")
	# Make the player forget the item first
	player._drop_item()
	# Then delete from the scene
	queue_free()

# Called when client wants to consume item,
# in other words delete the item from world
@rpc("any_peer", "call_local", "reliable")
func request_server_delete_item():
	if multiplayer.is_server():
		delete. rpc ()

# Deletes the item after consuming/using it,
# or sends a request to the server to delete it
func consume_item():
	if multiplayer.is_server():
		delete. rpc ()
	else:
		request_server_delete_item. rpc ()

# Called when player consumes the item
func on_player_consume_potion():
	if owned_node:
		consume_item()

func _process(delta):
	_animate(delta)

	# Only the server edits the item position
	if owned_node and multiplayer.is_server():
		# Get the position of the player, position the item on top of the player mesh. This way the item always floats above the head.
		var destination = owned_node.global_position
		destination.y += owned_node.get_node("Pivot/Armature/Skeleton3D/MeshInstance3D").get_aabb().size.y

		# Save the new item position for synchronization
		item_position = $RigidBody3D.global_position.lerp(destination, item_follow_speed * delta)
		$RigidBody3D.global_position = item_position
