class_name ZudeToolsSettings
extends Control

#region Constants

const CONFIG = "res://config.json"

#endregion

#region Onready Variables

@onready var editor: ZudeToolsEditor = $"../ZudeToolsEditor"
@onready var file_dialog: ZudeToolsFileDialog = $"../ZudeToolsFileDialog"

@onready var close_settings_button: Button = %CloseSettingsButton
@onready var settings_category_list: VBoxContainer = %SettingsCategoryListVBox

#endregion

#region Variables

var directory: String:
	set(path):
		directory = path
		editor.refresh()

var config: Dictionary = {
	"default_preview" : "res://zudecast.png",
	"directory" : directory,
	"templates" : [
		{}
	]
}

#endregion

func _ready() -> void:
	read_config_file()
	
	close_settings_button.pressed.connect(close)

func _exit_tree() -> void:
	close_settings_button.pressed.disconnect(close)

## Open the settings menu.
func popup() -> void:
	if visible == false:
		visible = true

## Close the settings menu.
func close() -> void:
	if visible == true:
		visible = false

## Read the config file and write it to the config property.
func read_config_file() -> void:
	var contents = FileAccess.get_file_as_string(CONFIG)
	var settings = JSON.parse_string(contents)
	
	config = settings
	directory = config.directory

## Write the config property to the config file.
func write_config_file() -> void:
	var config_file = FileAccess.open(CONFIG, FileAccess.WRITE_READ)
	
	config_file.store_string(JSON.stringify(config))
	config_file.close()
	
	prints("Wrote config:", config)

## Set the specified directory to the config.directory, the directory property, then write to config file.
func set_directory(dir: String) -> void:
	config.directory = dir
	directory = config.directory
	write_config_file()

## Set the path to the config.default_preview, then write to config file.
func set_default_preview(path: String) -> void:
	config.default_preview = path
	write_config_file()
	
