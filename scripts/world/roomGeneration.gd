extends Node3D

@onready var world = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	if world.generate_room:
		fill_room()


func fill_room():
	var room = world.room
	var enemy = load("res://scenes/enemy/enemy.tscn").instantiate()
	var x = randi_range(1, room[0] * 2 - 1)
	var y = randi_range(5, 30)
	var z = randi_range(1, room[1] * 2 - 1)
	enemy.position = Vector3i(x, y, z)
	add_child(enemy, true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
