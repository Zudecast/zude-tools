@tool
class_name ZudeToolsTextDialog
extends Window

#region Onready Variables

@onready var production_name: LineEdit = %ProductionName
@onready var episode_number: LineEdit = %EpisodeNumber
@onready var episode_title: LineEdit = %EpisodeTitle
@onready var confirm_button: Button = %ConfirmButton
@onready var cancel_button: Button = %CancelButton

#endregion

signal confirmed(text: String)

func _ready() -> void:
	confirm_button.pressed.connect(confirm, CONNECT_ONE_SHOT)
	cancel_button.pressed.connect(queue_free, CONNECT_ONE_SHOT)
	close_requested.connect(queue_free, CONNECT_ONE_SHOT)
	
	production_name.text = Config.production
	episode_number.text = str(DirAccess.get_directories_at(Config.directory).size() + 1)
	visible = true

func _exit_tree() -> void:
	visible = false

func confirm() -> void:
	var production: String = Config.production
	var ep_number: String = episode_number.text
	var ep_title: String = episode_title.text
	
	if ep_number == "":
		ep_number = episode_number.placeholder_text
	
	if ep_title == "":
		ep_title = episode_title.placeholder_text
	
	var joined_title: String = " ".join([production, ep_number, "-", ep_title])
	
	confirmed.emit(joined_title)
	queue_free()
