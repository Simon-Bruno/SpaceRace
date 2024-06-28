extends Node3D

# Initial speed
var speed = 0.0

# Acceleration rate (units per second squared)
const ACCELERATION = 5.0

@onready var mesh = $"../SpaceshuttleV2"
@onready var portal_effect = $"../Assets/floors/VFX_PORTAL_ENTRANCE/EntrancePortal"

# Flag to check if the object has started moving
var has_started_moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Increase the speed by the acceleration multiplied by the delta time
	speed += ACCELERATION * delta
	
	# Move the shuttle to the left
	position += transform.basis * Vector3(0, speed/30, -speed/1.6) * delta
	
	# Check if the object has started moving
	#if not has_started_moving and speed > 0:
		#has_started_moving = true
		#change_portal_effect()
#
## Function to change the portal effect
#func change_portal_effect():
	#if portal_effect:
		#var newMaterial = StandardMaterial3D.new()
		##newMaterial.albedo_color = Color(188.0,233.0,84.0)
		##portal_effect.material_override = newMaterial
		
