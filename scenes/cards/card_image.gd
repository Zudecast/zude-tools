@tool
class_name ZudeToolsCardImage
extends ZudeToolsCard

#region Onready Variables

@onready var title: LineEdit = %ImageTitle
@onready var preview: TextureRect = %ImagePreview
@onready var button: Button = %ImageButton

#endregion

func _ready() -> void:
	button.focus_entered.connect(focus_changed)

func _exit_tree() -> void:
	button.focus_entered.disconnect(focus_changed)

## Set the title node's text.
func set_title(text: String) -> void:
	name = text
	title.text = text
	tooltip_text = text

## Set the preview node's texture.
func set_preview(texture: Texture2D) -> void:
	preview.texture = texture
