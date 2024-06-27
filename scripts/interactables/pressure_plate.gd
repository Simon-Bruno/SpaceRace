extends Node3D

@export var interactable : Node
@export var enemy_pos : Vector3i
@export var winner_id : int

var is_finish_plate : bool = false
var customRooms : GridMap = null
var bodies_on_plate: Array = []
var finish = preload("res://scenes/menu/finish_menu.tscn")

const CHAT_PATH = "/root/Main/SpawnedItems/World/Chat"
const HUD_PATH = "/root/Main/SpawnedItems/World/HUD/InGame"

# Called when button is placed in world. Sets the mesh instance to off.
func _ready() -> void:
	var target_node_name = "WorldGeneration"
	var root_node = get_tree().root
	customRooms = find_node_by_name(root_node, target_node_name)
	if multiplayer.is_server():
		await get_tree().create_timer(1.5).timeout
		update_mesh.rpc(customRooms.PRESSUREPLATEOFF)

#Search the gridmap of the world and returns it.
func find_node_by_name(node: Node, target_name: String) -> Node:
	if node.name == target_name:
		return node

	for child in node.get_children():
		var found_node = find_node_by_name(child, target_name)
		if found_node:
			return found_node
	return null

# Detect when body entered the area
func _on_area_3d_body_entered(body) -> void:
	if not multiplayer.is_server():
		return

	if body.is_in_group("Players") or body is RigidBody3D:
		if bodies_on_plate.is_empty():
			update_mesh.rpc(customRooms.PRESSUREPLATEON)
			handle_plate_activation(body)
		bodies_on_plate.append(body)

# Detect when body exited the area
func _on_area_3d_body_exited(body) -> void:
	if not multiplayer.is_server():
		return

	if body.is_in_group("Players") or body is RigidBody3D:
		bodies_on_plate.erase(body)
		if bodies_on_plate.is_empty():
			update_mesh.rpc(customRooms.PRESSUREPLATEOFF)
			handle_plate_deactivation()

# Handle the activation logic when a body enters the pressure plate
func handle_plate_activation(body) -> void:
	if is_finish_plate and body.is_in_group('Players'):
		winner_id = body.name.to_int()
		finish = finish.instantiate()
		Audiocontroller.play_pressure_plate_sfx()
		
		var chat = get_node_or_null(CHAT_PATH)
		var hud = get_node_or_null(HUD_PATH)
		if chat != null:
			chat.visible = false
		if hud != null:
			hud.visible = false

		add_child(finish)
	else:
		if interactable != null:
			interactable.activated()
			Audiocontroller.play_pressure_plate_sfx()
		elif enemy_pos != null:
			GlobalSpawner.spawn_melee_enemy(enemy_pos)
			Audiocontroller.play_boss_spawn_minions_sfx()

# Handle the deactivation logic when a body exits the pressure plate
func handle_plate_deactivation() -> void:
	if interactable != null:
		interactable.deactivated()
		Audiocontroller.play_pressure_plate_sfx()

# Updates the pressureplate mesh according to the current state
@rpc("authority", "call_local", "reliable")
func update_mesh(state : int) -> void:
	if customRooms:
		$PressurePlate/MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(state)


