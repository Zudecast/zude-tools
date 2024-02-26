class_name Episode
extends Control

@onready var episode_button = $EpisodeButton
@onready var episode_preview: TextureRect = %EpisodePreview
@onready var episode_title: Label = %EpisodeTitle
@onready var tab_container = %TabContainer

signal entered

#region Variables

var title: String
var preview: Texture2D
var directory: String

var directories: Dictionary

#endregion

func _ready() -> void:
	print_rich("[color=green]Added episode: ", title, " at ", directory, "[/color]")
	
	episode_button.focus_entered.connect(focus_changed)
	
	get_directories_at(directory)
	
	#find_videos()
	#find_images()
	#find_thumbs()
	
	set_title()
	set_preview()

func focus_changed() -> void:
	entered.emit(self)

func set_title() -> void:
	episode_title.text = title

func set_preview() -> void:
	if directories["main_thumb"].is_empty() == false:
		for file: String in directories["main_thumb"]:
			if file.contains(title) and file.contains("png") or file.contains("jpg"):
				var image = Image.new()
				var image_path = directory.path_join("main/main_thumb").path_join(file)
				image.load(image_path)
				var texture = ImageTexture.create_from_image(image)
				preview = texture
	
	episode_preview.texture = preview

func get_directories_at(path: String) -> void:
	var dirs: PackedStringArray = DirAccess.get_directories_at(path)
	
	if dirs.size() > 0:
		for dir in dirs:
			var dir_path: String = path.path_join(dir)
			directories.merge({dir : get_files_at(dir_path)})
			get_directories_at(dir_path)

func get_files_at(path: String) -> PackedStringArray:
	var files = DirAccess.get_files_at(path)
	
	if files.size() > 0:
		return files
	
	return []

func find_videos() -> void:
	pass

func find_images() -> void:
	for image in directories["thumb"]:
		pass

func find_thumbs() -> void:
	pass

func _exit_tree() -> void:
	episode_button.focus_entered.disconnect(focus_changed)
