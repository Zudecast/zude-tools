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
	read_config()
	
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
func read_config() -> void:
	var config_file = FileAccess.get_file_as_string(CONFIG)
	var settings = JSON.parse_string(config_file)
	
	print(settings)
	
	config = settings
	
	directory = config.directory

## Write the config property to the config file.
func write_config() -> void:
	var config_file = FileAccess.open(CONFIG, FileAccess.WRITE_READ)
	
	config_file.store_string(JSON.stringify(config))
	config_file.close()
	
	prints("Wrote config:", config)

## Write the current directory to the config file and set it internally.
func write_directory(dir: String) -> void:
	config.directory = dir
	directory = config.directory
	write_config()
