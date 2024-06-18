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

var lasers = [LASERB, LASERG, LASERO, LASERP, LASERR, LASERY]
var buttons = [BUTTONB, BUTTONG, BUTTONO, BUTTONP, BUTTONR, BUTTONY]
var doors = [DOORB, DOORG, DOORO, DOORP, DOORR, DOORY]
var keys = [KEYB, KEYG, KEYO, KEYP, KEYR, KEYY]
var multipressures = [MULTIPRESSUREB, MULTIPRESSUREG, MULTIPRESSUREO, MULTIPRESSUREP, MULTIPRESSURER, MULTIPRESSUREY]
var solopressures = [SOLOPRESSUREB, SOLOPRESSUREG, SOLOPRESSUREO, SOLOPRESSUREP, SOLOPRESSURER, SOLOPRESSUREY]

var blue = [LASERB, BUTTONB, DOORB, HOLEB, KEYB, MULTIPRESSUREB, SOLOPRESSUREB]
var green = [LASERG, BUTTONG, DOORG, HOLEG, KEYG, MULTIPRESSUREG, SOLOPRESSUREG]
var orange = [LASERO, BUTTONO, DOORO, HOLEO, KEYO, MULTIPRESSUREO, SOLOPRESSUREO]
var purple = [LASERP, BUTTONP, DOORP, HOLEP, KEYP, MULTIPRESSUREP, SOLOPRESSUREP]
var red = [LASERR, BUTTONR, DOORR, HOLER, KEYR, MULTIPRESSURER, SOLOPRESSURER]
var yellow = [LASERY, BUTTONY, DOORY, HOLEY, KEYY, MULTIPRESSUREY, SOLOPRESSUREY]


# Main function to be called
func replace_entities(rooms : Array) -> void:
	spawn_enemies()
	spawn_lasers()
	spawn_doors(rooms)


# Checks each room seperately
func spawn_doors(rooms : Array) -> void:
	for i in rooms:
		spawn_doors_room(i)


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
func find_in_room(items, width, height, start):
	var found = []
	for x in width:
		for z in height:
			var location = Vector3i(x, 1, z) + Vector3i(start, 0, 0)
			var item = get_cell_item(location)
			if item in items:
				found.append([item, location, get_cell_item_orientation(location)])

	return found


# Returns the locations of two doors dependent on the left door as input.
func return_door_pair(location : Vector3i, direction : int) -> Array:
	var new_location = Vector3i(0, 0, 0)
	match direction:
		0: new_location = Vector3i(1, 0, 0)
		16: new_location = Vector3i(0, 0, -1)
		10: new_location = Vector3i(-1, 0, 0)
		22: new_location = Vector3i(0, 0, 1)
		
	return [location, location + new_location]
	

func remove_current_items(location : Vector3i) -> void:
	#statics.set_cell_item(location, EMPTY)
	set_cell_item(location, EMPTY)


func match_interactable_and_door(item : Array, interactables : Array) -> void:
	var locations = return_door_pair(item[1], item[2])
	var actual_location = (map_to_local(locations[0]) + map_to_local(locations[1])) / 2
	actual_location.y = 2
	var door = GlobalSpawner.spawn_door(actual_location, get_basis_with_orthogonal_index(item[2]), interactables.size() - 1)
	# TODO: Doors seems to not be perfectly centered. This will be fixed later.
	remove_current_items(locations[0])
	remove_current_items(locations[1])
	
	for interact in interactables:
		if interact == item:
			continue
			
		var location = map_to_local(interact[1])
		location.y = 2
		var button = GlobalSpawner.spawn_button(location, get_basis_with_orthogonal_index(interact[2]), door, false)
		remove_current_items(interact[1])
		

func spawn_doors_room(room : Array) -> void:
	var width = room[0]
	var height = room[1]
	var start = room[2]

	# Find all door types.
	var current = find_in_room(doors, room[0], room[1], room[2])
	
	# Find all items that correspond to the door
	for item in current:
		var corresponding = find_in_room(corresponding_types(item[0]), room[0], room[1], room[2])
		match_interactable_and_door(item, corresponding)


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
		self.set_cell_item(item, EMPTY)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
