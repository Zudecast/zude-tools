@tool
class_name ZudeToolsCardImage
extends ZudeToolsCard

#region Onready Variables

@onready var label: Label = %Label
@onready var button: Button = %Button

#endregion

func _ready() -> void:
	button.focus_entered.connect(focus_changed)
	
	update_label()
	update_preview()

func _exit_tree() -> void:
	button.focus_entered.disconnect(focus_changed)

## Set the label node's text to the specified text.
func update_label() -> void:
	name = title
	label.text = title
	tooltip_text = title

## Set the preview node's texture.
func update_preview(texture: Texture2D = Config.DEFAULT_PREVIEW) -> void:
	var image = Image.new()
	image.load(path)
	if image.is_empty() == false:
		texture = ImageTexture.create_from_image(image)
	
	button.icon = texture
