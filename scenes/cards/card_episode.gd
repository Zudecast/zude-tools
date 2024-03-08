@tool
class_name ZudeToolsCardEpisode
extends ZudeToolsCard

#region Onready Variables

@onready var label: LineEdit = %Label
@onready var preview: TextureRect = %Preview
@onready var button: Button = %Button

#endregion

#region Variables

## This episode's title.
var title: String
## This episode's path.
var path: String

## Contains a directory name as key and its path as value.
var directories: Dictionary
## Contains a directory name as key and a PackedStringArray of file paths as value.
var files: Dictionary

#endregion

func _ready() -> void:
	get_directories()
	get_files()
	
	update_label()
	update_preview()
	
	button.focus_entered.connect(focus_changed)

func _exit_tree() -> void:
	button.focus_entered.disconnect(focus_changed)
	
	files.clear()
	directories.clear()

## Set the label node's text to the specified text.
func update_label() -> void:
	name = title
	label.text = title
	tooltip_text = title

## Set the preview node's image to the specified path.
func update_preview(texture: Texture2D = Config.DEFAULT_PREVIEW) -> void:
	var image = Image.new()
	
	# Check for a preview image candidate.
	if files.has("main_thumb"):
		var dir_files: PackedStringArray = files["main_thumb"]
		
		if dir_files.is_empty(): return
		
		for file_name: String in dir_files:
			if file_name.is_valid_filename() and file_name.get_extension() in ["jpg"]:
				var path = directories["main_thumb"].path_join(file_name)
				image.load(path)
				if image.is_empty() == false:
					texture = ImageTexture.create_from_image(image)
	
	## Use the config default preview if one exists and a candidate was not found above.
	elif Config.settings.preview != null:
		image.load(Config.settings.preview)
		if image.is_empty() == false:
			texture = ImageTexture.create_from_image(image)
	
	## Set the final texture.
	preview.texture = texture

## Get all directories within this episode's directory. Directory name is key and its path is value.
func get_directories(at_path: String = path) -> void:
	var dirs: PackedStringArray = DirAccess.get_directories_at(at_path)
	
	for dir: String in dirs:
		var dir_path: String = at_path.path_join(dir)
		directories.merge({dir : dir_path})
		get_directories(dir_path)
	
	if directories.size() == 0:
		build_directories()

## Build directories based on the folders settings menu for new episodes.
func build_directories() -> void:
	for parent_name: String in Config.settings.folder_tree.keys():
		var parent_path: String
		if parent_name == "root":
			parent_path = path
		else:
			parent_path = path.path_join(parent_name)
			
		var child_dict_array: Array = Config.settings.folder_tree.get(parent_name)
		for child_dict: Dictionary in child_dict_array:
			var child_name: String = child_dict.keys()[0]
			var child_path = parent_path.path_join(child_name)
			DirAccess.make_dir_recursive_absolute(child_path)
	
	prints("Created episode at:", path)
	
	get_directories()

## Get all files within the directories dictionary. Directory name is key and a PackedStringArray of files is value.
func get_files() -> void:
	for dir: String in directories.keys():
		var dir_path: String = directories[dir]
		var dir_files: PackedStringArray = DirAccess.get_files_at(dir_path)
		if dir_files.size() > 0:
			files.merge({dir : dir_files})
		else:
			files.merge({dir : []})
