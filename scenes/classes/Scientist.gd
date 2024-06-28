extends Node

@onready var weaponDurationTimer = $weaponDuration
@onready var strenthDurationTimer = $strengthDuration
@onready var player_node = get_parent()
@onready var player_combat_node = player_node.get_node("PlayerCombat")

var pistol = preload("res://scenes/weapons/pistol.tscn")
var fists = preload("res://scenes/weapons/fists.tscn")

var strength_debuff : float = 0.5

var ability1_cooldown : int = 20
var ability2_cooldown : int = 40

var ability1_title : String = "Strength buff"
var ability2_title : String = "Upgrade weapon"

# This functions gets called once when the node enters the scene tree.
func _ready(): 
	# Load HUD
	var hud = get_node_or_null("../../../HUD")
	if hud:
		hud.set_ability_info(ability1_title, ability2_title, ability1_cooldown, ability2_cooldown)

func ability1():
	print("ability 1 soldier")
	strength_buff()
	
func ability2():
	print("ability 2 soldier")
	pistol_upgrade()

func pistol_upgrade():
	# get the current weapon and remove it, start the tinmer for the ability duration
	var weapon_node = player_node.get_node("PlayerCombat/Weapon")
	weaponDurationTimer.start()
	player_combat_node.remove_child(weapon_node)
	
	# load the pistol node and add it to the same spot as the previous weapon
	var new_pistol = pistol.instantiate()
	player_combat_node.add_child(new_pistol, true)
	new_pistol.set_name("Weapon") 
	
	# Display ability message
	%Label.text = "+ pistol"
	await get_tree().create_timer(1.0).timeout
	%Label.text = ""
	
# this function only gets called when the weapon duration timer reaches its end
func _on_weapon_duration_timeout():
	# Remove the pistol node
	var weapon_node = player_node.get_node("PlayerCombat/Weapon")
	player_combat_node.remove_child(weapon_node)
	player_combat_node.add_child(fists.instantiate(), true)
	
func strength_buff():
	# update the strength value. This value multiplies the damage output of the player
	player_node.strength += strength_debuff
	strenthDurationTimer.start()
	
	# Display ability message
	%Label.text = "+ strength"
	await get_tree().create_timer(1.0).timeout
	%Label.text = ""

# this function only gets called when the strength duration timer reaches its end.
func _on_strength_duration_timeout():
	player_node.strength -= strength_debuff
