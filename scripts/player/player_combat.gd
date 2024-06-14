extends Node3D

var enemies_in_weapon_range : Array = []
var able_to_attack : bool = true

@onready var player_node = get_parent()

func _input(event):
	if str(multiplayer.get_unique_id()) == get_parent().name:
		if event.is_action_pressed("attack") and able_to_attack and player_node.alive:
			$Weapon.attack()
			able_to_attack = false
			$DealAttackTimer.start()

func _on_deal_attack_timer_timeout():
	able_to_attack = true

func _on_GetHitCooldown_timeout():
	player_node.getHitCooldown = true
