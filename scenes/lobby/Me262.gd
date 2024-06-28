extends Node3D

# Initial speed.
var speed = 0.0

# Acceleration rate (units per second squared).
const ACCELERATION = 5.0

@onready var mesh = $"../SpaceshuttleV2"
@onready var portal_effect = $"../Assets/floors/VFX_PORTAL_ENTRANCE/EntrancePortal"

# Flag to check if the object has started moving.
var has_started_moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Increases the speed by the acceleration multiplied by the delta time.
	speed += ACCELERATION * delta
	
	# Move the shuttle to the left.
	position += transform.basis * Vector3(0, speed/30, -speed/1.6) * delta
