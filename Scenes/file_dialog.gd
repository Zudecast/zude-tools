@tool
class_name ZudeToolsFileDialog
extends FileDialog

#region Onready Variables

@onready var editor: ZudeToolsEditor = $"../ZudeToolsEditor"
@onready var settings: ZudeToolsSettings = $"../ZudeToolsSettings"

#endregion

## Pop up file explorer dialog with configued settings.
func popup_dialog(dialog_title: String = "Open...", dialog_file_mode: FileDialog.FileMode = FileDialog.FILE_MODE_OPEN_ANY) -> void:
	title = dialog_title
	file_mode = dialog_file_mode
	use_native_dialog = true
	visible = true

## Pop up file explorer dialog to select a directory.
func popup_directory_dialog() -> void:
	dir_selected.connect(settings.set_config_directory, CONNECT_ONE_SHOT)
	popup_dialog("Open a directory...", FileDialog.FILE_MODE_OPEN_DIR)

## Pop up file explorer dialog to select a default preview image.
func popup_image_dialog(path_setting: ZudeToolsPathSetting) -> void:
	file_selected.connect(path_setting.select_path, CONNECT_ONE_SHOT)
	file_selected.connect(clear_filters, CONNECT_ONE_SHOT)
	add_filter("*.jpg, *.png", "Image Files")
	popup_dialog("Open an image...", FileDialog.FILE_MODE_OPEN_FILE)

## Pop up file explorer dialog to select a default preview image.
func popup_template_dialog(path_setting: ZudeToolsPathSetting) -> void:
	## Connect to the path setting that popped the dialog and cal its update_path.
	file_selected.connect(path_setting.select_path, CONNECT_ONE_SHOT)
	file_selected.connect(clear_filters, CONNECT_ONE_SHOT)
	add_filter("*.psd, *.kra, *.krz", "Template Files")
	popup_dialog("Open a template...", FileDialog.FILE_MODE_OPEN_FILE)
