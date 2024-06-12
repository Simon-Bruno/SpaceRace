extends Node


var fps_state : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	Network.on_fps_toggled.connect(on_fps_toggled)


func on_fps_toggled(value : bool):
	fps_state = value
	#print(fps_state)


func get_fps_state():
	return fps_state


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
