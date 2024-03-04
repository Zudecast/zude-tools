@tool
extends FileDialog

## Pop up file explorer dialog with configued settings.
func popup_dialog(dialog_title: String = "Open...", dialog_file_mode: FileDialog.FileMode = FileDialog.FILE_MODE_OPEN_ANY) -> void:
	title = dialog_title
	file_mode = dialog_file_mode
	access = FileDialog.ACCESS_FILESYSTEM
	use_native_dialog = true
	popup_window = true
	visible = true

## Pop up file explorer dialog to select a directory.
func popup_directory_dialog() -> void:
	clear_filters()
	dir_selected.connect(Config.set_directory, CONNECT_ONE_SHOT)
	popup_dialog("Open a directory...", FileDialog.FILE_MODE_OPEN_DIR)

## Pop up file explorer dialog to select a default preview image.
func popup_image_dialog(path_setting: ZudeToolsPathSetting) -> void:
	clear_filters()
	add_filter("*.jpg, *.png", "Image Files")
	## Connect to the path setting that popped the dialog and call its update_path.
	file_selected.connect(path_setting.update_path, CONNECT_ONE_SHOT)
	popup_dialog("Open an image...", FileDialog.FILE_MODE_OPEN_FILE)

## Pop up file explorer dialog to select a default preview image.
func popup_template_dialog(path_setting: ZudeToolsPathSetting) -> void:
	clear_filters()
	add_filter("*.psd, *.kra, *.krz", "Template Files")
	## Connect to the path setting that popped the dialog and call its update_path.
	file_selected.connect(path_setting.update_path, CONNECT_ONE_SHOT)
	popup_dialog("Open a template...", FileDialog.FILE_MODE_OPEN_FILE)
