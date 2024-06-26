extends GridMap

# DO NOT SPAWN
enum {PRESSUREPLATE=28}

# Items without links
enum {SMALLBOX=27, EMPTY=-1}
enum {ENEMY=88, RANGEDENEMY=89, BOSS=91, SPAWNERMELEE=92, SPAWNERRANGED=93, WELDER=90, LASERTIMER=94, DYNAMITE=143}

# Items that respond to interactables.
enum {LASERB=56, LASERG=57, LASERO=58, LASERP=59, LASERR=60, LASERY=61}
enum {DOORB=38, DOORG=39, DOORO=40, DOORP=41, DOORR=42, DOORY=43}
enum {HOLEB=44, HOLEG=45, HOLEO=46, HOLEP=47, HOLER=48, HOLEY=49}
enum {BOSSB=114, BOSSG=115, BOSSO=116, BOSSP=117, BOSSR=118, BOSSY=119}
enum {ENEMYB=120, ENEMYG=121, ENEMYO=122, ENEMYP=123, ENEMYR=124, ENEMYY=125}
enum {ENEMYRANGEDB=126, ENEMYRANGEDG=127, ENEMYRANGEDO=128, ENEMYRANGEDP=129, ENEMYRANGEDR=130, ENEMYRANGEDY=131}

var lasers = [LASERB, LASERG, LASERO, LASERP, LASERR, LASERY]
var doors = [DOORB, DOORG, DOORO, DOORP, DOORR, DOORY]
var bosses = [BOSSB, BOSSG, BOSSO, BOSSP, BOSSR, BOSSY]
var enemies = [ENEMYB, ENEMYG, ENEMYO, ENEMYP, ENEMYR, ENEMYY]
var ranged_enemies = [ENEMYRANGEDB, ENEMYRANGEDG, ENEMYRANGEDO, ENEMYRANGEDP, ENEMYRANGEDR, ENEMYRANGEDY]
var holes = [HOLEB, HOLEG, HOLEO, HOLEP, HOLER, HOLEY]

# Interactables
enum {BUTTONB=32, BUTTONG=33, BUTTONO=34, BUTTONP=35, BUTTONR=36, BUTTONY=37}
enum {MULTIPRESSUREB=62, MULTIPRESSUREG=63, MULTIPRESSUREO=64, MULTIPRESSUREP=65, MULTIPRESSURER=66, MULTIPRESSUREY=67}
enum {SOLOPRESSUREB=70, SOLOPRESSUREG=71, SOLOPRESSUREO=72, SOLOPRESSUREP=73, SOLOPRESSURER=74, SOLOPRESSUREY=75}
enum {SWITCHOFFB=76, SWITCHOFFG=77, SWITCHOFFO=78, SWITCHOFFP=79, SWITCHOFFR=80, SWITCHOFFY=81}
enum {SWITCHONB=82, SWITCHONG=83, SWITCHONO=84, SWITCHONP=85, SWITCHONR=86, SWITCHONY=87}
enum {KEYHOLEB=96, KEYHOLEG=97, KEYHOLEO=98, KEYHOLEP=99, KEYHOLER=100, KEYHOLEY=101}
enum {TERMINALB=108, TERMINALG=109, TERMINALO=110, TERMINALP=111, TERMINALR=112, TERMINALY=113}

var buttons = [BUTTONB, BUTTONG, BUTTONO, BUTTONP, BUTTONR, BUTTONY]
var multipressures = [MULTIPRESSUREB, MULTIPRESSUREG, MULTIPRESSUREO, MULTIPRESSUREP, MULTIPRESSURER, MULTIPRESSUREY]
var solopressures = [SOLOPRESSUREB, SOLOPRESSUREG, SOLOPRESSUREO, SOLOPRESSUREP, SOLOPRESSURER, SOLOPRESSUREY]
var switchesoff = [SWITCHOFFB, SWITCHOFFG, SWITCHOFFO, SWITCHOFFP, SWITCHOFFR, SWITCHOFFY]
var switcheson = [SWITCHONB, SWITCHONG, SWITCHONO, SWITCHONP, SWITCHONR, SWITCHONY]
var keyholes = [KEYHOLEB, KEYHOLEG, KEYHOLEO, KEYHOLEP, KEYHOLER, KEYHOLEY]
var terminals = [TERMINALB, TERMINALG, TERMINALO, TERMINALP, TERMINALR, TERMINALY]

