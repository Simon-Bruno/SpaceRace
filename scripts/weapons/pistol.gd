extends Node3D

var enemies_in_weapon_range : Array = []
var closest_target_node : Node = null

var damage = 20

@export var projectile_scene : PackedScene
func attack():
	var projectile_instance = projectile_scene.instantiate()
	var direction_to_shoot = -global_transform.basis.z.normalized()
	var spawn_offset = direction_to_shoot * 1
	add_child(projectile_instance)
	projectile_instance.global_transform.origin = global_transform.origin + spawn_offset
	projectile_instance.direction = direction_to_shoot
