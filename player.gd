extends Node3D

var mouse_sensitivity = 0.2
var speed = 10
@export var score = 0

@onready var camera = $Camera3D
@onready var synchronizer = $MultiplayerSynchronizer
@onready var scoreLabel = $Score

func _ready():
	synchronizer.set_multiplayer_authority(str(name).to_int())
	camera.current = synchronizer.is_multiplayer_authority()

# Called every frame to move the player
func _physics_process(delta):
	var direction = Vector3.ZERO
	if Input.is_key_pressed(KEY_W): direction += global_transform.basis.z
	elif Input.is_key_pressed(KEY_S): direction -= global_transform.basis.z
	if Input.is_key_pressed(KEY_A): direction += global_transform.basis.x
	elif Input.is_key_pressed(KEY_D): direction -= global_transform.basis.x
	
	global_position += direction.normalized() * speed * delta
	score += 1
	scoreLabel.text = str(score)


# Called every time the mouse is moved, in order to move the camera
func _input(event):
	if event is InputEventKey and event.is_pressed() and event.keycode == KEY_ESCAPE:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE else Input.MOUSE_MODE_VISIBLE
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CONFINED_HIDDEN:
			rotate_y(-deg_to_rad(event.relative.x) * mouse_sensitivity)
			camera.rotate_x(deg_to_rad(event.relative.y) * mouse_sensitivity)
