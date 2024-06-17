extends GridMap

enum {SMALLBOX=27, ENEMY=88, EMPTY=-1}


func replace_entities() -> void:
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
