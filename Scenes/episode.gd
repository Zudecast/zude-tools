class_name Episode
extends Control

#region Onready Variables

@onready var episode_button = $EpisodeButton
@onready var episode_title: Label = %EpisodeTitle
@onready var episode_preview: TextureRect = %EpisodePreview

#endregion

#region Constants

const DEFAULT_THUMBNAIL: String = "res://zudecast.png"

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
## Updates Zude Tools details tabs with this episode's related files.
signal entered

#endregion

func _ready() -> void:
	episode_button.focus_entered.connect(focus_changed)
	
	get_directories()
	get_files()
	
	set_title()
	set_preview()
	# TODO - set_video()

func focus_changed() -> void:
	entered.emit(self)

func get_directories(path: String = directory) -> void:
	var dirs: PackedStringArray = DirAccess.get_directories_at(path)
	
	if dirs.size() > 0:
		for dir: String in dirs:
			var dir_path: String = path.path_join(dir)
			directories.merge({dir : dir_path})
			get_directories(dir_path)

func clear_directories() -> void:
	directories.clear()

func get_files() -> void:
	for dir: String in directories.keys():
		var dir_path: String = directories[dir]
		var dir_files: PackedStringArray = DirAccess.get_files_at(dir_path)
		if dir_files.size() > 0:
			files.merge({dir : dir_files})
		else:
			files.merge({dir : []})

func clear_files() -> void:
	files.clear()

func set_title() -> void:
	episode_title.text = title

# FIXME
func set_preview() -> void:
	if files.has("main_thumb"):
		var dir_files: PackedStringArray = files["main_thumb"]
	
		if dir_files.is_empty() == false:
			for file: String in dir_files:
				if file.contains(title) and file.contains(".jpg"):
					preview = directory.path_join("main").path_join("main_thumb").path_join(file)
		
			var image = Image.new()
			image.load(preview)
			episode_preview.texture = ImageTexture.create_from_image(image)
		else:
			var image = Image.new()
			image.load(DEFAULT_THUMBNAIL)
			episode_preview.texture = ImageTexture.create_from_image(image)

# FIXME
func set_video() -> void:
	var dir_files: PackedStringArray = files["ftg"]
	
	if dir_files.is_empty() == false:
		for file: String in dir_files:
			if file.contains(".mp4"):
				video = directory.path_join("ftg").path_join(file)

# TODO
func find_videos() -> void:
	pass

# TODO
func find_images() -> void:
	pass

# TODO
func find_thumbs() -> void:
	pass

func _exit_tree() -> void:
	episode_button.focus_entered.disconnect(focus_changed)
