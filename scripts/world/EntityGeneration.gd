extends GridMap

@onready var statics : GridMap = get_node("../WorldGeneration")

enum {SMALLBOX=27, ENEMY=88, EMPTY=-1}

enum {LASERB=56, LASERG=57, LASERO=58, LASERP=59, LASERR=60, LASERY=61}
enum {BUTTONB=32, BUTTONG=33, BUTTONO=34, BUTTONP=35, BUTTONR=36, BUTTONY=37}
enum {DOORB=38, DOORG=39, DOORO=40, DOORP=41, DOORR=42, DOORY=43}
enum {HOLEB=44, HOLEG=45, HOLEO=46, HOLEP=47, HOLER=48, HOLEY=49}
enum {KEYB=50, KEYG=51, KEYO=52, KEYP=53, KEYR=54, KEYY=55}
enum {MULTIPRESSUREB=62, MULTIPRESSUREG=63, MULTIPRESSUREO=64, MULTIPRESSUREP=65, MULTIPRESSURER=66, MULTIPRESSUREY=67}
enum {SOLOPRESSUREB=70, SOLOPRESSUREG=71, SOLOPRESSUREO=72, SOLOPRESSUREP=73, SOLOPRESSURER=74, SOLOPRESSUREY=75}
enum {SWITCHOFFB=76, SWITCHOFFG=77, SWITCHOFFO=78, SWITCHOFFP=79, SWITCHOFFR=80, SWITCHOFFY=81}
enum {SWITCHONB=82, SWITCHONG=83, SWITCHONO=84, SWITCHONP=85, SWITCHONR=86, SWITCHONY=87}

var lasers = [LASERB, LASERG, LASERO, LASERP, LASERR, LASERY]
var buttons = [BUTTONB, BUTTONG, BUTTONO, BUTTONP, BUTTONR, BUTTONY]
var doors = [DOORB, DOORG, DOORO, DOORP, DOORR, DOORY]
var keys = [KEYB, KEYG, KEYO, KEYP, KEYR, KEYY]
var multipressures = [MULTIPRESSUREB, MULTIPRESSUREG, MULTIPRESSUREO, MULTIPRESSUREP, MULTIPRESSURER, MULTIPRESSUREY]
var solopressures = [SOLOPRESSUREB, SOLOPRESSUREG, SOLOPRESSUREO, SOLOPRESSUREP, SOLOPRESSURER, SOLOPRESSUREY]
var switchesoff = [SWITCHOFFB, SWITCHOFFG, SWITCHOFFO, SWITCHOFFP, SWITCHOFFR, SWITCHOFFY]
var switcheson = [SWITCHONB, SWITCHONG, SWITCHONO, SWITCHONP, SWITCHONR, SWITCHONY]

var blue = [LASERB, BUTTONB, DOORB, HOLEB, KEYB, MULTIPRESSUREB, SOLOPRESSUREB, SWITCHOFFB, SWITCHONB]
var green = [LASERG, BUTTONG, DOORG, HOLEG, KEYG, MULTIPRESSUREG, SOLOPRESSUREG, SWITCHOFFG, SWITCHONG]
var orange = [LASERO, BUTTONO, DOORO, HOLEO, KEYO, MULTIPRESSUREO, SOLOPRESSUREO, SWITCHOFFO, SWITCHONO]
var purple = [LASERP, BUTTONP, DOORP, HOLEP, KEYP, MULTIPRESSUREP, SOLOPRESSUREP, SWITCHOFFP, SWITCHONP]
var red = [LASERR, BUTTONR, DOORR, HOLER, KEYR, MULTIPRESSURER, SOLOPRESSURER, SWITCHOFFR, SWITCHONR]
var yellow = [LASERY, BUTTONY, DOORY, HOLEY, KEYY, MULTIPRESSUREY, SOLOPRESSUREY, SWITCHOFFY, SWITCHONY]

var remove = []

# Main function to be called
func replace_entities(rooms : Array) -> Array:
	spawn_enemies()
	spawn_lasers()
	spawn_small_boxes()
	spawn_doors(rooms)
	
	return remove


# Checks each room seperately
func spawn_doors(rooms : Array) -> void:
	for room in rooms:
		spawn_doors_room(room, false)
		spawn_doors_room(room, true)


# Matches a door with its color type
func corresponding_types(door : int) -> Array:
	match door:
		DOORB: return blue
		DOORG: return green
		DOORO: return orange
		DOORP: return purple
		DOORR: return red
		DOORY: return yellow
		_: get_tree().quit(); return []


# Tries to find an item in a certain room, and returns all instances.
func find_in_room(items, width, height, start, zvalue):
	var found = []
	for x in width:
		for z in height:
			var location = Vector3i(x, 1, z) + Vector3i(start, 0, zvalue)
			var item = get_cell_item(location)
			if item in items:
				found.append([item, location, get_cell_item_orientation(location)])

	return found


