extends Node

var world = preload("res://scenes/world.tscn")

var team1 = []
var team2 = []
var random = []

func _ready():
	if multiplayer.is_server():
		Network.player_added.connect(add_player_character)

func _process(_delta):
	if (Input.is_action_just_pressed("attack") or \
	(team1.size() == 2 and team2.size() == 2) or \
	random.size() == 4) and multiplayer.is_server():
		_on_game_start.rpc()
		for character in team1:
			Network.player_teams[character.name] = "1"
		for character in team2:
			Network.player_teams[character.name] = "2"
		for character in random:
			Network.player_teams[character.name] = "2"
		get_node("/root/Main").add_child(world.instantiate())

func add_player_character(id):
	var character = preload("res://scenes/player/player.tscn").instantiate()
	character.name = str(id)
	add_child(character)

# Called when the node enters the scene tree for the first time.
@rpc("authority", "call_local", "reliable")
func _on_game_start():
	get_node("/root/Main/Lobby").queue_free()


func _on_team1_body_entered(body):
	if multiplayer.is_server() and body is CharacterBody3D:	
		team1.append(body)
		print("1 entererd")

func _on_team1_body_exited(body):
	if multiplayer.is_server() and body is CharacterBody3D:
		team1.erase(body)
		print("1 exit")

func _on_team2_body_entered(body):
	if multiplayer.is_server() and body is CharacterBody3D:
		team2.append(body)
		print("2 entererd")

func _on_team2_body_exited(body):
	if multiplayer.is_server() and body is CharacterBody3D:
		team2.erase(body)
		print("2 exit")
