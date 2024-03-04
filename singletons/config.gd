@tool
extends Node

## The config file path.
const CONFIG_FILE: String = "res://config.json"

## The contents of the config file.
var settings: Dictionary = {
	"directory" : null,
	"preview" : null,
	"templates" : {}
}

## Emit when these nodes need to be refreshed.
signal refresh_settings
signal refresh_editor

## Read the config file and write it to the settings property.
func read() -> void:
	if FileAccess.file_exists(CONFIG_FILE) == false:
		write()
	
	var contents = FileAccess.get_file_as_string(CONFIG_FILE)
	var parsed = JSON.parse_string(contents)
	
	if parsed is Dictionary:
		settings = parsed
		prints("Config read:", settings)
		refresh_settings.emit()
		refresh_editor.emit()

## Read the settings property and write it to the config file.
func write() -> void:
	var config_file = FileAccess.open(CONFIG_FILE, FileAccess.WRITE)
	
	config_file.store_string(JSON.stringify(settings))
	config_file.close()
	
	prints("Config written:", settings)
	refresh_settings.emit()

#region Global

## Set the specified directory to the config.directory, the directory property, then write to config file.
func set_directory(new_path: String) -> void:
	if new_path == "":
		settings.directory = null
	else:
		settings.directory = new_path
	write()
	refresh_editor.emit()

## Set the specified path to the config.preview, then write to config file.
func set_preview(new_path: String) -> void:
	if new_path == "":
		settings.preview = null
	else:
		settings.preview = new_path
	write()
	refresh_editor.emit()

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
