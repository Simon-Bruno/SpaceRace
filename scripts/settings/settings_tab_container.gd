class_name SettingsTabContainer
extends Control

signal back
@onready var tab_container = $TabContainer


func _process(_delta):
	settings_menu_input()


func settings_menu_input() -> void:
	# Change tab with left arrow key
	if Input.is_action_just_pressed("ui_left"):
		if tab_container.current_tab == 0:
			tab_container.set_current_tab(tab_container.get_tab_count() - 1)
			return
		tab_container.set_current_tab(tab_container.current_tab - 1)
	# Change tab with right arrow key
	if Input.is_action_just_pressed("ui_right"):
		if tab_container.current_tab >= tab_container.get_tab_count() - 1:
			tab_container.set_current_tab(0)
			return
		tab_container.set_current_tab(tab_container.current_tab + 1)
	# Close settings menu with escape key
	if Input.is_action_just_pressed("ui_cancel") and get_parent().get_parent().get_parent().visible:
		back.emit()
