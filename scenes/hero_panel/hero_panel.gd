@tool
class_name ZudeToolsHero
extends ZudeTools

@onready var title = %Title
@onready var image = %Image
@onready var video = %Video

func refresh(episode: ZudeToolsCardEpisode) -> void:
	clear()
	
	title.text = episode.title.text
	image.texture = episode.preview.texture

## Clear the hero panel variables and return them to defaults.
func clear() -> void:
	title.text = "Select an episode..."
	image.texture = null

## Toggle Hero visibilie=ty
func toggle_visibility() -> void:
	visible = !visible
