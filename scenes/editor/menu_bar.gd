@tool
class_name ZudeToolsMenuBar
extends Control

#region Export Variables

@export var editor: ZudeToolsEditor
@export var episode_panel: ZudeToolsEpisodePanel
@export var settings: ZudeToolsSettings

#endregion

#region Onready Variables

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
	open_production_button.pressed.connect(Dialog.popup_directory_dialog)
	new_episode_button.pressed.connect(episode_panel.new_episode)
	
	refresh_button.pressed.connect(editor.refresh_top)
	settings_button.pressed.connect(editor.toggle_interface)
	settings_button.pressed.connect(settings.toggle_interface)

func _exit_tree() -> void:
	open_production_button.pressed.disconnect(Dialog.popup_directory_dialog)
	new_episode_button.pressed.disconnect(episode_panel.new_episode)
	
	refresh_button.pressed.disconnect(editor.refresh_top)
	settings_button.pressed.disconnect(editor.toggle_interface)
	settings_button.pressed.disconnect(settings.toggle_interface)
