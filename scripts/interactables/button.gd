extends Node3D

@export var interactable : Node

var customRooms = null
var player = null
var activate_text: bool = false
@export var activate: bool = false

# Detect when body entered the area
func _on_area_3d_body_entered(body):
	if body is CharacterBody3D and body.is_in_group("Players") \
	and body.name == str(multiplayer.get_unique_id()):
		$ButtonText.show()
		player = body
		activate_text = true

# Detect when body exited the area
func _on_area_3d_body_exited(body):
	if body is CharacterBody3D and activate_text and body.is_in_group("Players") \
	and body.name == str(multiplayer.get_unique_id()):
		$ButtonText.hide()
		player = null
		activate_text = false

# Activate switch and call the interactable activation.
func _activate_switch():
	interactable.activated()
	activate = true

# Deactivate the switch and call the interactable deactivation.
func _deactivate_switch():
	interactable.deactivated()
	activate = false
	
@rpc("any_peer", "call_local", "reliable")
func _interact_pressed_on_button():
	if not multiplayer.is_server():
		return
	if !activate:
		_activate_switch()
	else:
		_deactivate_switch()
	_update_visual.rpc(activate)

@rpc("authority", "call_local", "reliable")
func _update_visual(active):
	if not customRooms is GridMap:
		return
	if active:
		$Button/MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(customRooms.WALLSWITCHON)
	else:
		$Button/MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(customRooms.WALLSWITCHOFF)
# Activate when button is pressed. Change the mesh to activate or deactivate.
func _input(event):
	if event.is_action_pressed("interact") and activate_text:
		if player != null and interactable != null:
			_interact_pressed_on_button.rpc()

# Called when button is placed in world. Sets the mesh instance to off.
func _ready():
	customRooms = get_parent()
	if customRooms is GridMap:
		$Button/MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(customRooms.WALLSWITCHOFF)
