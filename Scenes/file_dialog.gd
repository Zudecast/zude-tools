class_name ZudeToolsFileDialog
extends FileDialog

#region Onready Variables

@onready var zude_tools = $".."

#endregion

## Pop up file explorer dialog with configued settings.
func popup_dialog(dialog_title: String = "Open...", dialog_file_mode: FileDialog.FileMode = FileDialog.FILE_MODE_OPEN_ANY) -> void:
	title = dialog_title
	file_mode = dialog_file_mode
	use_native_dialog = true
	visible = true

## Pop up file explorer dialog to select a directory.
func popup_directory_dialog() -> void:
	dir_selected.connect(zude_tools.settings.write_directory, CONNECT_ONE_SHOT)
	popup_dialog("Open a directory...", FileDialog.FILE_MODE_OPEN_DIR)
