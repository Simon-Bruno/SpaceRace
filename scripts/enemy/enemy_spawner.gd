extends Node

func _enter_tree():
	if multiplayer.is_server():
		$"EnemyMultiplayerSpawner".set_multiplayer_authority(multiplayer.get_unique_id())
		
func _ready():
	GlobalSpawner.spawn_ranged_enemy(Vector3(2,20,4))