# Items
enum {KEYB=50, KEYG=51, KEYO=52, KEYP=53, KEYR=54, KEYY=55}
enum {BOTTLEHEALTHL=136, BOTTLEHEALTHS=137, BOTTLEMONSTER=138, BOTTLERANDOM=139, BOTTLESMALL=140, BOTTLESPEED=141, BOTTLESTRENGTH=142}
var keys = [KEYB, KEYG, KEYO, KEYP, KEYR, KEYY]
var bottles = [BOTTLEHEALTHL, BOTTLEHEALTHS, BOTTLEMONSTER, BOTTLERANDOM, BOTTLESMALL, BOTTLESPEED, BOTTLESTRENGTH]

# Misc
enum {TELEPORTB=102, TELEPORTG=103, TELEPORTO=104, TELEPORTP=105, TELEPORTR=106, TELEPORTY=107}
var teleporters = [TELEPORTB, TELEPORTG, TELEPORTO, TELEPORTP, TELEPORTR, TELEPORTY]

# Color links
var blue = [LASERB, BUTTONB, DOORB, HOLEB, KEYB, MULTIPRESSUREB, SOLOPRESSUREB, SWITCHOFFB, SWITCHONB, BOSSB, ENEMYB, ENEMYRANGEDB, KEYHOLEB, TERMINALB]
var green = [LASERG, BUTTONG, DOORG, HOLEG, KEYG, MULTIPRESSUREG, SOLOPRESSUREG, SWITCHOFFG, SWITCHONG, BOSSG, ENEMYG, ENEMYRANGEDG, KEYHOLEG, TERMINALG]
var orange = [LASERO, BUTTONO, DOORO, HOLEO, KEYO, MULTIPRESSUREO, SOLOPRESSUREO, SWITCHOFFO, SWITCHONO, BOSSO, ENEMYO, ENEMYRANGEDO, KEYHOLEO, TERMINALO]
var purple = [LASERP, BUTTONP, DOORP, HOLEP, KEYP, MULTIPRESSUREP, SOLOPRESSUREP, SWITCHOFFP, SWITCHONP, BOSSP, ENEMYP, ENEMYRANGEDP, KEYHOLEP, TERMINALP]
var red = [LASERR, BUTTONR, DOORR, HOLER, KEYR, MULTIPRESSURER, SOLOPRESSURER, SWITCHOFFR, SWITCHONR, BOSSR, ENEMYR, ENEMYRANGEDR, KEYHOLER, TERMINALR]
var yellow = [LASERY, BUTTONY, DOORY, HOLEY, KEYY, MULTIPRESSUREY, SOLOPRESSUREY, SWITCHOFFY, SWITCHONY, BOSSY, ENEMYY, ENEMYRANGEDY, KEYHOLEY, TERMINALY]


# Main function to be called
func replace_entities(rooms : Array) -> void:
	spawn_items()
	spawn_teleporters(rooms)
	spawn_doors(rooms)
	spawn_lasers(rooms)
	replace_unused()

func remove_all_placeholder():
	var list = [88, 89, 91, 27, 92, 93, 90, 94, 143]
	list.append_array(blue)
	list.append_array(green)
	list.append_array(orange)
	list.append_array(purple)
	list.append_array(red)
	list.append_array(yellow)
	list.append_array(teleporters)
	for i in list:
		for item in get_used_cells_by_item(i):
			set_cell_item(item, EMPTY)

# %%%%%%%%%%%%
# % GENERAL %
# %%%%%%%%%%%%

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
func find_in_room(items, room, mirrored):
	var width = room[0]
	var height = room[1]
	var start = room[2]
	
	var zstart = 0 if mirrored == false else -height

	var found = []
	for x in width:
		for z in height:
			var location = Vector3i(x, 1, z) + Vector3i(start, 0, zstart)
			var item = get_cell_item(location)
			if item in items:
				found.append([item, location, get_cell_item_orientation(location)])

	return found


# Sorts an array of items on the item value
func sort_on_items(a, b) -> bool:
	if a[0] < b[0]:
		return true
	return false


# %%%%%%%%%
# % LASERS%
# %%%%%%%%%

