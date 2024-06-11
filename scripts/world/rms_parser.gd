extends Node


# Called when the node enters the scene tree for the first time.
func parse_file(filepath : String):
	var dict : Dictionary = {}
	var file = FileAccess.open(filepath, FileAccess.READ)
	print(file.get_as_text())

