extends Node

var ability1_point_cost : int = 10
var ability2_point_cost : int = 20
var healing_amount : int = 50

func ability1() -> void:
	print("ability 1 scientist")
	heal()
	
func ability2() -> void:
	print("ability 2 scientist")
	slow_enemies()

func slow_enemies() -> void:
	set_slowness_on_other_team.rpc(Network.get_other_team_ids(multiplayer.get_unique_id()))
	
@rpc("any_peer", "call_local", "reliable")
func set_slowness_on_other_team(ids):
	if ids.has(str(multiplayer.get_unique_id())):
		Network.get_player_node_by_id(multiplayer.get_unique_id()).walkspeed_multiplier = 0.1
		await get_tree().create_timer(10).timeout
		Network.get_player_node_by_id(multiplayer.get_unique_id()).walkspeed_multiplier = 1

func heal() -> void:
	get_parent().health =  min(Global.player_max_health, get_parent().health + healing_amount)
	get_parent().HpBar.value = get_parent().health
