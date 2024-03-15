@tool
class_name ZudeToolsEditor
extends Control

#region Onready Variables

@onready var episode_panel: ZudeToolsEpisodePanel = %EpisodePanel
@onready var hero_panel: ZudeToolsHeroPanel = %HeroPanel
@onready var tab_panel: ZudeToolsTabPanel = %TabPanel

#endregion

func _ready() -> void:
	Config.editor_refresh_requested.connect(refresh_top)
	Config.directory_set.connect(reset_interface)
	Config.preview_set.connect(refresh_top)

func _exit_tree() -> void:
	Config.editor_refresh_requested.disconnect(refresh_top)
	Config.directory_set.disconnect(reset_interface)
	Config.preview_set.disconnect(refresh_top)

## Refresh episode panel.
func refresh_top() -> void:
	episode_panel.refresh()

## Refresh hero panel and tabs container.
func refresh_btm(episode: ZudeToolsCardFolder) -> void:
	hero_panel.refresh(episode)
	tab_panel.refresh(episode)

## Clear and reload all interface properties.
func reset_interface() -> void:
	hero_panel.clear()
	tab_panel.clear()
	refresh_top()

## Hide the editor and show the settings menu.
func toggle_interface() -> void:
	visible = !visible
