@tool
extends Node

## The config file path.
const CONFIG_FILE: String = "res://config.json"

## The contents of the config file.
var settings: Dictionary = {
	"directory" : null,
	"preview" : null,
	"templates" : {},
	"folder_tree" : {}
}

## Emit when these nodes need to be refreshed.
signal settings_refresh_requested
signal editor_refresh_requested

func _get_property_list() -> Array[Dictionary]:
	var properties = []
	properties.append({
		"name": "settings",
		"type": TYPE_DICTIONARY,
		"usage": PROPERTY_USAGE_STORAGE
	})
	
	return properties

## Read the config file and write it to the settings property.
func read() -> void:
	if FileAccess.file_exists(CONFIG_FILE) == false:
		write()
	
	var config_file = FileAccess.get_file_as_string(CONFIG_FILE)
	settings = JSON.parse_string(config_file)
	
	print("Config Read:", settings)
	settings_refresh_requested.emit()
	editor_refresh_requested.emit()

## Read the settings property and write it to the config file.
func write() -> void:
	var config_file = FileAccess.open(CONFIG_FILE, FileAccess.WRITE)
	config_file.store_string(JSON.stringify(settings))
	config_file.close()
	
	print("Config written:", settings)
	settings_refresh_requested.emit()

#region Global

## Set the specified directory to the config.directory, the directory property, then write to config file.
func set_directory(new_path: String) -> void:
	settings.directory = new_path
	write()
	editor_refresh_requested.emit()

## Set the specified path to the config.preview, then write to config file.
func set_preview(new_path: String) -> void:
	settings.preview = new_path
	write()
	editor_refresh_requested.emit()

#endregion

#region Templates

## Set a template file with a new label, or create one if it doesn't exist.
func set_template_label(new_label: String, old_label: String, path: String) -> void:
	remove_template(old_label)
	settings.templates.merge({new_label : path})
	write()

## Set a template file with a new path, or create one if it doesn't exist.
func set_template_path(new_path: String, label: String) -> void:
	settings.templates.merge({label : new_path}, true)
	write()

## Remove an entry from config.templates.
func remove_template(label: String) -> void:
	settings.templates.erase(label)
	write()

#endregion

#region Folders

func set_folder_tree(tree: Dictionary) -> void:
	settings.folder_tree = tree
	write()

#endregion
