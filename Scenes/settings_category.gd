@tool
class_name ZudeToolsSettingsCategory
extends Control

# FIXME - Again, it's all fucked.

#region Constants

const SETTINGS_PATH = preload("res://Scenes/settings_path.tscn")

#endregion

#region Onready Variables

@export var settings_category_label: Label
@export var toggle_category_button: Button
@export var settings_category_list: VBoxContainer
@export var add_path_button: Button

#endregion

#region Export Variables

@export var category_label: String:
	set(string):
		category_label = string
		settings_category_label.text = category_label

@export var show_add_path_button: bool = false:
	set(val):
		show_add_path_button = val
		add_path_button.visible = show_add_path_button

#endregion

func _ready():
	toggle_category_button.pressed.connect(toggle_visiblity)
	add_path_button.pressed.connect(add_path_setting)

func _exit_tree() -> void:
	toggle_category_button.pressed.disconnect(toggle_visiblity)
	add_path_button.pressed.disconnect(add_path_setting)

func toggle_visiblity() -> void:
	settings_category_list.visible = !settings_category_list.visible

func add_path_setting() -> void:
	var path_setting = SETTINGS_PATH.instantiate()
	settings_category_list.add_child(path_setting)
