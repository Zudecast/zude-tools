class_name ZudeTools
extends Control

#region Onready Variables

@onready var hero_video: VideoStreamPlayer = %HeroVideo
@onready var hero_preview: TextureRect = %HeroPreview
@onready var hero_title: Label = %HeroTitle
@onready var open_production_button_top: Button = %OpenProductionButtonTop
@onready var open_production_button_mid: Button = %OpenProductionButtonMid
@onready var new_episode_button: Button = %NewEpisodeButton
@onready var episode_flow: HFlowContainer = %EpisodesHFlowContainer
@onready var footage_flow: HFlowContainer = %FootageHFlowContainer
@onready var thumbnails_flow: HFlowContainer = %ThumbnailsHFlowContainer
@onready var clips_flow: HFlowContainer = %ClipsHFlowContainer
@onready var reels_flow: HFlowContainer = %ReelsHFlowContainer

#endregion

#region Constants

const CONFIG = "res://config.json"
const EPISODE: PackedScene = preload("res://Scenes/episode.tscn")
const THUMBNAIL: PackedScene = preload("res://Scenes/thumbnail.tscn")

#endregion

#region Variables

var file_dialog: FileDialog = preload("res://Scenes/file_dialog.tscn").instantiate()
var episodes: Dictionary
var directory: String:
	set(string):
		directory = string
		show_hide_open_production_button()
		clear_zude_tools()
		update_zude_tools()

#endregions

func _ready() -> void:
	read_directory()
	
	new_episode_button.pressed.connect(add_episode)
	open_production_button_mid.pressed.connect(open_production_dialog)
	open_production_button_top.pressed.connect(open_production_dialog)

func popup_dialog(title: String = "Open...", file_mode: FileDialog.FileMode = FileDialog.FILE_MODE_OPEN_ANY) -> void:
	file_dialog.title = title
	file_dialog.file_mode = file_mode
	file_dialog.use_native_dialog = true
	file_dialog.visible = true

func show_hide_open_production_button() -> void:
	if directory:
		open_production_button_mid.visible = false
	else:
		open_production_button_mid.visible = true

func open_production_dialog() -> void:
	file_dialog.dir_selected.connect(write_directory, CONNECT_ONE_SHOT)
	popup_dialog("Open a Production Directory...", FileDialog.FILE_MODE_OPEN_DIR)

func read_directory() -> void:
	var config = FileAccess.open(CONFIG, FileAccess.READ)
	var dir = JSON.parse_string(config.get_line())
	if dir != null:
		directory = dir
	
	config.close()
	
	prints("Read directory from config:", directory)

func write_directory(dir: String) -> void:
	directory = dir
	var config = FileAccess.open(CONFIG, FileAccess.WRITE_READ)
	config.store_string(JSON.stringify(directory))
	config.close()
	
	prints("Wrote directory to config:", directory)

func update_zude_tools() -> void:
	add_episodes()
	update_episode_flow()

func clear_zude_tools() -> void:
	episodes.clear()
	clear_episode_flow()
	clear_detail_flows()
	clear_hero()

func add_episodes() -> void:
	var list: PackedStringArray = DirAccess.get_directories_at(directory)
	
	list.reverse()
	
	for title in list:
		add_episode(title)

func add_episode(title: String = "New Episode") -> void:
	if directory == null:
		print("No directory selected!")
		return
	
	var episode: Episode = EPISODE.instantiate()
	
	episode.title = title
	episode.directory = directory.path_join(title)
	
	episode.entered.connect(update_hero)
	episode.entered.connect(update_detail_flows)
	
	episodes.merge({episode.title : episode})

func update_episode_flow() -> void:
	for episode in episodes:
		episode_flow.add_child(episodes.get(episode))

func clear_episode_flow() -> void:
	for child in episode_flow.get_children():
		child.queue_free()

# FIXME
func update_hero(episode: Episode) -> void:
	clear_hero()
	
	hero_title.text = episode.title
	hero_preview.texture = episode.episode_preview.texture
	
	var stream := FFmpegVideoStream.new()
	stream.set_file(episode.video)
	hero_video.stream = stream

func clear_hero() -> void:
	hero_preview.texture = null
	hero_title.text = "Select an episode..."

func update_detail_flows(episode: Episode) -> void:
	update_thumbnail_flow(episode)
	update_footage_flow(episode)
	update_clips_flow(episode)
	update_reels_flow(episode)

func clear_detail_flows() -> void:
	clear_thumbnail_flow()
	clear_footage_flow()
	clear_clips_flow()
	clear_reels_flow()

func update_thumbnail_flow(episode: Episode) -> void:
	clear_thumbnail_flow()
	
	for file_name: String in episode.files["clips_thumb"]:
		if file_name.contains(".jpg"):
			var image_path = episode.directory.path_join("clips").path_join("clips_thumb").path_join(file_name)
			
			var thumb: Thumbnail = THUMBNAIL.instantiate()
			thumb.title = file_name
			thumb.preview = image_path
			
			thumbnails_flow.add_child(thumb)

func clear_thumbnail_flow() -> void:
	for child in thumbnails_flow.get_children():
		child.queue_free()

# TODO
func update_footage_flow(_episode: Episode) -> void:
	clear_footage_flow()

func clear_footage_flow() -> void:
	for child in footage_flow.get_children():
		child.queue_free()

# TODO
func update_clips_flow(_episode: Episode) -> void:
	clear_clips_flow()

func clear_clips_flow() -> void:
	for child in clips_flow.get_children():
		child.queue_free()

# TODO
func update_reels_flow(_episode: Episode) -> void:
	clear_reels_flow()

func clear_reels_flow() -> void:
	for child in reels_flow.get_children():
		child.queue_free()

func _exit_tree():
	new_episode_button.pressed.disconnect(add_episode)
	open_production_button_mid.pressed.disconnect(open_production_dialog)
	open_production_button_top.pressed.disconnect(open_production_dialog)
