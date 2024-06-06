extends GridMap

var locationRoom = Vector3(20, 0, 0)

@export var room_amount = 15
@export var room_width = 20
@export var room_height = 20
@export var room_margin = 7


func _ready():
	for i in room_amount:
		var scene = load("res://scenes/world/generate.tscn")
		var instance = scene.instantiate()
		add_child(instance)
		instance.position = i * Vector3(room_width, 0, 0) + i * Vector3(room_margin, 0, 0)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
