extends Node

@onready var player_node = get_parent()

var healing_amount : int = 50

var ability1_cooldown : int = 20
var ability2_cooldown : int = 30

var ability1_title : String = "Heal"
var ability2_title : String = "Sabotage WIP"

func _ready():
	var hud = get_node_or_null("../../../HUD")
	if hud:
		hud.set_ability_info(ability1_title, ability2_title, ability1_cooldown, ability2_cooldown)


func ability1() -> void:
	print("ability 1 scientist")
	heal()
	
func ability2() -> void:
	print("ability 2 scientist")

func heal() -> void:
	player_node.health =  min(Global.player_max_health, player_node.health + healing_amount)
