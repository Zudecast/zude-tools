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
@onready var production_link: LinkButton = %ProductionLink

@onready var bar_right: HBoxContainer = %BarRight
@onready var refresh_button: Button = %RefreshButton
@onready var settings_button: Button = %SettingsButton

#endregion

func _ready():
	Config.settings_refresh_requested.connect(set_production_link)
	Config.settings_refresh_requested.connect(refresh_buttons_visibility)
	open_production_button.pressed.connect(Dialog.popup_directory_dialog)
	new_episode_button.pressed.connect(episode_panel.new_episode)
	
	refresh_button.pressed.connect(editor.refresh_top)
	refresh_button.pressed.connect(editor.refresh_btm)
	settings_button.pressed.connect(editor.toggle_interface)
	settings_button.pressed.connect(settings.toggle_interface)

func _exit_tree() -> void:
	Config.settings_refresh_requested.disconnect(set_production_link)
	Config.settings_refresh_requested.disconnect(refresh_buttons_visibility)
	open_production_button.pressed.disconnect(Dialog.popup_directory_dialog)
	new_episode_button.pressed.disconnect(episode_panel.new_episode)
	
	refresh_button.pressed.disconnect(editor.refresh_top)
	refresh_button.pressed.disconnect(editor.refresh_btm)
	settings_button.pressed.disconnect(editor.toggle_interface)
	settings_button.pressed.disconnect(settings.toggle_interface)

func refresh_buttons_visibility() -> void:
	if Config.settings.directory == null:
		new_episode_button.visible = false
		production_link.visible = false
	else:
		new_episode_button.visible = true
		production_link.visible = true

func set_production_link() -> void:
	production_link.text = Config.settings.directory
	production_link.uri = Config.settings.directory
