class_name Episode
extends Control

@onready var episode_button = $EpisodeButton
@onready var episode_title: Label = %EpisodeTitle
@onready var episode_preview: TextureRect = %EpisodePreview
@onready var tab_container = %TabContainer

signal entered

#region Variables

var title: String
var preview: String
var video: String
var directory: String

var directories: Dictionary
var files: Dictionary

#endregion

func _ready() -> void:
	episode_button.focus_entered.connect(focus_changed)
	
	get_directories()
	get_files()
	set_title()
	set_preview()
	set_hero_video()

func focus_changed() -> void:
	entered.emit(self)

func get_directories(path: String = directory) -> void:
	var dirs: PackedStringArray = DirAccess.get_directories_at(path)
	
	if dirs.size() > 0:
		for dir: String in dirs:
			var dir_path: String = path.path_join(dir)
			directories.merge({dir : dir_path})
			get_directories(dir_path)

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

func set_preview() -> void:
	var dir_files: PackedStringArray = files["main_thumb"]
	
	if dir_files.is_empty() == false:
		for file: String in dir_files:
			if file.contains(title) and file.contains(".jpg"):
				preview = directory.path_join("main").path_join("main_thumb").path_join(file)
	
	var image = Image.new()
	image.load(preview)
	var texture = ImageTexture.create_from_image(image)
	episode_preview.texture = texture

func set_hero_video() -> void:
	var dir_files: PackedStringArray = files["ftg"]
	
	if dir_files.is_empty() == false:
		for file: String in dir_files:
			if file.contains(".mp4"):
				video = directory.path_join("ftg").path_join(file)

func find_videos() -> void:
	pass

func find_images() -> void:
	pass

func find_thumbs() -> void:
	pass

func _exit_tree() -> void:
	episode_button.focus_entered.disconnect(focus_changed)
