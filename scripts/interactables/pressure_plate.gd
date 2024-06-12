extends Node3D

@export var interactable : Node

var customRooms = null
var bodies_on_plate: Array = []

@export var winning_players : Array = []
@export var losing_players : Array = []

var finish = preload("res://scenes/menu/finish_menu.tscn")

# Detect when body entered the area
func _on_area_3d_body_entered(body):
	if body.is_in_group("Players") or body is RigidBody3D:
		if bodies_on_plate.is_empty():
			if interactable == null:
				
				# Retrieve ids of winning team
				var winner_id = multiplayer.get_unique_id()
				var winner_teammate_id = Network.other_team_member_id
				var all_players = Network.player_teams

				print("winner_id: " + str(winner_id));
				print("winner_teammate_id: " + str(winner_teammate_id));
				print("all_players: " + str(all_players));
				
				# Check which players should win or lose (store in array)
				for i in all_players:
					print(i, winner_id)
					if str(i) == str(winner_id) or str(i) == str(winner_teammate_id):
						winning_players.append(i)
					else:
						losing_players.append(i)

				finish = finish.instantiate()
				add_child(finish)
				print("went to finish")
			else:
				interactable.activated()
		bodies_on_plate.append(body)

# Detect when body exited the area
func _on_area_3d_body_exited(body):
	if body.is_in_group("Players") or body is RigidBody3D:
		bodies_on_plate.erase(body)
		if bodies_on_plate.is_empty():
			if interactable != null:
				interactable.deactivated()
			else:
				print("endpressureplate")
				pass

# Called when button is placed in world. Sets the mesh instance to off.
#func _ready():
	#customRooms = get_parent().get_parent()
	#if customRooms is GridMap:
		#$PressurePlate/MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(customRooms.PRESSUREPLATEOFF)
