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

var config: Dictionary = {
	"default_preview" : "res://zudecast.png",
	"directory" : null,
	"templates" : {}
}:
	set(dict):
		config = dict
		write_config_file()
		refresh_menu()

#endregion

func _ready() -> void:
	read_config_file()
	
	# Connect signals for local buttons.
	close_settings_button.pressed.connect(close_menu)
	
	# Connect signals for global settings.
	default_preview_path_setting.path_updated.connect(set_config_default_preview)
	default_preview_path_setting.path_selected.connect(set_config_default_preview)
	default_preview_path_setting.dialog_requested.connect(file_dialog.popup_image_dialog)
	
	# Connect signals for template settings.
	add_template_button.pressed.connect(create_template_path_setting)
	add_folder_button.pressed.connect(folder_tree.create_item)
	
	editor.refresh()

func _exit_tree() -> void:
	# Disconnect signals for local buttons.
	close_settings_button.pressed.disconnect(close_menu)
	
	# Disconnect signals for global settings.
	default_preview_path_setting.path_updated.disconnect(set_config_default_preview)
	default_preview_path_setting.path_selected.disconnect(set_config_default_preview)
	default_preview_path_setting.dialog_requested.disconnect(file_dialog.popup_image_dialog)
	
	# Disconnect signals for template settings.
	add_template_button.pressed.disconnect(create_template_path_setting)
	add_folder_button.pressed.disconnect(folder_tree.create_item)
	
	write_config_file()

#region Settings Menu

## Called every time the config property is updated. Calls a chain of other updates.
func refresh_menu() -> void:
	# Update default preview PathSetting.
	if default_preview_path_setting.path.text != config.default_preview:
		default_preview_path_setting.path.text = config.default_preview
	
	# Rebuild all templates from config.
	refresh_template_path_settings()

## Open the settings menu.
func popup_menu() -> void:
	if visible == false:
		visible = true

## Close the settings menu.
func close_menu() -> void:
	if visible == true:
		visible = false

#endregion

#region Config Read/Write

## Read the config file and write it to the config property.
func read_config_file() -> void:
	var contents = FileAccess.get_file_as_string(CONFIG)
	var settings = JSON.parse_string(contents)
	
	config = settings

## Read the config property and write it to the config file.
func write_config_file() -> void:
	var config_file = FileAccess.open(CONFIG, FileAccess.WRITE)
	
	config_file.store_string(JSON.stringify(config))
	config_file.close()

#endregion

#region Global Settings

## Set the specified directory to the config.directory, the directory property, then write to config file.
func set_config_directory(new_path: String) -> void:
	if config.directory != new_path:
		config.directory = new_path
	editor.refresh()

## Set the specified path to the config.default_preview, then write to config file.
func set_config_default_preview(new_path: String) -> void:
	if config.default_preview != new_path:
		config.default_preview = new_path
	editor.refresh()

#endregion

#region Template Settings

## Clear template PathSettings from the templates settings menu then rebuild them from config.
func refresh_template_path_settings() -> void:
	for child in templates.get_children():
		if child != add_template_button:
			child.queue_free()
	
	for label: String in config.templates:
		var path: String = config.templates.get(label)
		create_template_path_setting(label, path)

## Instantiate and configure a new PathSetting and add it to the templates settings menu.
func create_template_path_setting(file_name: String = "", file_path: String = "") -> void:
	# Instantiate a new PathSetting.
	var path_setting: ZudeToolsPathSetting = PATH_SETTING.instantiate()
	templates.add_child(path_setting)
	
	# Configure path setting.
	path_setting.label_text = file_name
	path_setting.label_placeholder = "Template Name"
	path_setting.path_text = file_path
	path_setting.path_placeholder = "template.psd"
	path_setting.button_text = "Select File"
	
	# Connect path setting to relevant signals.
	path_setting.label_updated.connect(update_config_template_label)
	path_setting.path_updated.connect(update_config_template_path)
	path_setting.path_selected.connect(update_config_template_path)
	path_setting.dialog_requested.connect(file_dialog.popup_template_dialog)
	path_setting.setting_deleted.connect(remove_config_template, CONNECT_ONE_SHOT)

## Update a template file with a new label, or create it if it does nt exist.
func update_config_template_label(new_label: String, old_label: String, path: String) -> void:
	# Erase the old entry so it can be replaced.
	config.templates.erase(old_label)
	# Merge a new entry into config.templates using the new label and current path.
	config.templates.merge({new_label : path})

## Update a template file with a new path.
func update_config_template_path(new_path: String, label: String) -> void:
	# Overwrite the existing config.templates entry using the current label and new path.
	config.templates.merge({label : new_path}, true)

## Remove an entry from config.templates.
func remove_config_template(label: String) -> void:
	config.templates.erase(label)

#endregion
