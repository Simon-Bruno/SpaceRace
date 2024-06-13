extends RigidBody3D

@export var speed : float = 30.0
var damage : int = 50
var direction: Vector3

func _ready():
	if multiplayer.is_server():
		$MultiplayerSynchronizer.set_multiplayer_authority(multiplayer.get_unique_id())
	$LifeSpan.start()

func _physics_process(delta):
	if not multiplayer.is_server():
		return
		
	var motion = direction * speed * delta
	var collision = move_and_collide(motion)

	if collision:
		if collision.get_collider().is_in_group("Players"):
			collision.get_collider().take_damage.rpc(collision.get_collider().name, damage)
		if collision.get_collider().is_in_group("Enemies"):
			if collision.get_collider().has_method("take_damage"):
				collision.get_collider().take_damage.rpc(collision.get_collider().name, damage, self)
		queue_free()

func _on_life_span_timeout():
	queue_free()