# Handles all laser spawning
func spawn_lasers(rooms : Array) -> void:
	laser_timer()
	colored_lasers()


func laser_timer() -> void:
	for timer in get_used_cells_by_item(LASERTIMER):
		GlobalSpawner.spawn_laser(map_to_local(timer), find_laser_basis(timer), true)


# Spawns a laser at all laser spawnpoints in the map.
func colored_lasers() -> void:
	var lasers = []
	for type in [LASERB, LASERG, LASERO, LASERP, LASERR, LASERY]:
		lasers += get_used_cells_by_item(type)

	if lasers.size() == 0:
		return

	for laser in lasers:
		GlobalSpawner.spawn_laser(map_to_local(laser), find_laser_basis(laser), false)


func find_laser_basis(laser):
	var orientations = [0, 16, 10, 22]
	var new_orientations = [22, 0, 16, 10]
	var orientation = get_cell_item_orientation(laser)
	return get_basis_with_orthogonal_index(new_orientations[orientations.find(orientation)])


# %%%%%%%%%%%%%%%%%%
# % REPLACE UNUSED %
# %%%%%%%%%%%%%%%%%%

# Replaces all unused plates etc, and replaces them by dummy interactables.
func replace_unused() -> void:
	replace_plates()


func replace_plates() -> void:
	var plates = get_used_cells_by_item(PRESSUREPLATE)
	for plate in plates:
		var orientation = get_cell_item_orientation(plate)
		connect_pressureplate(null, [PRESSUREPLATE, plate, orientation])


# %%%%%%%%%
# % DOORS %
# %%%%%%%%%

# Checks each room seperately
func spawn_doors(rooms : Array) -> void:
	for room in rooms:
		spawn_doors_room(room, false)
		spawn_doors_room(room, true)


# Finds all different doors in a room and the interactables that are linked to it. It then starts
# the process of matching them.
func spawn_doors_room(room : Array, mirrored : bool) -> void:
	for item in find_in_room(doors, room, mirrored):
		var corresponding = find_in_room(corresponding_types(item[0]), room, mirrored)
		match_interactable_and_door(item, corresponding, mirrored)


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
	set_cell_item(locations[0], EMPTY)
	set_cell_item(locations[1], EMPTY)
	
	for interactable in interactables:
		if interactable == item:
			continue
		
		if interactable[0] in switcheson or interactable[0] in switchesoff:
			connect_button(door, interactable)
		if interactable[0] in multipressures or interactable[0] in solopressures:
			connect_pressureplate(door, interactable)
		if interactable[0] in bosses:
			connect_boss(door, interactable)
		if interactable[0] in keyholes:
			connect_keyhole(door, interactable)
		if interactable[0] in holes:
			connect_holes(door, interactable)
		if interactable[0] in terminals:
			connect_terminal(door, interactable)

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


# Spawns a button on the correct location, and links it to a given door.
# TODO: Inverted and non-inverted switches conflict and dont work as expected.
func connect_button(door : StaticBody3D, interactable : Array) -> void:
	var inverted = false if interactable[0] in switchesoff else true
	var location = map_to_local(interactable[1])
	location.y = 2
	var button = GlobalSpawner.spawn_button(location, get_basis_with_orthogonal_index(interactable[2]), door, inverted)
	set_cell_item(interactable[1], EMPTY)


# Spawns a pressureplate on the correct location, and links it to a given door.
func connect_pressureplate(door : StaticBody3D, interactable : Array) -> void:
	var location = map_to_local(interactable[1])
	location.y = 2
	var button = GlobalSpawner.spawn_pressure_plate(location, get_basis_with_orthogonal_index(interactable[2]), door)
	set_cell_item(interactable[1], EMPTY)


func connect_boss(door : StaticBody3D, interactable : Array) -> void:
	var location = map_to_local(interactable[1])
	location.y = 2
	var boss = GlobalSpawner.spawn_boss(location)
	boss.interactable_door = door

	set_cell_item(interactable[1], EMPTY)


func connect_keyhole(door : StaticBody3D, interactable : Array) -> void:
	var location = map_to_local(interactable[1])
	location.y = 3
	var keyhole = GlobalSpawner.spawn_keyhole(location, get_basis_with_orthogonal_index(interactable[2]), door)
	set_cell_item(interactable[1], EMPTY)
	

