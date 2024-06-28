extends Node

var enemy_scene = preload("res://scenes/enemy/enemy.tscn")
var ranged_enemy_scene = preload("res://scenes/characters/ranged_enemy/ranged_enemy.tscn")
var laser_scene = preload("res://scenes/interactables/laser.tscn")
var item_scene = preload("res://scenes/item/key.tscn")
var welder_scene = preload("res://scenes/item/welder.tscn")
var hp_bottle_scene = preload("res://scenes/item/hp_bottle.tscn")
var full_hp_bottle_scene = preload("res://scenes/item/full_health_bottle.tscn")
var strength_bottle_scene = preload("res://scenes/item/strength_bottle.tscn")
var speed_bottle_scene = preload("res://scenes/item/speed_bottle.tscn")
var bomb_scene = preload("res://scenes/item/bomb.tscn")
var box_scene = preload("res://scenes/interactables/moveable_object.tscn")
var button_scene = preload("res://scenes/interactables/button.tscn")
var door_scene = preload("res://scenes/interactables/door.tscn")
var pressure_plate_scene = preload("res://scenes/interactables/pressure_plate.tscn")
var terminal_scene = preload("res://scenes/interactables/terminal.tscn")
var portal_scene = preload("res://scenes/interactables/portal.tscn")
var boss_scene = preload("res://scenes/characters/boss.tscn")
var projectile_scene = preload("res://scenes/characters/ranged_enemy/projectile.tscn")
var wall_scene = preload("res://scenes/world/intern_wall.tscn")
var keyhole_scene = preload("res://scenes/interactables/keyhole.tscn")
var jump_laser_scene = preload("res://scenes/interactables/laser_low.tscn")
var broken_wall_scene = preload("res://scenes/interactables/broken_wall.tscn")

func spawn_broken_wall(pos, dir, interact):
	if not multiplayer.is_server():
		return
	var spawner = get_node_or_null("/root/Main/SpawnedItems/World/InteractableSpawner")
	if spawner:
		var broken_wall = broken_wall_scene.instantiate()
		broken_wall.position = pos
		broken_wall.basis	= dir
		broken_wall.interactable = interact
		spawner.add_child(broken_wall, true)
		return broken_wall
	return null

func spawn_keyhole(pos, dir, interact):
	if not multiplayer.is_server():
		return
	var spawner = get_node_or_null("/root/Main/SpawnedItems/World/InteractableSpawner")
	if spawner:
		var keyhole = keyhole_scene.instantiate()
		keyhole.position = pos
		keyhole.basis	= dir
		keyhole.interactable = interact
		spawner.add_child(keyhole, true)
		return keyhole
	return null

func spawn_pressure_plate(pos, dir, interact=null, pos_enemy=null):
	if not multiplayer.is_server():
		return
	var spawner = get_node_or_null("/root/Main/SpawnedItems/World/InteractableSpawner")
	if spawner:
		var plate = pressure_plate_scene.instantiate()
		plate.position = pos
		plate.basis	= dir
		plate.interactable = interact
		if pos_enemy != null:
			plate.enemy_pos = pos_enemy
		spawner.add_child(plate, true)
		return plate
	return null

func spawn_portal(pos1, dir1, pos2, dir2):
	if not multiplayer.is_server():
		return
	var spawner = get_node_or_null("/root/Main/SpawnedItems/World/InteractableSpawner")
	if spawner:
		var portal1 = portal_scene.instantiate()
		var portal2 = portal_scene.instantiate()
		portal1.position = pos1
		portal2.position = pos2
		portal1.basis	= dir1
		portal2.basis	= dir2
		portal1.interactable = portal2
		portal2.interactable = portal1
		spawner.add_child(portal1, true)
		spawner.add_child(portal2, true)
		return portal1
	return null

func spawn_button(pos, dir, interact, inverse):
	if not multiplayer.is_server():
		return
	var spawner = get_node_or_null("/root/Main/SpawnedItems/World/InteractableSpawner")
	if spawner:
		var button = button_scene.instantiate()
		button.position = pos
		button.basis	= dir
		button.interactable = interact
		button.inverse = inverse
		spawner.add_child(button, true)
		return button
	return null

func spawn_door(pos, dir, activation):
	if not multiplayer.is_server():
		return
	var spawner = get_node_or_null("/root/Main/SpawnedItems/World/InteractableSpawner")
	if spawner:
		var door = door_scene.instantiate()
		door.position = pos
		door.basis	= dir
		door.activation_count = activation
		spawner.add_child(door, true)
		return door
	return null

