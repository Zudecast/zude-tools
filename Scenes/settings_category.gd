class_name ZudeToolsSettingsCategory
extends Control

# FIXME - Again, it's all fucked.

#region Constants

const PATH_SETTING = preload("res://Scenes/path_setting.tscn")

#endregion

#region Onready Variables

@onready var settings_category_list: VBoxContainer = %SettingsCategoryVBox

#endregion

# Instantiate a PathSetting
func add_path_setting() -> void:
	var path_setting = PATH_SETTING.instantiate()
	settings_category_list.add_child(path_setting)
