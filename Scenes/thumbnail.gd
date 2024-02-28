class_name Thumbnail
extends Control

#region Onready Variables

@onready var thumb_button = %ThumbButton
@onready var thumb_title: Label = %ThumbTitle
@onready var thumb_preview: TextureRect = %ThumbImage

#endregion

#region Variables

## A file name.
var title: String
## An image file path.
var preview: String

#endregion

## Update title and preview.
func _ready() -> void:
	set_title()
	set_preview()

## Set the thumb_title node's text to the internal title property.
func set_title() -> void:
	thumb_title.text = title

## Set the thumb_preview node's image to a new image created from the file path stored in the preview property.
func set_preview() -> void:
	var image = Image.new()
	image.load(preview)
	var texture = ImageTexture.create_from_image(image)
	thumb_preview.texture = texture
