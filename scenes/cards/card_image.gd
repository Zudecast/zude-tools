@tool
class_name ZudeToolsCardImage
extends ZudeToolsCard

#region Onready Variables

@onready var title: LineEdit = %ImageTitle
@onready var preview: TextureRect = %ImagePreview
@onready var button: Button = %ImageButton

#endregion

signal focused(ZudeToolsCardImage)

func _ready() -> void:
	button.focus_entered.connect(focus_changed)

func _exit_tree() -> void:
	button.focus_entered.disconnect(focus_changed)

## Emit the focused signal (returning self) when the focus_entered signal is also emitted.
func focus_changed() -> void:
	focused.emit(self)

## Set the title node's text.
func set_title(text: String) -> void:
	title.text = text

## Set the preview node's texture.
func set_preview(texture: Texture2D) -> void:
	preview.texture = texture
