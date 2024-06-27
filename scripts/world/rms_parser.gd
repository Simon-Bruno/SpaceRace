extends Node


var wall_test = [ {"set_min_distance": 5, "set_max_distance": 8, "length": 6, "length_variation": 2 }, { "set_min_distance": 4, "set_max_distance": 6, "length": 3, "length_variation": 1 } ]
var object_test = [ { "set_min_distance": 8, "set_max_distance": 10, "set_length": 3, "type": "LASER" }, { "set_min_distance": 17, "set_max_distance": 20, "type": "ITEM" }, { "set_min_distance": 4, "set_max_distance": 9, "type": "ITEM" } ]
var enemy_test = [ { "set_min_distance": 5, "set_max_distance": 8, "set_group_size": 3, "loose_grouping": true } ]

# This function is purely a unit check, since this will never be loaded
# in the main project.
func _ready():
	var rms_dict = parse_file("res://files/random_map_scripts/test.rms")
	print(rms_dict)
	assert(rms_dict['walls'] == wall_test, "The walls were not parsed correctly")
	print("The walls get parsed correctly")
	assert(rms_dict['objects'] == object_test, "The objects were not parsed correctly")
	print("The objects get parsed correctly")
	assert(rms_dict['enemies'] == enemy_test, "The enemies were not parsed correctly")
	print("The enemies got parsed correctly")
	print("All tests passed")

# Called when the node enters the scene tree for the first time.
func parse_file(filepath : String) -> Dictionary:
	var dict : Dictionary = {}
	var file = FileAccess.open(filepath, FileAccess.READ)
	var data = file.get_as_text()
	var sections = data.split("<", false)
	for section in sections:
		if section.begins_with("WALL_SETUP"):
			dict['walls'] = []
			wall_parser(section, dict['walls'])
		elif section.begins_with("OBJECTS_GENERATION"):
			dict['objects'] = []
			object_parser(section, dict['objects'])
		elif section.begins_with("ENEMY_GENERATION"):
			dict['enemies'] = []
			enemies_parser(section, dict['enemies'])
	return dict

func segment_to_dict(segment : String) -> Dictionary:
	var dict = {}
	if not segment.begins_with("{"):
		return {}
	var lines = segment.split('\n', false)
	for line in lines:
		line = line.strip_edges()
		if line == "":
			continue
		line = line.split(" ", false, 1)
		if line[0] == "type":
			dict["type"] = line[1]
		elif line[0] == 'buff_type':
			dict['buff_type'] = line[1]
		elif len(line) > 1:
			dict[line[0]] = int(line[1])
		elif line[0] == "set_loose_grouping":
			dict['loose_grouping'] = true
			
	return dict

func wall_parser(section: String, wall_dict : Array) -> void:
	var walls = section.split("create_wall")
	for i in walls.size():
		var wall = walls[i].strip_edges()
		var parsed_wall : Dictionary = segment_to_dict(wall)
		if parsed_wall == {}:
			continue
		wall_dict.append(parsed_wall)

func object_parser(section: String, object_dict : Array) -> void:
	var objects = section.split('create_object')
	for i in objects.size():
		# Get an object from the list
		var object = objects[i]
		# The object might just be the section divider
		if object.begins_with("OBJECTS_GENERATION"):
			continue
		# Preprocess the object by stripping the edges and extracting the type of object
		object = object.strip_edges().split("\n", false, 1)
		var type = object[0]
		# Convert it to a dictionary for the object
		var parsed_object : Dictionary = segment_to_dict(object[1])
		# Do a safety check if segment_to_dict works.
		if parsed_object == {}:
			continue
		# Set the type of object
		parsed_object['type'] = type
		# Set the object in the dictionary of objects
		object_dict.append(parsed_object)

func enemies_parser(section : String, enemy_dict : Array) -> void:
	var mobs = section.split('create_mob')
	for i in mobs.size():
		var mob = mobs[i].strip_edges()
		if mob.begins_with("ENEMY_GENERATION"):
			continue
		mob = mob.split("\n", false, 1)
		var type = mob[0]
		var parsed_mob : Dictionary = segment_to_dict(mob[1])
		if parsed_mob == {}:
			continue
		if not parsed_mob.has('loose_grouping'):
			parsed_mob['loose_grouping'] = false
		parsed_mob['type'] = type
		enemy_dict.append(parsed_mob)
