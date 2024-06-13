extends Node3D

func _ready():
	var ranged = preload("res://scenes/characters/ranged_enemy/ranged_enemy.tscn").instantiate()
	ranged.position = Vector3(2,20,4)
	add_child(ranged, true)
