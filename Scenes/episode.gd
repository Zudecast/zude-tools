class_name Episode
extends Control

#region Onready Variables

@onready var episode_button: Button = $EpisodeButton
@onready var episode_title: Label = %EpisodeTitle
@onready var episode_preview: TextureRect = %EpisodePreview

#endregion

#region Variables

## This episode's directory path.
var directory: String
## A file name.
var title: String
## An image file path.
var preview: String
## A video file path.
var video: String

## Contains a directory name as key and its path as value.
var directories: Dictionary
## Contains a directory name as key and a PackedStringArray of file paths as value.
var files: Dictionary

#endregion

#region Signals

## Emitted by focus_changed() when the focus_entered signal is also emitted.
## Updates Zude Tools tab flows with this episode's related files.
signal entered

#endregion

## Connect all signals, get directories, get files, and update title and preview.
func _ready() -> void:
	episode_button.focus_entered.connect(focus_changed)
	
	get_directories()
	get_files()
	
	set_title()
	set_preview()
	# TODO - set_video()

## Emit the entered signal when the cofus_changes signal is also emitted.
func focus_changed() -> void:
	entered.emit(self)

## Get all directories within this episode's directory. Directory name is key and its path is value.
func get_directories(path: String = directory) -> void:
	var dirs: PackedStringArray = DirAccess.get_directories_at(path)
	
	if dirs.size() > 0:
		for dir: String in dirs:
			var dir_path: String = path.path_join(dir)
			directories.merge({dir : dir_path})
			get_directories(dir_path)

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

## Set the episode_title node's text to the internal title property.
func set_title() -> void:
	episode_title.text = title

## Set the episode_preview node's image to a new image created from the file path stored in the preview property.
func set_preview() -> void:
	if files.has("main_thumb"):
		var dir_files: PackedStringArray = files["main_thumb"]
		
		if dir_files.is_empty():
			return
		
		for file_name: String in dir_files:
			if file_name.is_valid_filename() and file_name.contains(title) and file_name.ends_with(".jpg"):
				preview = directories["main_thumb"].path_join(file_name)
	
	var image = Image.new()
	image.load(preview)
	episode_preview.texture = ImageTexture.create_from_image(image)

# FIXME - ## Store the file path of the best hero video candidate in the video property.
func set_video() -> void:
	if files.has("ftg"):
		var dir_files: PackedStringArray = files["ftg"]
		
		if dir_files.is_empty():
			return
		
		for file_name: String in dir_files:
			if file_name.contains(".mp4"):
				video = directories["ftg"].path_join(file_name)

## Disconnect all signals.
func _exit_tree() -> void:
	episode_button.focus_entered.disconnect(focus_changed)
