@tool
class_name ZudeToolsEditor
extends Control

#region Onready Variables

@onready var episode_panel: ZudeToolsEpisodePanel = %EpisodePanel
@onready var hero_panel: ZudeToolsHeroPanel = %HeroPanel
@onready var tab_panel: ZudeToolsTabPanel = %TabPanel

#endregion

func _ready() -> void:
	Config.directory_set.connect(refresh)
	Config.preview_set.connect(episode_panel.refresh)
	Config.editor_refresh_requested.connect(episode_panel.refresh)

func _exit_tree() -> void:
	Config.directory_set.disconnect(refresh)
	Config.preview_set.disconnect(episode_panel.refresh)
	Config.editor_refresh_requested.disconnect(episode_panel.refresh)

## Refresh all editor UI elements.
func refresh() -> void:
	episode_panel.refresh()
	hero_panel.refresh()
	tab_panel.refresh()

## Hide the editor so the settings menu can be shown.
func toggle_interface() -> void:
	visible = !visible