# Returns the locations of two doors dependent on the left door as input.
func return_door_pair(location : Vector3i, direction : int, mirrored : bool) -> Array:
	var new_location = Vector3i(0, 0, 0)
	if mirrored:
		match direction:
			0: new_location = Vector3i(-1, 0, 0)
			16: new_location = Vector3i(0, 0, 1)
			10: new_location = Vector3i(1, 0, 0)
			22: new_location = Vector3i(0, 0, -1)
		return [location, location + new_location]
	else:
		match direction:
			0: new_location = Vector3i(1, 0, 0)
			16: new_location = Vector3i(0, 0, -1)
			10: new_location = Vector3i(-1, 0, 0)
			22: new_location = Vector3i(0, 0, 1)
		return [location + new_location, location]


# Removes item from dynamic gridmap and adds them to list to be passed to static layer.
func remove_current_items(location : Vector3i) -> void:
	remove.append(location)
	set_cell_item(location, EMPTY)


# This funcion matches all doors with the appropriate buttons, and binds them to work as expected.
func match_interactable_and_door(item : Array, interactables : Array, mirrored : bool) -> void:
	var locations = return_door_pair(item[1], item[2], mirrored)
	var actual_location = (map_to_local(locations[0]) + map_to_local(locations[1])) / 2
	actual_location.y = 2
	
	var total_interactions = interactables.size() - 1
	for interactable in interactables:
		if interactable[0] in solopressures:
			total_interactions = 1
	
	var door = GlobalSpawner.spawn_door(actual_location, get_basis_with_orthogonal_index(item[2]), total_interactions)
	remove_current_items(locations[0])
	remove_current_items(locations[1])
	
	for interactable in interactables:
		if interactable == item:
			continue
		
		if interactable[0] in switcheson or interactable[0] in switchesoff:
			connect_button(door, interactable)
		if interactable[0] in multipressures or interactable[0] in solopressures:
			connect_pressureplate(door, interactable)


# Spawns a pressureplate on the correct location, and links it to a given door.
func connect_pressureplate(door : StaticBody3D, interactable : Array) -> void:
	var location = map_to_local(interactable[1])
	location.y = 2
	var button = GlobalSpawner.spawn_pressure_plate(location, get_basis_with_orthogonal_index(interactable[2]), door)
	remove_current_items(interactable[1])


# Spawns a button on the correct location, and links it to a given door.
# TODO: Inverted and non-inverted switches conflict and dont work as expected.
func connect_button(door : StaticBody3D, interactable : Array) -> void:
	var inverted = false if interactable[0] in switchesoff else true
	var location = map_to_local(interactable[1])
	location.y = 2
	var button = GlobalSpawner.spawn_button(location, get_basis_with_orthogonal_index(interactable[2]), door, inverted)
	remove_current_items(interactable[1])


# Finds all different doors in a room and the interactables that are linked to it. It then starts
# the process of matching them.
func spawn_doors_room(room : Array, mirrored : bool) -> void:
	var width = room[0]
	var height = room[1]
	var start = room[2]
	
	var zstart = 0 if mirrored == false else -height
	
	

	# Find all door types.
	var current = find_in_room(doors, width, height, start, zstart)
	
	# Find all items that correspond to the door
	for item in current:
		var corresponding = find_in_room(corresponding_types(item[0]), width, height, start, zstart)
		match_interactable_and_door(item, corresponding, mirrored)


# Spawns a small box at all small box placeholders in the map. It then also removes the placeholder.
func spawn_small_boxes() -> void:
	var boxes = get_used_cells_by_item(SMALLBOX)
	for box in boxes:
		GlobalSpawner.spawn_box(map_to_local(box))
		remove_current_items(box)


# Spawns a laser at all laser spawnpoints in the map.
func spawn_lasers() -> void:
	var lasers = []
	for type in [LASERB, LASERG, LASERO, LASERP, LASERR, LASERY]:
		lasers += get_used_cells_by_item(type)

	if lasers.size() == 0:
		return

	for laser in lasers:
		var orientations = [0, 16, 10, 22]
		var new_orientations = [22, 0, 16, 10]
		var orientation = get_cell_item_orientation(laser)
		orientation = get_basis_with_orthogonal_index(new_orientations[orientations.find(orientation)])
		GlobalSpawner.spawn_laser(map_to_local(laser), orientation)


# Spawns an enemy at all enemy placeholders in the map. It then also removes the placeholder.
func spawn_enemies() -> void:
	var enemies = get_used_cells_by_item(ENEMY)
	for item in enemies:
		GlobalSpawner.spawn_melee_enemy(map_to_local(item))
		remove_current_items(item)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
