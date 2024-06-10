extends Node3D

var enemy_in_range = false
var health = 100
var player_alive = true
var attack_in_progress = false
var player_movement_script = null
var targeted_enemy = null 

@onready var player_node = get_parent()
@onready var player_spawner_node = player_node.get_parent()


func die():
	player_spawner_node.player_died(player_node)

func _process(_delta):
<<<<<<< HEAD
	if get_parent().health <= 0:
		print("health < 0")
		die()
	
func _input(event):
	if event.is_action_pressed("attack"):
=======
	if health <= 0:
		player_alive = false
		health = 0

	enemy_attack()
	player_attack()

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

func player_attack():
	if Input.is_action_just_pressed("attack") and not Global.in_chat:
		Global.player_attacking = true
>>>>>>> main
		attack_in_progress = true
		apply_damage_to_enemy()
		$DealAttackTimer.start()

func _on_player_hitbox_body_entered(body):
	if body.is_in_group("Enemies"):
		enemy_in_range = true
		targeted_enemy = body 

func _on_player_hitbox_body_exited(body):
	if body.is_in_group("Enemies"):
		enemy_in_range = false
		targeted_enemy = null 

func _on_deal_attack_timer_timeout():
	attack_in_progress = false
	$DealAttackTimer.stop()

func apply_damage_to_enemy():
	if enemy_in_range and targeted_enemy:
		targeted_enemy.take_damage(20, self)

func _on_GetHitCooldown_timeout():
	get_parent().getHitCooldown = true

