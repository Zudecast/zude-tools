@tool
class_name ZudeToolsCardVideo
extends ZudeToolsCard

#region Onready Variables

@onready var label: LineEdit = %Title
@onready var preview: ZudeToolsVideoPlayer = %Preview
@onready var button: Button = %Button

#endregion

func _ready() -> void:
	button.focus_entered.connect(focus_changed)
	
	update_label()
	update_preview()

func _exit_tree() -> void:
	button.focus_entered.disconnect(focus_changed)

func update_label() -> void:
	name = title
	label.text = title
	tooltip_text = title

## Set the video node's stream file to the specified path.
func update_preview() -> void:
	preview.video.stream.file = path
