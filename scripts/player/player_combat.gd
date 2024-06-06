extends Node

var enemy_in_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	enemy_attack()
	
	if health <= 0:
		#TODO: Add death mechanic (10 sec frozen to full health)? Respawn?
		player_alive = false
		print("Player dead")
		
func player():
	# method to check if object is player
	pass

#Note: Currently only has melee logic
func _on_player_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_in_range = true

func _on_player_hitbox_body_exited(body):
 #Note: Enemy will need this function so we recognize its an enemy
	if body.has_method("enemy"):
		enemy_in_range = false

func enemy_attack():
	if enemy_in_range and enemy_attack_cooldown == true:
		health = health - 20
		enemy_attack_cooldown = false
		$AttackCooldown.start()
		print("player got hit")


func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true
