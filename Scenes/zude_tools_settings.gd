@tool
class_name ZudeToolsSettings
extends Control

#region Constants

const CONFIG: String = "res://config.json"
const PATH_SETTING: PackedScene = preload("res://Scenes/zude_tools_path_setting.tscn")

#endregion

#region Onready Variables

@onready var editor: ZudeToolsEditor = $"../ZudeToolsEditor"
@onready var file_dialog: ZudeToolsFileDialog = $"../ZudeToolsFileDialog"

@onready var close_settings_button: Button = %CloseSettingsButton

@onready var global: VBoxContainer = %GlobalVBox
@onready var default_preview_path_setting: ZudeToolsPathSetting = %DefaultPreviewPathSetting

@onready var templates: VBoxContainer = %TemplatesVBox
@onready var add_template_button: Button = %AddTemplateButton

@onready var folder_tree: Tree = %FolderTree
@onready var add_folder_button: Button = %AddFolderButton

#endregion

#region Variables

var directory: String:
	set(path):
		directory = path
		editor.refresh()

var config: Dictionary = {
	"default_preview" : "res://zudecast.png",
	"directory" : directory,
	"templates" : {}
}:
	set(dict):
		config = dict
		refresh()
		write_config_file()

#endregion

func _ready() -> void:
	read_config_file()
	
	# Connect signals for local buttons.
	close_settings_button.pressed.connect(close)
	
	# Connect signals for global settings.
	default_preview_path_setting.button.pressed.connect(file_dialog.popup_default_preview_dialog)
	
	# Connect signals for template settings.
	add_template_button.pressed.connect(create_template_setting)
	add_folder_button.pressed.connect(folder_tree.create_item)

func _exit_tree() -> void:
	# Disconnect signals for local buttons.
	close_settings_button.pressed.disconnect(close)
	
	# Disconnect signals for global settings.
	default_preview_path_setting.button.pressed.disconnect(file_dialog.popup_default_preview_dialog)
	
	# Disconnect signals for template settings.
	add_template_button.pressed.disconnect(create_template_setting)
	add_folder_button.pressed.disconnect(folder_tree.create_item)
	
	write_config_file()

#region Settings Menu

## Open the settings menu.
func popup() -> void:
	if visible == false:
		visible = true

## Close the settings menu.
func close() -> void:
	if visible == true:
		visible = false

## Update all settings properties with their coresponding config properties.
## Called every time the config property is changed.
func refresh() -> void:
	#region Global Settings
	
	# Update directory.
	if directory != config.directory:
		directory = config.directory
	
	# Update default preview.
	default_preview_path_setting.path.text = config.default_preview
	
	#endregion
	
	#region Template Settings
	
	# Free all templates from the settings menu
	clear_templates()
	
	# Rebuild all templates from config.
	for label: String in config.templates:
		var path: String = config.templates.get(label)
		create_template_setting(label, path)
	
	#endregion

#endregion

#region Config Read/Write

## Read the config file and write it to the config property. Update settings menu.
## Triggers refresh() and write_config_file().
func read_config_file() -> void:
	var contents = FileAccess.get_file_as_string(CONFIG)
	var settings = JSON.parse_string(contents)
	
	config = settings

## Read the config property and write it to the config file. Update settings menu.
func write_config_file() -> void:
	var config_file = FileAccess.open(CONFIG, FileAccess.WRITE_READ)
	
	config_file.store_string(JSON.stringify(config))
	config_file.close()

#endregion

#region Global Settings

## Set the specified directory to the config.directory, the directory property, then write to config file.
func set_config_directory(dir_path: String) -> void:
	if config.directory != dir_path:
		config.directory = dir_path

## Set the specified path to the config.default_preview, then write to config file.
func set_config_default_preview(file_path: String) -> void:
	if config.default_preview != file_path:
		config.default_preview = file_path

#endregion

#region Template Settings

## Adds a new entry to config.templates.
func add_config_template_file(file_path: String, file_name: String = "New Template") -> void:
	# Add template to config.templates.
	config.templates.merge({file_name : file_path})

## Update an existing template file with a new path.
func update_config_template_label(path: String, old_label: String, new_label: String) -> void:
	config.templates.erase(old_label)
	
	# Merge a new entry into config.templates using the new label and old path.
	config.templates.merge({new_label : path})

# FIXME - ## Update an existing template file with a new name.
func update_config_template_path(label: String, old_path: String, new_path: String) -> void:
	# Overwrite the existing config.templates entry using the old label and new path.
	config.templates.merge({label : new_path}, true)

## Instantiate and configure a new PathSetting and add it to the templates settings menu.
func create_template_setting(file_name: String = "", file_path: String = "") -> void:
	# Instantiate a new PathSetting.
	var path_setting: ZudeToolsPathSetting = PATH_SETTING.instantiate()
	templates.add_child(path_setting)
	
	# Configure path setting.
	path_setting.label_text = file_name
	path_setting.label_placeholder = "Template Name"
	path_setting.path_text = file_path
	path_setting.path_placeholder = "template.psd"
	path_setting.button_text = "Select File"
	
	# Connect path setting label to update_config_template_label().
	path_setting.label_updated.connect(update_config_template_label)
	# Connect path setting path to update_config_template_path().
	path_setting.path_updated.connect(update_config_template_path)
	# Connect path setting button to template file dialog.
	path_setting.send_setting.connect(file_dialog.popup_template_file_dialog)

## Remove all template entries from the settings menu so they can be rebuilt from config.
func clear_templates() -> void:
	for child in templates.get_children():
		if child != add_template_button:
			child.queue_free()

#endregion
