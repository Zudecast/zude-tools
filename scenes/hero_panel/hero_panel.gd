@tool
class_name ZudeToolsHeroPanel
extends Control

#region Onready Variables

@onready var title: LinkButton = %Title
@onready var image_link: LinkButton = %ImageLink
@onready var image: TextureRect = %Image
@onready var video: VideoStreamPlayer = %Video

#endregion

## Refresh the hero panel with the focused card.
func refresh(card: ZudeToolsCard) -> void:
	clear()
	
	title.text = card.title
	title.uri = card.path
	image_link.uri = card.path
	image.texture = card.preview.texture

## Clear the hero panel variables and return them to defaults.
func clear() -> void:
	title.text = "Select an episode..."
	image.texture = null

## Toggle hero panel visibility.
func toggle_visibility() -> void:
	visible = !visible
