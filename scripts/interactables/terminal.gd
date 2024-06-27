extends Node3D

@export var interactable : Node

var playercount : int = 0
var total_progress : int = 100
var progress : float = 0

var progress_up_speed : float = 15
var progress_down_speed : float = 1.2

var is_activated : bool = false

var timer_time : float = 3
var timer : float

var last_sum : int = 0

func _ready():
	timer = timer_time
	$Terminal/Terminal.generate_new_screen()

func _process(delta):
	if not multiplayer.is_server() or is_activated:
		return
	if playercount > 0:
		if progress >= 100:
			if not is_activated:
				is_activated = true
				$Terminal.visible = false
				Network.in_terminal = false
				get_node("/root/Main/SpawnedItems/World/HUD/InGame").visible = true
				if interactable:
					interactable.activated()

	progress -= progress_down_speed * delta
	if progress < 0:
		progress = 0
	timer -= delta
	if timer <= 0:
		timer = timer_time
		$Terminal/Terminal.generate_new_screen()
	$Terminal/TimeBar.value = timer / timer_time * 100
	$SubViewport/ProgressBar.value = progress / total_progress * 100
	$Terminal/ScoreBar.value = progress / total_progress * 100

func progress_updated(correct : bool):
	print(correct)
	if correct:
		progress += progress_up_speed
	else:
		progress -= 1.5 * progress_up_speed
	$SubViewport/ProgressBar.value = progress / total_progress * 100
	$Terminal/ScoreBar.value = progress / total_progress * 100
	$Terminal/Terminal.generate_new_screen()
	timer = timer_time
	$Terminal/TimeBar.value = 100

func _on_area_3d_body_entered(body):
	if body.is_in_group("Players") and not is_activated:
		playercount += 1;
		Audiocontroller.play_terminal_sfx()
		if body.name == str(multiplayer.get_unique_id()):
			$Terminal.visible = true
			Network.in_terminal = true
			get_node("/root/Main/SpawnedItems/World/HUD/InGame").visible = false

func _on_area_3d_body_exited(body):
	if body.is_in_group("Players") and not is_activated:
		playercount -= 1;
		if body.name == str(multiplayer.get_unique_id()):
			$Terminal.visible = false
			Network.in_terminal = false
			get_node("/root/Main/SpawnedItems/World/HUD/InGame").visible = true
