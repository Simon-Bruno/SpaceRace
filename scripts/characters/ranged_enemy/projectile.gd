extends RigidBody3D

@export var lifespan : float = 5.0
@export var speed : float = 30.0

var direction: Vector3

func _ready():
	print("Projectile ready")

func _physics_process(delta):
	var motion = direction * speed * delta
	motion.y = 0  # Prevent downward motion

	var collision = move_and_collide(motion)

	if collision:
		print(collision.get_collider().name)
		print("Collision detected")
		if collision.get_collider().is_in_group("Players"):
			print("Hit player: ", collision.get_collider().name)
			collision.get_collider().take_damage(10)
		if collision.get_collider().is_in_group("Enemies"):
			print("Hit Enemy: ", collision.get_collider().name)
			if collision.get_collider().has_method("take_damage"):
				collision.get_collider().take_damage(10, self)
		queue_free()

