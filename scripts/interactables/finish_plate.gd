extends Node

@export var winning_players: Array = []
@export var losing_players: Array = []

var finish_scene = preload("res://scenes/menu/finish_menu.tscn")

func process_winning_team(multiplayer_id) -> Array:
	# Retrieve ids of winning team
	var winner_id = multiplayer_id
	var winner_teammate_id = Network.other_team_member_id
	var all_players = Network.player_teams

	print("at finishplate: winner_id: " + str(winner_id))
	print("at finishplate: winner_teammate_id: " + str(winner_teammate_id))
	print("at finishplate: all_players_id:  " + str(all_players))

	# Check which players should win or lose (store in array)
	for i in all_players:
		print(i, winner_id)
		if str(i) == str(winner_id) or str(i) == str(winner_teammate_id):
			winning_players.append(i)
		else:
			losing_players.append(i)

	print("went to finish")
	return [winning_players, losing_players]
