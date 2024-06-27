extends Node3D

var enemies_in_weapon_range : Array = []
var closest_target_node : Node = null

var damage = 20

@export var projectile_scene : PackedScene

func attack():
	if get_node_or_null("/root/Main/SpawnedItems/World/ProjectileSpawner") != null:
		var direction_to_shoot = -global_transform.basis.z.normalized()
		var spawn_offset = direction_to_shoot * 1
		spawn_projectile_for_me.rpc(global_transform.origin, spawn_offset, direction_to_shoot)
	
@rpc("any_peer", "call_local", "reliable")
func spawn_projectile_for_me(transform_origin, spawn_offset, direction):
	if not multiplayer.is_server():
		return
		
	var projectile_instance = projectile_scene.instantiate()
	get_node("/root/Main/SpawnedItems/World/ProjectileSpawner").add_child(projectile_instance, true)
	projectile_instance.global_transform.origin = transform_origin + spawn_offset
	projectile_instance.direction = direction
	projectile_instance.shooter_is_player = true
