extends Node3D

@export var interactable : Node
var customRooms = null

var player = null
var activate_text: bool = false
var activate: bool = false
var WALLSWITCHOFF = 18
var WALLSWITCHON = 19

# Detect when body entered the area
func _on_area_3d_body_entered(body):
	if body is CharacterBody3D and body.is_in_group("Players"):
		$ButtonText.show()
		player = body
		activate_text = true

# Detect when body exited the area
func _on_area_3d_body_exited(body):
	if body is CharacterBody3D and activate_text and body.is_in_group("Players"):
		$ButtonText.hide()
		player = null
		activate_text = false

# Activate switch
func _activate_switch():
	if customRooms is GridMap:
		$Button/MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(WALLSWITCHON)
	interactable.activated()
	activate = true

# Deactivate the switch
func _deactivate_switch():
	if customRooms is GridMap:
		$Button/MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(WALLSWITCHOFF)
	interactable.deactivated()
	activate = false

# Activate when button is pressed
func _process(delta):
	if Input.is_action_just_pressed("interact") and activate_text:
		if player != null and interactable != null:
			if !activate:
				_activate_switch()
			else:
				_deactivate_switch()

func _ready():
	customRooms = get_parent().get_parent()
	if customRooms is GridMap:
		$Button/MeshInstance3D.mesh = customRooms.mesh_library.get_item_mesh(WALLSWITCHOFF)
