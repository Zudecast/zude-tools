@tool
class_name ZudeToolsHeroPanel
extends Control

#region Onready Variables

@onready var label: Label = %Label
@onready var link: LinkButton = %Link
@onready var preview: TextureRect = %Preview

#endregion

var card: ZudeToolsCard

func _ready() -> void:
	label.text = "Select an item..."
	link.uri = ""

## Refresh the hero panel with the focused card.
func refresh(focused_card: ZudeToolsCard) -> void:
	preview.texture = focused_card.preview.texture
	label.text = focused_card.title
	link.uri = focused_card.path
	
	match focused_card:
		ZudeToolsCardEpisode:
			pass
		ZudeToolsCardImage:
			pass
		ZudeToolsCardVideo:
			pass

## Clear the hero panel.
func clear() -> void:
	label.text = "Select an item..."
	link.uri = ""

## Toggle hero panel visibility.
func toggle_visibility() -> void:
	visible = !visible
