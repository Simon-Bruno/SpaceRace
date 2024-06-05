extends StaticBody3D

#onready var door = $AnimationPlayer
#Code is temp for opening and closing a door.
var tijd = 100

func _physics_process(delta):
#Play animation to open door
	$AnimationPlayer.play("Door Sliding")
	
# Open door after 100 repeats
	#if tijd == 0:
		#$AnimationPlayer.play("Door Sliding")
		#print('Deur gaat open')
		#tijd = 100
	#else:
		#tijd -= 1
		#print('seconde', tijd)
		#$AnimationPlayer.play_backwards("Door Sliding")
