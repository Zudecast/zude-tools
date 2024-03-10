@tool
class_name ZudeToolsHeroPanel
extends Control

#region Onready Variables

@onready var title: LinkButton = %Title
@onready var preview_link: LinkButton = %ImageLink
@onready var preview: TextureRect = %Image
@onready var video: VideoStreamPlayer = %Video

#endregion

## Refresh the hero panel with the focused card.
func refresh(card: ZudeToolsCard) -> void:
	title.text = card.title
	title.uri = card.path
	preview_link.uri = card.path
	preview.texture = card.button.icon

## Clear the hero panel variables and return them to defaults.
func clear() -> void:
	title.text = "Select an episode..."
	preview.texture = null

## Toggle hero panel visibility.
func toggle_visibility() -> void:
	visible = !visible
