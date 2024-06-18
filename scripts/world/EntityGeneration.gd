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


func replace_entities() -> void:
	spawn_enemies()
	spawn_lasers()
	#spawn_doors()


func spawn_doors() -> void:
	var roomLayouts = statics.rooms
	
	for i in roomLayouts:
		spawn_doors_room(i)
	


func spawn_doors_room(room : Array) -> void:
	var width = room[0]
	var height = room[1]
	var start = room[2]

	
	

#func spawn_door(doorLoc, )


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
