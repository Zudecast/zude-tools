@tool
class_name EditorBarTop
extends Control

#region Onready Variables

@onready var editor = $"../ZudeToolsEditor"
@onready var settings = $"../ZudeToolsSettings"

@onready var bar_left: HBoxContainer = %BarLeft
@onready var new_episode_button: Button = %NewEpisodeButton
@onready var open_production_button: Button = %OpenProductionButton

@onready var bar_center: HBoxContainer = %BarCenter
@onready var episode_size_slider: HSlider = %EpisodeSizeSlider

@onready var bar_right: HBoxContainer = %BarRight
@onready var refresh_button: Button = %RefreshButton
@onready var settings_button: Button = %SettingsButton

#endregion

func _ready():
	if editor:
		refresh_button.pressed.connect(editor.refresh_interface)
		new_episode_button.pressed.connect(editor.load_episode)
		settings_button.pressed.connect(editor.toggle_interface)
	if settings:
		settings_button.pressed.connect(settings.toggle_interface)
	
	open_production_button.pressed.connect(Dialog.popup_directory_dialog)

func _exit_tree() -> void:
	if editor:
		refresh_button.pressed.disconnect(editor.refresh_interface)
		new_episode_button.pressed.disconnect(editor.load_episode)
		settings_button.pressed.disconnect(editor.toggle_interface)
	if settings:
		settings_button.pressed.disconnect(settings.toggle_interface)
	
	open_production_button.pressed.disconnect(Dialog.popup_directory_dialog)
