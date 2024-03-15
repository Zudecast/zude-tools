@tool
class_name ZudeToolsCardFolder
extends ZudeToolsCard

#region Variables

## Contains a directory name as key and its path as value.
var directories: Dictionary
## Contains a directory name as key and a PackedStringArray of file paths as value.
var files: Dictionary

#endregion

func _ready() -> void:
	directories = FileUtils.get_directories(path)
	files = FileUtils.get_files(directories)
	
	super()

func _exit_tree() -> void:
	super()

## Set the card texture.
func update_preview() -> void:
	var file_path: String = Config.preview
	
	# Check for a preview image candidate.
	if files.has("main_thumb"):
		var dir_files: PackedStringArray = files.get("main_thumb")
		if dir_files.is_empty() == false:
			for file_name: String in dir_files:
				if file_name.is_valid_filename() and file_name.get_extension() in ["jpg"]:
					file_path = directories.get("main_thumb")
					file_path = file_path.path_join(file_name)
	
	# Check if we generated a file_path other than Config.preview
	if file_path.get_extension() in ["tres"]:
		preview.texture = load(file_path)
	else:
		var image := Image.new()
		image.load(file_path)
		preview.texture = ImageTexture.create_from_image(image)
