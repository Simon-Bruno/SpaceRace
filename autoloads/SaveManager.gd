extends Node

const SETTINGS_SAVE_PATH : String = "user://SettingsData.save"

var settings_data_dict : Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	SettingsSignalBus.settings_dictionary.connect(on_settings_save)
	load_settings_data()


func on_settings_save(data : Dictionary):
	# Save settings data to file using a password
	var save_settings_data_file = FileAccess.open_encrypted_with_pass(SETTINGS_SAVE_PATH, FileAccess.WRITE, "MIGeMA0GCSqGSIb3DQEBAQUAA4GMADCBiAKBgFGEGflGwObzO7IECx3Ulsxmj3NxevmB5na1LlOE/8BygAJN0v7zu9SSQq4u4+GKiViImwBq4RvaGKu2cTrY9rsyUG435RvWxVtCJwN/psi07dbFlpnBgsXceuUSqMDB28yA6UNz1criEWP6qsSHJE77xrm/kWHG0dikj7grFGx9AgMBAAE=")
	var json_data_string = JSON.stringify(data) # Convert the dictionary to a JSON string
	save_settings_data_file.store_line(json_data_string) # Save the JSON string to the file


func load_settings_data():
	# Return if the file does not exist
	if not FileAccess.file_exists(SETTINGS_SAVE_PATH):
		return

	# Load settings data from file using a password
	var save_settings_data_file = FileAccess.open_encrypted_with_pass(SETTINGS_SAVE_PATH, FileAccess.READ, "MIGeMA0GCSqGSIb3DQEBAQUAA4GMADCBiAKBgFGEGflGwObzO7IECx3Ulsxmj3NxevmB5na1LlOE/8BygAJN0v7zu9SSQq4u4+GKiViImwBq4RvaGKu2cTrY9rsyUG435RvWxVtCJwN/psi07dbFlpnBgsXceuUSqMDB28yA6UNz1criEWP6qsSHJE77xrm/kWHG0dikj7grFGx9AgMBAAE=")
	var loaded_data : Dictionary = {}

	# Read the file line by line
	while save_settings_data_file.get_position() < save_settings_data_file.get_length():
		var json_string = save_settings_data_file.get_line() # Read the JSON string from the file
		var json = JSON.new() # Create a new JSON object
		var _parsed_result = json.parse(json_string) # Parse the JSON string

		loaded_data = json.get_data() # Get the dictionary data from the JSON object

	SettingsSignalBus.emit_load_settings_data(loaded_data) # Emit the signal with the loaded data
	loaded_data = {} # Clear the loaded data