func connect_holes(door : StaticBody3D, interactable : Array) -> void:
	var location = map_to_local(interactable[1])
	location.y = 3
	var keyhole = GlobalSpawner.spawn_broken_wall(location, get_basis_with_orthogonal_index(interactable[2]), door)
	set_cell_item(interactable[1], EMPTY)
	

func connect_terminal(door : StaticBody3D, interactable : Array) -> void:
	var location = map_to_local(interactable[1])
	location.y = 2
	var keyhole = GlobalSpawner.spawn_terminal(location, get_basis_with_orthogonal_index(interactable[2]), door)
	set_cell_item(interactable[1], EMPTY)

# %%%%%%%%%%%%%
# % ALL ROOMS %
# %%%%%%%%%%%%%


func spawn_items() -> void:
	spawn_enemies()
	spawn_small_boxes()
	spawn_keys()
	spawn_welders()
	spawn_potions()


# Spawns a small box at all small box placeholders in the map. It then also removes the placeholder.
func spawn_small_boxes() -> void:
	var boxes = get_used_cells_by_item(SMALLBOX)
	for box in boxes:
		GlobalSpawner.spawn_box(map_to_local(box))
		set_cell_item(box, EMPTY)


# Spawns an enemy at all enemy placeholders in the map. It then also removes the placeholder.
func spawn_enemies() -> void:
	var enemies = get_used_cells_by_item(ENEMY)
	var ranged = get_used_cells_by_item(RANGEDENEMY)
	var bosses = get_used_cells_by_item(BOSS)

	for item in enemies:
		GlobalSpawner.spawn_melee_enemy(map_to_local(item))
		set_cell_item(item, EMPTY)

	for item in ranged:
		GlobalSpawner.spawn_ranged_enemy(map_to_local(item))
		set_cell_item(item, EMPTY)

	for boss in bosses:
		GlobalSpawner.spawn_boss(map_to_local(boss))
		set_cell_item(boss, EMPTY)


# Spawns a key at all key locations.
func spawn_keys() -> void:
	for key in keys:
		var items = get_used_cells_by_item(key)
		for item in items:
			GlobalSpawner.spawn_item(map_to_local(item))
			set_cell_item(item, EMPTY)


func spawn_welders() -> void:
	var items = get_used_cells_by_item(WELDER)
	for item in items:
		GlobalSpawner.spawn_item(map_to_local(item), true)
		set_cell_item(item, EMPTY)


func spawn_potions() -> void:
	for bottle in bottles:
		var items = get_used_cells_by_item(bottle)
		for item in items:
			match bottle:
				BOTTLEHEALTHS: GlobalSpawner.spawn_buff(map_to_local(item), 0, false)
				BOTTLESTRENGTH: GlobalSpawner.spawn_buff(map_to_local(item), 1, false)
				BOTTLEHEALTHL: GlobalSpawner.spawn_buff(map_to_local(item), 2, false)
				BOTTLESPEED: GlobalSpawner.spawn_buff(map_to_local(item), 3, false)
				BOTTLERANDOM: GlobalSpawner.spawn_buff(map_to_local(item), 0)
			set_cell_item(item, EMPTY)


# %%%%%%%%%%%%%%%
# % TELEPORTERS %
# %%%%%%%%%%%%%%%


# Runs the teleporter spawning for all rooms
func spawn_teleporters(rooms : Array) -> void:
	for room in rooms:
		spawn_teleporters_room(room, false)
		spawn_teleporters_room(room, true)


# Finds all teleporters in a given room and links them
func spawn_teleporters_room(room : Array, mirrored : bool) -> void:
	var items = find_in_room(teleporters, room, mirrored)
	items.sort_custom(sort_on_items)
	#assert(items.size() % 2 == 0)
	print(room)
	for i in range(0, items.size(), 2):
		var location1 = map_to_local(items[i][1])
		var basis1 = get_basis_with_orthogonal_index(items[i][2])
		var location2 = map_to_local(items[i + 1][1])
		var basis2 = get_basis_with_orthogonal_index(items[i + 1][2])
		
		GlobalSpawner.spawn_portal(location1, basis1, location2, basis2)
		
		set_cell_item(items[i][1], EMPTY)
		set_cell_item(items[i + 1][1], EMPTY)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
