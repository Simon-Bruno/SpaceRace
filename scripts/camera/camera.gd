extends Camera3D

# Reference to the player node
@export var player_path: NodePath
var player: Node = null

func _ready():
	# Ensure the player node is assigned
	player = get_node(player_path)

# Make sure the camera only moves in the X-axis
func _process(delta):
	if player:
		# Get the player's current position
		var player_position = player.global_transform.origin
		
		# Get the camera's current position
		var camera_position = global_transform.origin
		
		# Update only the x-axis of the camera position
		camera_position.x = player_position.x
		
		# Set the new position back to the camera
		global_transform.origin = camera_position
