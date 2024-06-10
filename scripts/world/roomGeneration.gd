extends Node3D

@onready var world = get_parent()


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 3:
		var enemy = preload("res://scenes/enemy/enemy.tscn").instantiate()
		enemy.position = Vector3(randi_range(1, world.room_width - 1),20,randi_range(1, world.room_height - 1))
		add_child(enemy)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
