@tool
class_name ZudeToolsCardEpisode
extends ZudeToolsCard

#region Onready Variables

@onready var title: LineEdit = %EpisodeTitle
@onready var preview: TextureRect = %EpisodePreview
@onready var button: Button = $EpisodeButton

#endregion

#region Variables

## This episode's directory path.
var directory: String

## Contains a directory name as key and its path as value.
var directories: Dictionary
## Contains a directory name as key and a PackedStringArray of file paths as value.
var files: Dictionary

#endregion

#region Signals

## Emitted by focus_changed() when the focus_entered signal is also emitted.
signal focused(ZudeToolsCardEpisode)

#endregion

func _ready() -> void:
	get_directories()
	get_files()
	
	button.focus_entered.connect(focus_changed)

func _exit_tree() -> void:
	button.focus_entered.disconnect(focus_changed)

## Set the title node's text to the specified text.
func set_title(text: String) -> void:
	title.text = text

## Set the preview node's image to the specified path.
func set_preview(texture: Texture2D) -> void:
	preview.texture = texture
	# Check episode directory for a main thumb, use
	if files.has("main_thumb"):
		var dir_files: PackedStringArray = files["main_thumb"]
		
		if dir_files.is_empty():
			return
		
		for file_name: String in dir_files:
			if file_name.is_valid_filename() and file_name.ends_with(".jpg"):
				var path = directories["main_thumb"].path_join(file_name)
				var image = Image.new()
				
				image.load(path)
				preview.texture = ImageTexture.create_from_image(image)

# FIXME - ## Store the file path of the best hero video candidate in the video property.
func set_video(path: String) -> void:
	if files.has("ftg"):
		var dir_files: PackedStringArray = files["ftg"]
		
		if dir_files.is_empty():
			return
		
		for file_name: String in dir_files:
			if file_name.contains(".mp4"):
				path = directories["ftg"].path_join(file_name)
		
		var stream = FFmpegVideoStream.new()
		stream.load(path)

## Emit the focused signal (returning self) when the focus_entered signal is also emitted.
func focus_changed() -> void:
	focused.emit(self)

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
