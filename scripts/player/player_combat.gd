extends Node3D

var enemy_in_range = false
var health = 100
var player_alive = true
var attack_in_progress = false
var player_movement_script = null
var targeted_enemy = null

@onready var player_node = get_parent()
@onready var player_spawner_node = player_node.get_parent()

signal player_died(player)


func die():
	player_spawner_node.player_died(player_node)

func _process(_delta):
	if get_parent().health <= 0:
		die()

func _input(event):
	if event.is_action_pressed("attack"):
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
		if Input.is_action_just_pressed("attack"):
			Audiocontroller.play_attack_fist_sfx()

func _on_GetHitCooldown_timeout():
	get_parent().getHitCooldown = true

