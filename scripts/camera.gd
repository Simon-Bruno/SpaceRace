extends Camera3D

# Reference to the player nodes
var player: Node = null
var player2: Node = null

func _ready():
	# Ensure the player nodes are assigned
	if multiplayer.is_server():
		Network.player_spawned.connect(add_new_player)
		$"../MultiplayerSynchronizer".set_multiplayer_authority(multiplayer.get_unique_id())
	
func add_new_player(object, id):
	if not player:
		player = object
	else:
		player2 = object

# calculate how many players are in the team
func get_player_count():
	var playercount: int = 0
	if player:
		playercount += 1
	if player2:
		playercount += 1
	return playercount


# calculate the total x-values of the players in a team
func calc_total_x(player_count):
	var total_x: float = 0.0
	total_x += player.global_transform.origin.x
	if player_count == 2:
		total_x += player2.global_transform.origin.x
	return total_x        



# modify the current camera position
func modify_camera_pos(average_x):
	# Get the camera position
	var camera_position = global_transform.origin
	
	# Update only the x-axis of the camera position
	camera_position.x = average_x
	
	# Set the new position back to the camera
	global_transform.origin = camera_position


# Make sure the camera only moves in the X-axis
func _process(_delta):
	var player_count: int = get_player_count()

	# Calculate the average x position if there are players in the team
	if player_count > 0:
		var total_x: float = calc_total_x(player_count)
		var average_x: float = total_x / player_count

		modify_camera_pos(average_x)
