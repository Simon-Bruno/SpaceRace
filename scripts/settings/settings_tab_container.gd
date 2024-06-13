class_name SettingsTabContainer
extends Control

signal Back_To_menu

@onready var tab_container = $TabContainer 

func _process(_delta):
	settings_menu_input()


func settings_menu_input() -> void:
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("ui_left"):
		if tab_container.current_tab == 0:
			tab_container.set_current_tab(tab_container.get_tab_count() - 1)
			return
		tab_container.set_current_tab(tab_container.current_tab - 1)
	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("ui_right"):
		if tab_container.current_tab >= tab_container.get_tab_count() - 1:
			tab_container.set_current_tab(0)
			return
		tab_container.set_current_tab(tab_container.current_tab + 1)

	if Input.is_action_just_pressed("ui_cancel"):
		Back_To_menu.emit()
