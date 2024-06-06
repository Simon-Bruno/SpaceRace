extends Camera3D

var ZoomMin = Vector2(0.25,0.25)
var ZoomMax = Vector2(2.5,2.5)
var ZoomSpd = Vector2(0.3,0.3)
var PanSpeedKey = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_pressed("MoveCamUp"):
		position.y += PanSpeedKey
	if Input.is_action_pressed("MoveCamDown"):
		position.y -= PanSpeedKey
	if Input.is_action_pressed("MoveCamLeft"):
		position.x -= PanSpeedKey
	if Input.is_action_pressed("MoveCamRight"):
		position.x += PanSpeedKey
	if Input.is_action_pressed("MoveCamForward"):
		position.z -= PanSpeedKey
	if Input.is_action_pressed("MoveCamBackward"):
		position.z += PanSpeedKey
	pass
