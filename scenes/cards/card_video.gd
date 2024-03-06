@tool
class_name ZudeToolsCardVideo
extends ZudeToolsCard

#region Onready Variables

@onready var title: LineEdit = %Title
@onready var preview: ZudeToolsVideoPlayer = %Preview
@onready var button: Button = %Button

#endregion

func _ready() -> void:
	button.focus_entered.connect(focus_changed)

func _exit_tree() -> void:
	button.focus_entered.disconnect(focus_changed)

## Set the title node's text to the specified text.
func set_title(text: String) -> void:
	name = text
	title.text = text
	tooltip_text = text

## Set the video node's stream file to the specified path.
func set_preview(path: String) -> void:
	preview.video.stream.file = path
