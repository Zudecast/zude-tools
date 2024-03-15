@tool
extends Node

#region Constants

## The config file path.
const CONFIG_FILE: String = "res://config.json"
## Default image card preview.
const DEFAULT_PREVIEW: String = "res://resources/theme/default_preview.tres"
## Default folder structure preset for new projects.
const DEFAULT_FOLDERS: String = "res://resources/config/default_folders.json"

#endregion

#region Variables

var production: String

var color: String
var directory: String
var folders: Dictionary
var preview: String
var templates: Dictionary

#endregion

#region Signals

## Emitted when settings nodes need to be refreshed.
signal settings_refresh_requested
## Emitted when settings nodes need to be refreshed.
signal editor_refresh_requested
## Emitted when theme color need to be refreshed.
signal theme_color_set
## Emitted when Zude Tools need to be refreshed.
signal directory_set
## Emitted when previews need to be refreshed.
signal preview_set
## Emitted when template settings need to be refreshed.
signal templates_set
## Emitted when folder settings need to be refreshed.
signal folder_tree_set

#endregion

## Read the config file and write it to the config properties.
func read() -> void:
	if FileAccess.file_exists(CONFIG_FILE) == false:
		write()
	
	var stringified := FileAccess.get_file_as_string(CONFIG_FILE)
	var config: Dictionary = JSON.parse_string(stringified)
	
	color = config.color
	directory = config.directory
	folders = config.folders
	preview = config.preview
	production = directory.get_slice("\\", directory.get_slice_count("\\") - 1)
	templates = config.templates
	
	if color.is_empty():
		color = "0f0f0f"
	
	if folders.is_empty():
		load_folder_preset(DEFAULT_FOLDERS)
	
	if preview.is_empty():
		preview = DEFAULT_PREVIEW
	
	print()
	print("-- Config Read --")
	print(stringified)
	print("-- Config End --")
	print()
	
	settings_refresh_requested.emit()
	editor_refresh_requested.emit()

## Read the config properties and write them to the config file.
func write() -> void:
	var config_file := FileAccess.open(CONFIG_FILE, FileAccess.WRITE)
	
	if color.is_empty():
		color = "0f0f0f"
	
	if folders.is_empty():
		load_folder_preset(DEFAULT_FOLDERS)
	
	if preview.is_empty():
		preview = DEFAULT_PREVIEW
	
	## The contents of the config file.
	var config: Dictionary = {
		"color" : color,
		"directory" : directory,
		"folders" : folders,
		"preview" : preview,
		"templates" : templates
	}
	
	var stringified := JSON.stringify(config, "	")
	config_file.store_string(stringified)
	config_file.close()
	
	print()
	print("-- Config Written --")
	print(stringified)
	print("-- Config End --")
	print()
	
	settings_refresh_requested.emit()

#region Global

## Set the specified path to the config.directory then write to config file.
func set_directory(new_path: String = directory) -> void:
	directory = new_path
	write()
	directory_set.emit()

## Set the specified path to the config.preview, then write to config file.
func set_preview(new_path: String = preview) -> void:
	preview = new_path
	
	if preview.is_empty():
		preview = DEFAULT_PREVIEW
	
	write()
	preview_set.emit()

#endregion

#region Templates

## Set a template file with a new label, or create one if it doesn't exist.
func set_template_label(new_label: String, old_label: String, path: String) -> void:
	remove_template(old_label)
	templates.merge({new_label : path})
	write()
	templates_set.emit()

## Set a template file with a new path, or create one if it doesn't exist.
func set_template_path(new_path: String, label: String) -> void:
	templates.merge({label : new_path}, true)
	write()
	templates_set.emit()

## Remove an entry from config.templates.
func remove_template(label: String) -> void:
	templates.erase(label)
	write()
	templates_set.emit()

#endregion

#region Folders

# TODO - Add me to folder tree as a ui element.
func save_folder_preset(path: String) -> void:
	var new_preset := FileAccess.open(path, FileAccess.WRITE)
	var stringified := JSON.stringify(new_preset, "	")
	new_preset.store_string(stringified)
	new_preset.close()

# TODO - Add me to folder tree as a ui element.
func load_folder_preset(path: String) -> void:
	var stringified := FileAccess.get_file_as_string(DEFAULT_FOLDERS)
	folders = JSON.parse_string(stringified)

func set_folders(tree: Dictionary = folders) -> void:
	folders = tree
	
	write()
	folder_tree_set.emit()

#endregion

#region Theme

func set_color(new_color: Color = color) -> void:
	color = new_color.to_html()
	
	write()
	theme_color_set.emit()

#endregion
