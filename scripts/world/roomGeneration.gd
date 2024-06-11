extends Node3D

@onready var world = get_parent()

var parser = preload("res://scripts/world/rms_parser.gd").new()

var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
var laser_scene = preload("res://scenes/interactables/laser_beam.tscn")
var item_scene = preload("res://scenes/item/item.tscn")
var box_scene = preload("res://scenes/interactables/moveable_object.tscn")

func _ready():
	if world.generate_room:
		var filename = "res://files/random_map_scripts/test.rms"
		var world_dict : Dictionary = parser.parse_file(filename)
		fill_room()


func fill_room():
	var room = world.room
	
	var enemy = enemy_scene.instantiate()
	enemy.position = Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(5, 30), randi_range(1, room[1] * 2 - 1))
	add_child(enemy, true)
	
	var laser = laser_scene.instantiate()
	laser.position = Vector3i(2, 3, 5)
	add_child(laser, true)
	
	var item = item_scene.instantiate()
	item.position = Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(3, 10), randi_range(1, room[1] * 2 - 1))
	add_child(item, true)
	
	var box = box_scene.instantiate()
	box.position = Vector3i(randi_range(1, room[0] * 2 - 1), randi_range(3, 10), randi_range(1, room[1] * 2 - 1))
	add_child(box)

#func _process(delta):
	#pass
