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
func popup_default_preview_dialog() -> void:
	file_selected.connect(settings.set_config_default_preview, CONNECT_ONE_SHOT)
	file_selected.connect(clear_filters, CONNECT_ONE_SHOT)
	add_filter("*.jpg, *.png", "Image Files")
	popup_dialog("Open an image...", FileDialog.FILE_MODE_OPEN_FILE)

# FIXME - setting not used ## Pop up file explorer dialog to select a default preview image.
func popup_template_file_dialog(setting: ZudeToolsPathSetting) -> void:
	file_selected.connect(settings.update_config_template_path, CONNECT_ONE_SHOT)
	file_selected.connect(clear_filters, CONNECT_ONE_SHOT)
	add_filter("*.psd, *.kra, *.krz", "Template Files")
	popup_dialog("Open a template...", FileDialog.FILE_MODE_OPEN_FILE)
