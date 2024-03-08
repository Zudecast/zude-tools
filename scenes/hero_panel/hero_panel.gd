@tool
class_name ZudeToolsHeroPanel
extends Control

#region Onready Variables

@onready var title = %Title
@onready var image = %Image
@onready var video = %Video

#endregion

## Refresh the hero panel witht he focused episode.
func refresh(episode: ZudeToolsCardEpisode) -> void:
	clear()
	
	title.text = episode.title
	image.texture = episode.preview.texture

## Clear the hero panel variables and return them to defaults.
func clear() -> void:
	title.text = "Select an episode..."
	image.texture = null

## Toggle hero panel visibility.
func toggle_visibility() -> void:
	visible = !visible
