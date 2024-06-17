extends Node

@onready var weaponDurationTimer = $weaponDuration
@onready var strenthDurationTimer = $strengthDuration
var pistol = preload("res://scenes/weapons/pistol.tscn")
var fists = preload("res://scenes/weapons/fists.tscn")

@onready var player_node = get_parent()
@onready var player_combat_node = player_node.get_node("PlayerCombat")

var strength_debuff : float = 0.5

func _onready():
	print("player_node: ", player_node)

func _input(event):
	if event.is_action_pressed("ability_1"):
		strength_buff()
	if event.is_action_pressed("ability_2"):
		pistol_upgrade()

func pistol_upgrade():
	var weapon_node = player_node.get_node("PlayerCombat/Weapon")
	
	weaponDurationTimer.start()
	player_combat_node.remove_child(weapon_node)
	var new_pistol = pistol.instantiate()
	player_combat_node.add_child(new_pistol, true)
	new_pistol.set_name("Weapon") 
	
func _on_weapon_duration_timeout():
	var weapon_node = player_node.get_node("PlayerCombat/Weapon")
	
	player_combat_node.remove_child(weapon_node)
	player_combat_node.add_child(fists.instantiate(), true)
	
func strength_buff():
	player_node.strength += strength_debuff
	strenthDurationTimer.start()
	

func _on_strength_duration_timeout():
	player_node.strength -= strength_debuff
