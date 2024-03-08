@tool
class_name ZudeToolsSettings
extends Control

#region Constants

const PATH_SETTING: PackedScene = preload("res://scenes/settings/path_setting.tscn")

#endregion

#region Onready Variables

@onready var global: VBoxContainer = %GlobalVBox
@onready var default_preview: ZudeToolsPathSetting = %DefaultPreview

@onready var templates: VBoxContainer = %TemplatesVBox
@onready var add_template_button: Button = %AddTemplateButton

@onready var folder_tree: Tree = %FolderTree
@onready var add_folder_button: Button = %AddFolderButton

#endregion

func _ready() -> void:
	Config.settings_refresh_requested.connect(refresh_interface)
	# Connect signals for the general interface.
	visibility_changed.connect(refresh_interface)
	# Connect signals for global path settings.
	default_preview.path_updated.connect(Config.set_preview)
	default_preview.dialog_requested.connect(Dialog.popup_image_dialog)
	# Connect signals for template path settings.
	add_template_button.pressed.connect(create_template_setting)
	# Connect signals for folder tree settings.
	add_folder_button.pressed.connect(folder_tree.create_tree_item)

func _exit_tree() -> void:
	Config.settings_refresh_requested.disconnect(refresh_interface)
	# Disconnect signals for the general interface.
	visibility_changed.disconnect(refresh_interface)
	# Disconnect signals for global settings.
	default_preview.path_updated.disconnect(Config.set_preview)
	default_preview.dialog_requested.disconnect(Dialog.popup_image_dialog)
	# Disconnect signals for template settings.
	add_template_button.pressed.disconnect(create_template_setting)
	# Disconnect signals for folder tree settings.
	add_folder_button.pressed.disconnect(folder_tree.create_tree_item)

#region Interface

## Called every time Config changes or the visibility_changed signal is emitted.
func refresh_interface() -> void:
	if visible:
		refresh_global_menu()
		refresh_template_menu()
		folder_tree.refresh_folder_tree_menu()
		print("Settings interface refreshed.")

## Open the settings menu.
func toggle_interface() -> void:
	visible = !visible

## Update all global settings from config.
func refresh_global_menu() -> void:
	if Config.settings.preview != null:
		default_preview.path.text = Config.settings.preview

## Clear template PathSettings from the templates settings menu then rebuild them from config.
func refresh_template_menu() -> void:
	for child in templates.get_children():
		if child != add_template_button:
			child.queue_free()
		
	if Config.settings.templates.is_empty() == false:
		for label: String in Config.settings.templates:
			var path: String = Config.settings.templates.get(label)
			create_template_setting(label, path)

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
	
	# Connect path setting to relevant signals.
	path_setting.label_updated.connect(Config.set_template_label)
	path_setting.path_updated.connect(Config.set_template_path)
	path_setting.dialog_requested.connect(Dialog.popup_template_dialog)
	path_setting.setting_deleted.connect(Config.remove_template, CONNECT_ONE_SHOT)
