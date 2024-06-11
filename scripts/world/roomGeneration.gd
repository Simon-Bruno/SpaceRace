extends Node3D

@onready var world = get_parent()

var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
var laser_scene = preload("res://scenes/interactables/laser.tscn")
var item_scene = preload("res://scenes/item/item.tscn")
var box_scene = preload("res://scenes/interactables/moveable_items.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	if world.generate_room:
		fill_room()


func fill_room():
	var room = world.room
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(5, 30), randi_range(1, room[1] * 2 - 1))
	add_child(enemy, true)
	var laser = laser_scene.instantiate()
	laser.position = Vector3i(1, 3, 5)
	add_child(laser, true)
	var item = item_scene.instantiate()
	item.position = Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(3, 10), randi_range(1, room[1] * 2 - 1))
	add_child(item, true)
	var box = box_scene.instantiate()
	box.position = Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(3, 10), randi_range(1, room[1] * 2 - 1))
	add_child(box)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
