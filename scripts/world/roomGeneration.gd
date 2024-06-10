extends Node3D

@onready var world = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	var room = world.room
	var enemy = preload("res://scenes/enemy/enemy.tscn").instantiate()
	enemy.position = Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(5, 30), randi_range(1, room[1] * 2 - 1))
	add_child(enemy, true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
