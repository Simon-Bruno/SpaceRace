extends Node

const SETTINGS_SAVE_PATH : String = "user://SettingsData.save"

var settings_data_dict : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	SettingsSignalBus.settings_dictionary.connect(on_settings_save)
	load_settings_data()


func on_settings_save(data : Dictionary):
	var save_settings_data_file = FileAccess.open_encrypted_with_pass(SETTINGS_SAVE_PATH, FileAccess.WRITE, "MIGeMA0GCSqGSIb3DQEBAQUAA4GMADCBiAKBgFGEGflGwObzO7IECx3Ulsxmj3NxevmB5na1LlOE/8BygAJN0v7zu9SSQq4u4+GKiViImwBq4RvaGKu2cTrY9rsyUG435RvWxVtCJwN/psi07dbFlpnBgsXceuUSqMDB28yA6UNz1criEWP6qsSHJE77xrm/kWHG0dikj7grFGx9AgMBAAE=")
	var json_data_string = JSON.stringify(data)
	save_settings_data_file.store_line(json_data_string)


func load_settings_data():
	if not FileAccess.file_exists(SETTINGS_SAVE_PATH):
		return

	var save_settings_data_file = FileAccess.open_encrypted_with_pass(SETTINGS_SAVE_PATH, FileAccess.READ, "MIGeMA0GCSqGSIb3DQEBAQUAA4GMADCBiAKBgFGEGflGwObzO7IECx3Ulsxmj3NxevmB5na1LlOE/8BygAJN0v7zu9SSQq4u4+GKiViImwBq4RvaGKu2cTrY9rsyUG435RvWxVtCJwN/psi07dbFlpnBgsXceuUSqMDB28yA6UNz1criEWP6qsSHJE77xrm/kWHG0dikj7grFGx9AgMBAAE=")
	var loaded_data : Dictionary = {}

	while save_settings_data_file.get_position() < save_settings_data_file.get_length():
		var json_string = save_settings_data_file.get_line()
		var json = JSON.new()
		var _parsed_result = json.parse(json_string)
		
		loaded_data = json.get_data()
		print(loaded_data)
	
	SettingsSignalBus.emit_load_settings_data(loaded_data)
	loaded_data = {}
