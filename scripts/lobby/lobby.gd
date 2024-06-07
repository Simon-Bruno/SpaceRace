extends Node

@onready var start_timer = Timer.new()

var world = preload("res://scenes/world.tscn")

var team1 = []
var team2 = []
var random = []

func _ready():
	if multiplayer.is_server():
		Network.player_added.connect(Callable(self, "add_player_character"))
		add_child(start_timer)
		start_timer.stop()
		start_timer.wait_time = 0.0
		start_timer.one_shot = true
		start_timer.connect("timeout", Callable(self, "_on_start_timer_timeout"))

func _on_start_timer_timeout():
	_on_game_start.rpc()
	for character in team1:
		Network.player_teams[character.name] = "1"
	for character in team2:
		Network.player_teams[character.name] = "2"
	# Add the players from the random list to teams
	for character in random:
		if team1.size() < 2:
			team1.append(character)
			Network.player_teams[character.name] = "1"
		else:
			team2.append(character)
			Network.player_teams[character.name] = "2"
	get_node("/root/Main").add_child(world.instantiate())

func _process(_delta):
	if multiplayer.is_server():
		print(team1.size(), " : ", team2.size(), " : ", random.size())
		if ((team1.size() == 2 and team2.size() == 2) or random.size() == 4 or Input.is_action_just_pressed("StartGame")) and start_timer.is_stopped():
			start_timer.start()
			print("timer start")

func add_player_character(id):
	var character = preload("res://scenes/player/player.tscn").instantiate()
	character.name = str(id)
	add_child(character)

@rpc("authority", "call_local", "reliable")
func _on_game_start():
	get_node("/root/Main/Lobby").queue_free()
	
func assign_teams():
	random.shuffle()
	for i in range(random.size()):
		if i % 2 == 0:
			team1.append(random[i])
		else:
			team2.append(random[i])
	random.clear()  # Clear the random list after assigning teams

	# Check if both teams have exactly 2 players
	if team1.size() == 2 and team2.size() == 2:
		start_timer.start()

func _on_team1_body_entered(body):
	if multiplayer.is_server() and body is CharacterBody3D and not team1.has(body):	
		team1.append(body)
		check_start_conditions()
		print("A entered")

func _on_team1_body_exited(body):
	if multiplayer.is_server() and body is CharacterBody3D:
		team1.erase(body)
		check_start_conditions()
		print("A exit")

func _on_team2_body_entered(body):
	if multiplayer.is_server() and body is CharacterBody3D and not team2.has(body):
		team2.append(body)
		check_start_conditions()
		print("B entered")

func _on_team2_body_exited(body):
	if multiplayer.is_server() and body is CharacterBody3D:
		team2.erase(body)
		check_start_conditions()
		print("B exit")
		
func _on_random_body_entered(body):
	if multiplayer.is_server() and body is CharacterBody3D and not random.has(body):
		random.append(body)
		check_start_conditions()
		print("random entered")
		
func _on_random_body_exited(body):
	if multiplayer.is_server() and body is CharacterBody3D:
		random.erase(body)
		check_start_conditions()
		print("random exit")

func check_start_conditions():
	if (team1.size() == 2 and team2.size() == 2) or random.size() == 4:
		if start_timer.is_stopped():
			start_timer.start()
			print("timer start")
	else:
		if not start_timer.is_stopped():
			start_timer.stop()
			print("timer stop")
