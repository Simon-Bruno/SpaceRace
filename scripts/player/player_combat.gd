extends Node

var enemy_in_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true
var attack_in_progress = false
var player_movement_script = null
var enemy = null 

func _ready():
	pass

func _process(_delta):
	enemy_attack()
	attack()
	if health <= 0:
		player_alive = false
		health = 0

func player():
	# Nodig om te identifien wat de player is
	pass

func _on_player_hitbox_body_entered(body):
	if body.has_method("enemy"):
		enemy_in_range = true
		enemy = body 

func _on_player_hitbox_body_exited(body):
	if body.has_method("enemy"):
		enemy_in_range = false
		enemy = null 

func enemy_attack():
	if enemy_in_range and enemy_attack_cooldown:
		health -= 20
		if health < 0:
			health = 0
		print("Player got hit, health: ", health)
		enemy_attack_cooldown = false
		$AttackCooldown.start()

func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true

func attack():
	if Input.is_action_just_pressed("attack"):
		Global.player_attacking = true
		attack_in_progress = true
		$DealAttackTimer.start()

func _on_deal_attack_timer_timeout():
	Global.player_attacking = false
	attack_in_progress = false
	$DealAttackTimer.stop()
	if enemy_in_range and enemy:
		enemy.take_damage(20)
