extends Node

@onready var player_node = get_parent()

var ability1_point_cost : int = 10
var ability2_point_cost : int = 20
var healing_amount : int = 50

func ability1() -> void:
	heal()
	
func ability2() -> void:
	pass

func heal() -> void:
	player_node.health =  min(Global.player_max_health, player_node.health + healing_amount)
