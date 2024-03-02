@tool
class_name ZudeToolsPathSetting
extends Control

# FIXME - Yes, the whole thing is fucked.

#region Onready Variables

@onready var label: LineEdit = %PathSettingLabel
@onready var path: LineEdit = %PathSettingPath
@onready var button: Button = %PathSettingButton

#endregion

#region Export Variables

@export var editable_label: bool = true:
	set(val):
		editable_label = val
		if label:
			label.editable = editable_label

@export var label_text: String:
	set(string):
		label_text = string
		if label:
			label.text = label_text

@export var path_text: String:
	set(string):
		path_text = string
		if path:
			path.text = path_text

@export var label_placeholder: String:
	set(string):
		label_placeholder = string
		if label:
			label.placeholder_text = label_placeholder

@export var path_placeholder: String:
	set(string):
		path_placeholder = string
		if path:
			path.placeholder_text = path_placeholder

@export var button_text: String:
	set(string):
		button_text = string
		if button:
			button.text = button_text

#endregion

signal label_updated(prev: String, new: String)
signal path_updated(prev: String, new: String)

func _ready() -> void:
	label.text_submitted.connect(update_label)
	path.text_submitted.connect(update_path)
	
	update()

func _exit_tree() -> void:
	label.text_submitted.disconnect(update_label)
	path.text_submitted.disconnect(update_path)

## Called on node ready to force export properties to update properties in onready properties.
func update() -> void:
	label.editable = editable_label
	label.text = label_text
	label.placeholder_text = label_placeholder
	path.text = path_text
	path.placeholder_text = path_placeholder
	button.text = button_text

## Called when label.text_submitted is emitted.
func update_label(new_label: String) -> void:
	label_updated.emit(label_text, new_label)
	label_text = new_label

## Called when path.text_submitted is emitted.
func update_path(new_path: String) -> void:
	path_updated.emit(path_text, new_path)
	path_text = new_path
