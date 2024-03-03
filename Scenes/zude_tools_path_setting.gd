@tool
class_name ZudeToolsPathSetting
extends Control

#region Onready Variables

@onready var label: LineEdit = %PathSettingLabel
@onready var path: LineEdit = %PathSettingPath
@onready var select_button: Button = %PathSettingButton
@onready var delete_button: Button = %DeletePathButton

#endregion

#region Export Variables

@export var editable_label: bool = true:
	set(val):
		editable_label = val
		if label and label.editable != editable_label:
			label.editable = editable_label

@export var label_text: String:
	set(string):
		label_text = string
		if label and label.text != label_text:
			label.text = label_text

@export var label_placeholder: String:
	set(string):
		label_placeholder = string
		if label and label.placeholder_text != label_placeholder:
			label.placeholder_text = label_placeholder

@export var path_text: String:
	set(string):
		path_text = string
		if path and path.text != path_text:
			path.text = path_text

@export var path_placeholder: String:
	set(string):
		path_placeholder = string
		if path and path.placeholder_text != path_placeholder:
			path.placeholder_text = path_placeholder

@export var button_text: String:
	set(string):
		button_text = string
		if select_button and select_button.text != button_text:
			select_button.text = button_text

@export var show_delete: bool = true:
	set(val):
		show_delete = val
		if delete_button and delete_button.visible != show_delete:
			delete_button.visible = show_delete

#endregion

#region Signals

signal label_updated(new: String, prev: String, path: String)
signal path_updated(new: String, label: String)
signal path_selected(path: String)
signal dialog_requested(ZudeToolsPathSetting)
signal setting_deleted(ZudeToolsPathSetting)

#endregion

func _ready() -> void:
	# Connect to a related update methods.
	label.text_submitted.connect(update_label)
	path.text_submitted.connect(update_path)
	select_button.pressed.connect(request_dialog)
	delete_button.pressed.connect(delete_setting)
	
	# Force export properties to update onready properties.
	label.editable = editable_label
	label.text = label_text
	label.placeholder_text = label_placeholder
	path.text = path_text
	path.placeholder_text = path_placeholder
	select_button.text = button_text
	delete_button.visible = show_delete

func _exit_tree() -> void:
	label.text_submitted.disconnect(update_label)
	path.text_submitted.disconnect(update_path)
	select_button.pressed.disconnect(request_dialog)
	delete_button.pressed.disconnect(delete_setting)

#region Signal Updates

## Called when label.text_submitted is emitted.
func update_label(new_label: String) -> void:
	label_updated.emit(new_label, label_text, path_text)
	label_text = new_label

## Called when path.text_submitted is emitted.
func update_path(new_path: String) -> void:
	path_updated.emit(new_path, label_text)
	path_text = new_path

## Called when file_dialog.file_selected is emitted.
func select_path(new_path: String) -> void:
	path_selected.emit(path)
	path_text = new_path

## Called when select_button.pressed is emitted. Sends self to the file dialog to call select_path.
func request_dialog() -> void:
	dialog_requested.emit(self)

## Called when delete_button.pressed is emitted.
func delete_setting() -> void:
	setting_deleted.emit(label_text)
	queue_free()

#endregion
