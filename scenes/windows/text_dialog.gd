@tool
extends Window

#region Onready Variables

@onready var line: LineEdit = %LineEdit
@onready var confirm_button: Button = %ConfirmButton
@onready var cancel_button: Button = %CancelButton

#endregion

signal confirmed(String)

func _ready() -> void:
	confirm_button.pressed.connect(confirm, CONNECT_ONE_SHOT)
	cancel_button.pressed.connect(queue_free, CONNECT_ONE_SHOT)
	close_requested.connect(queue_free, CONNECT_ONE_SHOT)
	visible = true

func _exit_tree() -> void:
	visible = false

func confirm() -> void:
	if line.text == "":
		confirmed.emit(line.placeholder_text)
		queue_free()
	else:
		confirmed.emit(line.text)
		queue_free()
