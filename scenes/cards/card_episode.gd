@tool
class_name ZudeToolsCardEpisode
extends ZudeToolsCard

#region Variables

## Contains a directory name as key and its path as value.
var directories: Dictionary
## Contains a directory name as key and a PackedStringArray of file paths as value.
var files: Dictionary

#endregion

func _ready() -> void:
	get_directories()
	get_files()
	
	super()

func _exit_tree() -> void:
	super()
	
	files.clear()
	directories.clear()

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

## Get all directories within this episode's directory. Directory name is key and its path is value.
func get_directories(at_path: String = path) -> void:
	var dirs: PackedStringArray = DirAccess.get_directories_at(at_path)
	
	for dir: String in dirs:
		var dir_path: String = at_path.path_join(dir)
		directories.merge({dir : dir_path})
		get_directories(dir_path)

## Get all files within the directories dictionary. Directory name is key and a PackedStringArray of files is value.
func get_files() -> void:
	for dir: String in directories.keys():
		var dir_path: String = directories[dir]
		var dir_files: PackedStringArray = DirAccess.get_files_at(dir_path)
		if dir_files.size() > 0:
			files.merge({dir : dir_files})
		else:
			files.merge({dir : []})
