extends Node

var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
var laser_scene = preload("res://scenes/interactables/laser.tscn")
var item_scene = preload("res://scenes/item/item.tscn")
var box_scene = preload("res://scenes/interactables/moveable_object.tscn")
var button_scene = preload("res://scenes/interactables/button.tscn")
var pressure_plate_scene = preload("res://scenes/interactables/pressure_plate.tscn")

func spawn_melee_enemy(pos):
	var spawner = get_tree().get_node_or_null("/root/Main/SpawnedItems/World/EnemySpawner")
	if spawner:
		var enemy = enemy_scene.instantiate()
		enemy.position = pos
		spawner.add_child(enemy, true)

func spawn_laser(pos, dir):
	var spawner = get_tree().get_node_or_null("/root/Main/SpawnedItems/World/ProjectileSpawner")
	if spawner:
		var laser = enemy_scene.instantiate()
		laser.position = pos
		laser.basis	= dir
		spawner.add_child(laser, true)
