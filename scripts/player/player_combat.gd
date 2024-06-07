extends Node

var enemy_in_range = false
var enemy_attack_cooldown = true
var health = 100
var player_alive = true
var attack_in_progress = false
var player_movement_script = null
var targeted_enemy = null 

func die():
	player_alive = false

func _process(_delta):
	if health <= 0:
		die()

	enemy_attack()
	player_attack()

func _on_player_hitbox_body_entered(body):
	if body.is_in_group("Enemies"):
		print("enemy entered player hitbox")
		enemy_in_range = true
		targeted_enemy = body 

func _on_player_hitbox_body_exited(body):
	if body.is_in_group("Enemies"):
		enemy_in_range = false
		targeted_enemy = null 

func enemy_attack():
	if enemy_in_range and enemy_attack_cooldown:
		health = max(0, health-20)
		print("Player got hit by," + str(targeted_enemy) + " health: " + str(health))
		enemy_attack_cooldown = false
		$AttackCooldown.start()

func _on_attack_cooldown_timeout():
	enemy_attack_cooldown = true

func player_attack():
	if Input.is_action_just_pressed("attack"):
		Global.player_attacking = true
		attack_in_progress = true
		apply_damage_to_enemy()
		$DealAttackTimer.start()

func _on_deal_attack_timer_timeout():
	Global.player_attacking = false
	attack_in_progress = false
	$DealAttackTimer.stop()

func apply_damage_to_enemy():
	if enemy_in_range and targeted_enemy:
		targeted_enemy.take_damage(20)
		print("Enemy took damage, health: ", targeted_enemy.health)
