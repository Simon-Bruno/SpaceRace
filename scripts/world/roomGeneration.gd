extends Node3D

@onready var world = get_parent()

var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
var laser_scene = preload("res://scenes/interactables/laser.tscn")
var item_scene = preload("res://scenes/item/item.tscn")
var box_scene = preload("res://scenes/interactables/moveable_object.tscn")
var button_scene = preload("res://scenes/interactables/button.tscn")
var pressure_plate_scene = preload("res://scenes/interactables/pressure_plate.tscn")
var door_scene = preload("res://scenes/interactables/door.tscn")

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
	
	var door = door_scene.instantiate()
	door.position = Vector3i(randi_range(1, room[0] * 2 - 1), 2, randi_range(1, room[1] * 2 - 1))
	add_child(door)
	door.activation_count = 2
	
	var button = button_scene.instantiate()
	button.position = Vector3i(randi_range(1, room[0] * 2 - 1), 2, randi_range(1, room[1] * 2 - 1))
	add_child(button)
	button.interactable = door
	
	var button2 = button_scene.instantiate()
	button2.position = Vector3i(randi_range(1, room[0] * 2 - 1), 2, randi_range(1, room[1] * 2 - 1))
	add_child(button2)
	button2.interactable = door

#func _process(delta):
	#pass
