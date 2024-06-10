extends Node

@onready var start_timer = Timer.new()

var world = preload("res://scenes/world.tscn")

var team1 = []
var team2 = []
var random = []
var player_id = null

<<<<<<< HEAD
func _ready():
	if multiplayer.is_server():
		Network.player_added.connect(Callable(self, "lobby_add_player_character"))
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
		if ((team1.size() == 2 and team2.size() == 2) or random.size() == 4 or Input.is_action_just_pressed("StartGame")) and start_timer.is_stopped():
=======
var waittime = 3.0

func _process(_delta):
	if multiplayer.is_server():
		if Input.is_action_just_pressed("StartGame"):
			if random.size() == multiplayer.get_peers().size() + 1 or \
			team1.size() + team2.size() == multiplayer.get_peers().size() + 1:
				_on_start_timer_timeout()
		if not start_timer.is_stopped():
			$SubViewport/ProgressBar.value = (waittime - start_timer.time_left) / waittime * 100

func _ready():
	if multiplayer.is_server():
		$MultiplayerSynchronizer.set_multiplayer_authority(multiplayer.get_unique_id())
		Network.player_added.connect(add_player_character)
		init_timer()

func init_timer():
		add_child(start_timer)
		start_timer.stop()
		start_timer.wait_time = waittime
		start_timer.one_shot = true
		start_timer.connect("timeout", _on_start_timer_timeout)
		
func _on_start_timer_timeout():
	if not multiplayer.is_server():
		return
	if random.size() == 4:
		assign_teams()
	for character in team1:
		Network.player_teams[character.name] = 1
	for character in team2:
		Network.player_teams[character.name] = 2
		
	_on_game_start.rpc(Network.player_teams)
	get_parent().add_child(world.instantiate())
	queue_free()

func check_start_conditions():
	if (team1.size() == 2 and team2.size() == 2) or random.size() == 4:
		if start_timer.is_stopped():
>>>>>>> main
			start_timer.start()
			$Sprite3D.visible = true
	else:
		if not start_timer.is_stopped():
			start_timer.stop()
			$SubViewport/ProgressBar.value = 0
			$Sprite3D.visible = false


func lobby_add_player_character(id):
	player_id = id
	print("lobby script add player character id: ", id)
	var character = preload("res://scenes/player/player.tscn").instantiate()
	character.name = str(id)
	Network.player_nodes[id] = character
	Network.player_spawned.emit(character, id)
	Network._update_player_node_dict.rpc(Network.player_nodes)
	add_child(character)
	
@rpc("authority", "call_local", "reliable")
<<<<<<< HEAD
func _on_game_start():
	get_node("/root/Main/Lobby").queue_free()
	Network.player_added.emit(1)

=======
func _on_game_start(player_teams):
	Network.player_teams = player_teams
	Audiocontroller.play_game_music()
	var myteam = player_teams[str(multiplayer.get_unique_id())]
	for player_id in player_teams.keys():
		if player_id == str(multiplayer.get_unique_id()):
			continue
		if Network.player_teams[player_id] == myteam:
			Network.other_team_member_id = player_id
>>>>>>> main
	
func assign_teams():
	random.shuffle()
	for i in range(random.size()):
		if i % 2 == 0:
			team1.append(random[i])
		else:
			team2.append(random[i])

func _on_team1_body_entered(body):
	if multiplayer.is_server() and body is CharacterBody3D and not team1.has(body):	
		team1.append(body)
		$RedTeam/AmountText.text = str(team1.size()) + "/2"
		check_start_conditions()

func _on_team1_body_exited(body):
	if multiplayer.is_server() and body is CharacterBody3D:
		team1.erase(body)
		$RedTeam/AmountText.text = str(team1.size()) + "/2"
		check_start_conditions()

func _on_team2_body_entered(body):
	if multiplayer.is_server() and body is CharacterBody3D and not team2.has(body):
		team2.append(body)
		$BlueTeam/AmountText.text = str(team2.size()) + "/2"
		check_start_conditions()

func _on_team2_body_exited(body):
	if multiplayer.is_server() and body is CharacterBody3D:
		team2.erase(body)
		$BlueTeam/AmountText.text = str(team2.size()) + "/2"
		check_start_conditions()
		
func _on_random_body_entered(body):
	if multiplayer.is_server() and body is CharacterBody3D and not random.has(body):
		random.append(body)
		$RandomTeam/AmountText.text = str(random.size()) + "/4"
		check_start_conditions()
		
func _on_random_body_exited(body):
	if multiplayer.is_server() and body is CharacterBody3D:
		random.erase(body)
		$RandomTeam/AmountText.text = str(random.size()) + "/4"
		check_start_conditions()