func spawn_melee_enemy(pos):
	if not multiplayer.is_server():
		return
	var spawner = get_node_or_null("/root/Main/SpawnedItems/World/EnemySpawner")
	if spawner:
		var enemy = enemy_scene.instantiate()
		enemy.position = pos
		spawner.add_child(enemy, true)
		return enemy

func spawn_ranged_enemy(pos):
	if not multiplayer.is_server():
		return
	var spawner = get_node_or_null("/root/Main/SpawnedItems/World/EnemySpawner")
	if spawner:
		var enemy = ranged_enemy_scene.instantiate()
		enemy.position = pos
		spawner.add_child(enemy, true)

func spawn_boss(pos):
	if not multiplayer.is_server():
		return
	var spawner = get_node_or_null("/root/Main/SpawnedItems/World/EnemySpawner")
	if spawner:
		var boss = boss_scene.instantiate()
		boss.position = pos
		spawner.add_child(boss, true)
		return boss
	return null

func spawn_laser(pos, dir, timer = false, activation = 1, hinder = false, jumpable=false, active = true):
	if not multiplayer.is_server():
		return
	var spawner = get_node_or_null("/root/Main/SpawnedItems/World/ProjectileSpawner")
	if spawner:
		var laser = laser_scene.instantiate()
		if jumpable:
			laser = jump_laser_scene.instantiate()
		laser.position = pos
		laser.basis	= dir
		laser.timer_active = timer
		laser.activation_count = activation
		laser.active = active
		spawner.add_child(laser, true)
		if hinder:
			laser.set_laser()
		return laser
	return null

func spawn_terminal(pos, dir, activation=null):
	if not multiplayer.is_server():
		return
	var spawner = get_node_or_null("/root/Main/SpawnedItems/World/InteractableSpawner")
	if spawner:
		var terminal = terminal_scene.instantiate()
		terminal.position = pos
		terminal.basis = dir
		terminal.interactable = activation
		spawner.add_child(terminal, true)
		return terminal

func spawn_box(pos):
	if not multiplayer.is_server():
		return
	var spawner = get_node_or_null("/root/Main/SpawnedItems/World/ItemSpawner")
	if spawner:
		var item = box_scene.instantiate()
		item.position = pos
		spawner.add_child(item, true)

func spawn_wall(pos):
	if not multiplayer.is_server():
		return
	var spawner = get_node_or_null("/root/Main/SpawnedItems/World/WallSpawner")
	if spawner:
		var wall = wall_scene.instantiate()
		wall.position = pos
		spawner.add_child(wall, true)

func spawn_item(pos, welder = false):
	if not multiplayer.is_server():
		return
	var spawner = get_node_or_null("/root/Main/SpawnedItems/World/ItemSpawner")
	if spawner:
		var item = item_scene.instantiate()
		if welder:
			item = welder_scene.instantiate()
			item.add_to_group("Welder")
		else:
			item.add_to_group("Key")
		item.position = pos
		item.welder = welder
		spawner.add_child(item, true)
		return item
	return null

# This function spawns a rondom buff (bomb or potion) and makes sure it is synchronised correctly.
func spawn_buff(pos, choice=0, random=true):
	if not multiplayer.is_server():
		return
	var spawner = get_node_or_null("/root/Main/SpawnedItems/World/ItemSpawner")
	# List of all buffs
	var BUFFS = [hp_bottle_scene, strength_bottle_scene, full_hp_bottle_scene, speed_bottle_scene, bomb_scene]
	# Choose random buff and spawn it in:
	if spawner:
		var buff_scene = null
		if random:
			choice = randi() % BUFFS.size()
		buff_scene = BUFFS[choice]

		var buff = buff_scene.instantiate()
		buff.position = pos
		spawner.add_child(buff, true)
		return choice
	return -1

@rpc("any_peer", "call_local", "reliable")
func spawn_projectile(transform_origin, spawn_offset, direction, shooter):
	if not multiplayer.is_server():
		return

	var projectile_instance = projectile_scene.instantiate()
	get_node("/root/Main/SpawnedItems/World/ProjectileSpawner").add_child(projectile_instance, true)
	projectile_instance.global_transform.origin = transform_origin + spawn_offset
	projectile_instance.direction = direction
	projectile_instance.shooter_is_player = shooter
