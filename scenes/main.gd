extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	$SpawnedItems.add_child(preload("res://scenes/menu/menu.tscn").instantiate())
