@tool
class_name ZudeToolsCardEpisode
extends ZudeToolsCard

#region Onready Variables

@onready var title: LineEdit = %Title
@onready var preview: TextureRect = %Preview
@onready var button: Button = %Button

#endregion

#region Variables

## This episode's directory path.
var directory: String

## Contains a directory name as key and its path as value.
var directories: Dictionary
## Contains a directory name as key and a PackedStringArray of file paths as value.
var files: Dictionary

#endregion

func _ready() -> void:
	get_directories()
	get_files()
	
	button.focus_entered.connect(focus_changed)

func _exit_tree() -> void:
	button.focus_entered.disconnect(focus_changed)
	
	clear_files()
	clear_directories()

## Set the internal directory property for this node.
func set_directory(new_dir: String) -> void:
	directory = new_dir

## Set the title node's text to the specified text.
func set_title(text: String) -> void:
	name = text
	title.text = text
	tooltip_text = text

## Set the preview node's image to the specified path.
func set_preview(texture: Texture2D) -> void:
	preview.texture = texture
	# Check episode directory for a main thumb, use
	if files.has("main_thumb"):
		var dir_files: PackedStringArray = files["main_thumb"]
		
		if dir_files.is_empty():
			return
		
		for file_name: String in dir_files:
			if file_name.is_valid_filename() and file_name.get_extension() in ["jpg"]:
				var path = directories["main_thumb"].path_join(file_name)
				var image = Image.new()
				image.load(path)
				if image.is_empty() == false:
					preview.texture = ImageTexture.create_from_image(image)

## Get all directories within this episode's directory. Directory name is key and its path is value.
func get_directories(path: String = directory) -> void:
	var dirs: PackedStringArray = DirAccess.get_directories_at(path)
	
	for dir: String in dirs:
		var dir_path: String = path.path_join(dir)
		directories.merge({dir : dir_path})
		get_directories(dir_path)
	
	if directories.size() == 0:
		build_directories()

## Build directories based on the folders settings menu for new episodes.
func build_directories() -> void:
	for parent_name: String in Config.settings.folder_tree.keys():
		var parent_path: String
		if parent_name == "root":
			parent_path = directory
		else:
			parent_path = directory.path_join(parent_name)
			
		var child_dict_array: Array = Config.settings.folder_tree.get(parent_name)
		for child_dict: Dictionary in child_dict_array:
			var child_name: String = child_dict.keys()[0]
			var child_path = parent_path.path_join(child_name)
			DirAccess.make_dir_recursive_absolute(child_path)
	
	prints("Created episode at:", directory)
	
	get_directories()

## Clear directories dictionary.
func clear_directories() -> void:
	directories.clear()

## Get all files within the directories dictionary. Directory name is key and a PackedStringArray of files is value.
func get_files() -> void:
	for dir: String in directories.keys():
		var dir_path: String = directories[dir]
		var dir_files: PackedStringArray = DirAccess.get_files_at(dir_path)
		if dir_files.size() > 0:
			files.merge({dir : dir_files})
		else:
			files.merge({dir : []})

## Clear files dictionary.
func clear_files() -> void:
	files.clear()
