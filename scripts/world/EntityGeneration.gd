extends GridMap

enum {SMALLBOX=27, ENEMY=88, EMPTY=-1}

enum {LASERB=56, LASERG=57, LASERO=58, LASERP=59, LASERR=60, LASERY=61}


func replace_entities() -> void:
	spawn_enemies()
	spawn_lasers()


# Spawns a laser at all laser spawnpoints in the map.
func spawn_lasers() -> void:
	var lasers = []
	for type in [LASERB, LASERG, LASERO, LASERP, LASERR, LASERY]:
		lasers += get_used_cells_by_item(type)

	if lasers.size() == 0:
		return

	print(lasers)

	for laser in lasers:
		var orientations = [0, 16, 10, 22]
		var new_orientations = [22, 10, 16, 0]
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
