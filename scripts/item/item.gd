extends Node3D

# make sure only one person holds the item
@export var owned = false
@export var owned_node : Node3D = null
# how fast the item should follow the player
var item_follow_speed = 15

# animation vars
var rotation_speed = 0.5
var bob_frequency = 0.25
var bob_amplitude = 0.25
var bob_offset = 0.25
var bob_time = 0.0

@export var item_position : Vector3
var initial_position = Vector3()

func _enter_tree():
	if multiplayer.is_server():
		$MultiplayerSynchronizer.set_multiplayer_authority(multiplayer.get_unique_id())

func _ready():
	initial_position = $RigidBody3D/MeshOrigin.position
	item_position = $RigidBody3D.global_position

func _animate(delta):
	"""Makes the item rotate and bob up and down"""

	# rotate by rotating the origin
	$RigidBody3D/MeshOrigin.rotate_y(rotation_speed * delta)

	# bobbing by translating the origin
	bob_time += delta
	# TAU is 2*PI
	var new_y = bob_offset + initial_position.y + bob_amplitude * sin(bob_time * bob_frequency * TAU)
	$RigidBody3D/MeshOrigin.position = Vector3(initial_position.x, new_y, initial_position.z)

# Deletes the item after consuming/using it
@rpc("authority", "call_local", "reliable")
func delete():
	if not multiplayer.is_server() or not owned_node:
		queue_free()
		return

	var node = owned_node.get_node("PlayerItem")
	node.holding = null # Player stops holding item / forgets item
	queue_free()

func _process(delta):
	_animate(delta)
	if owned_node and multiplayer.is_server():

		var destination = owned_node.global_position
		destination.y += owned_node.get_node("Pivot/Armature/Skeleton3D/MeshInstance3D").get_aabb().size.y

		# Nodig voor het syncen
		item_position = $RigidBody3D.global_position.lerp(destination, item_follow_speed * delta)

		$RigidBody3D.global_position = item_position
