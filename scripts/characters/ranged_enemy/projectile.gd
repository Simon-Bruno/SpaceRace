extends RigidBody3D

@export var lifespan : float = 5.0
@export var speed : float = 30.0
@export var shooter: CharacterBody3D = null
var damage : int = 50
var direction: Vector3

func _ready():
	if multiplayer.is_server():
		$MultiplayerSynchronizer.set_multiplayer_authority(multiplayer.get_unique_id())

func _physics_process(delta):
	if not multiplayer.is_server():
		return
		
	var motion = direction * speed * delta
	motion.y = 0  # Prevent downward motion

	var collision = move_and_collide(motion)

	if collision:
		if collision.get_collider().is_in_group("Boss") and shooter.is_in_group("Boss"):
			return
		if collision.get_collider().is_in_group("Players"):
			collision.get_collider().take_damage.rpc(collision.get_collider().name, damage)
		if collision.get_collider().is_in_group("Enemies"):
			if collision.get_collider().has_method("take_damage"):
				collision.get_collider().take_damage(damage, shooter)
		queue_free()

