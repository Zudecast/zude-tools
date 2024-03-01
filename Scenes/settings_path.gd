@tool
class_name ZudeToolsSettingsPath
extends Control

# FIXME - Yes, the whole thing is fucked.

#region Export Variables

@export var settings_path_label: LineEdit
@export var settings_path_line_edit: LineEdit
@export var settings_path_button: Button

@export var editable_label: bool = true:
	set(val):
		editable_label = val
		settings_path_label.editable = editable_label

@export var label_text: String:
	set(string):
		label_text = string
		settings_path_label.text = label_text

@export var label_placeholder: String:
	set(string):
		label_placeholder = string
		settings_path_label.placeholder_text = label_placeholder

@export var line_placeholder: String:
	set(string):
		line_placeholder = string
		settings_path_line_edit.placeholder_text = line_placeholder

@export var button_text: String:
	set(string):
		button_text = string
		settings_path_button.text = button_text

var path: String:
	set(string):
		path = string
		settings_path_line_edit.text = path

#endregion

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
