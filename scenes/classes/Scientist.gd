extends Node

@onready var player_node = get_parent()

var ability1_point_cost : int = 10
var ability2_point_cost : int = 20
var healing_amount : int = 50
var slowed_player_nodes : Array = []

func ability1() -> void:
	print("ability 1 scientist")
	heal()
	
func ability2() -> void:
	print("ability 2 scientist")
	slow_enemies()

func slow_enemies() -> void:
	var all_player_keys : Array = Network.player_teams.keys()
	for player_id in all_player_keys:
		if int(player_id) == multiplayer.get_unique_id() or int(player_id) == Network.other_team_member_id:
			continue
		else:
			player_node = Network.get_player_node_by_id(player_id)
			player_node.walkspeed_multiplier = 0.1
			slowed_player_nodes.append(player_node) 
			$slow_duration.start()
			player_node.get_node("PlayerCombat/SubViewport/HpBar").value = 50 # to see which nodes are affected
	print("player node: ", Network.get_player_node_by_id(multiplayer.get_unique_id()))
	print("slowed nodes: ", slowed_player_nodes)

func _on_slow_ability_time_timeout():
	for player_node in slowed_player_nodes:
		player_node.walkspeed_multiplier = 1

func heal() -> void:
	player_node.health =  min(Global.player_max_health, player_node.health + healing_amount)
