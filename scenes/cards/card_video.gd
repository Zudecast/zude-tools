@tool
class_name ZudeToolsCardVideo
extends ZudeToolsCard

#region Onready Variables

@onready var title: LineEdit = %VideoTitle
@onready var video: VideoStreamPlayer = %VideoPreview
@onready var button: Button = $VideoButton

#endregion

func _ready() -> void:
	button.pressed.connect(video.play)
	button.focus_entered.connect(focus_changed)

func _exit_tree() -> void:
	button.pressed.disconnect(video.play)
	button.focus_entered.disconnect(focus_changed)

## Set the title node's text to the specified text.
func set_title(text: String) -> void:
	name = text
	title.text = text
	tooltip_text = text

## Set the video node's stream file to the specified path.
func set_video(path: String) -> void:
	video.stream.file = path
