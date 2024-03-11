@tool
extends Node

#region Constants

## The config file path.
const CONFIG_FILE: String = "res://config.json"
## Default image card preview.
const DEFAULT_PREVIEW: NoiseTexture2D = preload("res://resources/theme/default_preview.tres")

#endregion

#region Variables

## The contents of the config file.
var settings: Dictionary = {
	"theme_color" : null,
	"directory" : null,
	"preview" : null,
	"templates" : {},
	"folder_tree" : {
		"clips": [{ "clips_img": "" },{ "clips_thumb": "" }],
		"img": [{ "instagram_flyer": "" }],
		"main": [{ "main_thumb": "" }, { "main_img": "" }],
		"reels": [{ "reels_img": "" }],
		"root": [{ "ftg": "" }, { "main": "" }, { "clips": "" }, { "img": "" }, { "reels": "" }, { "super": "" }, { "srt": "" }]
	}
}

#endregion

#region Signals

## Emit when these nodes need to be refreshed.
signal settings_refresh_requested
signal editor_refresh_requested
signal theme_color_set
signal directory_set
signal preview_set
signal templates_set
signal folder_tree_set

#endregion

## Read the config file and write it to the settings property.
func read() -> void:
	if FileAccess.file_exists(CONFIG_FILE) == false:
		write()
	
	var config_file = FileAccess.get_file_as_string(CONFIG_FILE)
	settings = JSON.parse_string(config_file)
	
	print()
	print("-- Config Read --")
	for setting in settings:
		print(setting, ": ", settings.get(setting))
	print("-- Config End --")
	print()
	
	settings_refresh_requested.emit()
	editor_refresh_requested.emit()

## Read the settings property and write it to the config file.
func write() -> void:
	var config_file = FileAccess.open(CONFIG_FILE, FileAccess.WRITE)
	config_file.store_string(JSON.stringify(settings))
	config_file.close()
	
	print()
	print("-- Config Written --")
	for setting in settings:
		print(setting, ": ", settings.get(setting))
	print("-- Config End --")
	print()
	
	settings_refresh_requested.emit()

#region Global

## Set the specified path to the config.directory then write to config file.
func set_directory(new_path: String) -> void:
	settings.directory = new_path
	write()
	directory_set.emit()

## Set the specified path to the config.preview, then write to config file.
func set_preview(new_path: String) -> void:
	settings.preview = new_path
	write()
	preview_set.emit()

#endregion

#region Templates

## Set a template file with a new label, or create one if it doesn't exist.
func set_template_label(new_label: String, old_label: String, path: String) -> void:
	remove_template(old_label)
	settings.templates.merge({new_label : path})
	write()
	templates_set.emit()

## Set a template file with a new path, or create one if it doesn't exist.
func set_template_path(new_path: String, label: String) -> void:
	settings.templates.merge({label : new_path}, true)
	write()
	templates_set.emit()

## Remove an entry from config.templates.
func remove_template(label: String) -> void:
	settings.templates.erase(label)
	write()
	templates_set.emit()

#endregion

#region Folders

func set_folder_tree(tree: Dictionary) -> void:
	settings.folder_tree = tree
	write()
	folder_tree_set.emit()

#endregion

#region Theme

func set_theme_color(color: Color) -> void:
	settings.theme_color = color.to_html()
	write()
	theme_color_set.emit()

#endregion
