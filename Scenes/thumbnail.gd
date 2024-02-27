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

func _ready() -> void:
	set_title()
	set_preview()

func set_title() -> void:
	thumb_title.text = title

func set_preview() -> void:
	var image = Image.new()
	image.load(preview)
	var texture = ImageTexture.create_from_image(image)
	thumb_preview.texture = texture
