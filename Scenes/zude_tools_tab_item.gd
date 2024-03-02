class_name ZudeToolsTabItem
extends Control

#region Onready Variables

@onready var title: Label = %ThumbTitle
@onready var preview: TextureRect = %ThumbImage
@onready var button = %ThumbButton

#endregion

func _ready() -> void:
	# TODO - button.pressed.connect()
	pass

## Set the thumb_title node's text to the internal title property.
func set_title(text: String) -> void:
	title.text = text

## Set the thumb_preview node's image to a new image created from the file path stored in the preview property.
func set_preview(path: String) -> void:
	var image := Image.new()
	image.load(path)
	var texture := ImageTexture.create_from_image(image)
	preview.texture = texture
