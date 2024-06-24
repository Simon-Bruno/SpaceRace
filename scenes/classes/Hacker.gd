extends Node


var ability1_cooldown : int = 30
var ability2_cooldown : int = 40

var ability1_title : String = "Lights off WIP"
var ability2_title : String = "Slow enemies WIP"

func _ready():
	var hud = get_node_or_null("../../../HUD")
	if hud:
		hud.set_ability_info(ability1_title, ability2_title, ability1_cooldown, ability2_cooldown)

func ability1():
	print("ability 1 hacker")
	
func ability2():
	print("ability 2 hacker")
