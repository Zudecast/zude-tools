class_name ZudeTools
extends Control

#region Onready Variables

@onready var hero_preview = %HeroPreview
@onready var hero_title = %HeroTitle
@onready var open_production_button_top: Button = %OpenProductionButtonTop
@onready var open_production_button_mid: Button = %OpenProductionButtonMid
@onready var new_episode_button: Button = %NewEpisodeButton
@onready var episode_flow: HFlowContainer = %EpisodesHFlowContainer
@onready var tab_container = %TabContainer

#endregion

#region Constants

const CONFIG = "res://config.json"
const EPISODE: PackedScene = preload("res://Scenes/episode.tscn")
const DETAILS_PANEL: PackedScene = preload("res://Scenes/details_panel.tscn")
const DEFAULT_THUMB: Texture2D = preload("res://zudecast.png")

#endregion

#region Variables

var tabs: Dictionary
var episode_dictionary: Dictionary
var directory: String:
	set(string):
		directory = string
		show_hide_open_production_button()
		clear_zude_tool()
		find_episodes()
var file_dialog: FileDialog = preload("res://Scenes/file_dialog.tscn").instantiate()

#endregion

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

func find_episodes() -> void:
	var list: PackedStringArray = DirAccess.get_directories_at(directory)
	
	for title in list:
		add_episode(title)
	
	update_episode_flow()

func add_episode(title: String = "New Episode") -> void:
	if directory == null:
		print("No directory selected!")
		return
	
	var episode: Episode = EPISODE.instantiate()
	
	episode.title = title
	episode.preview = DEFAULT_THUMB
	episode.directory = directory.path_join(title)
	
	episode.entered.connect(create_tabs)
	episode.entered.connect(set_hero)
	
	episode_dictionary.merge({episode : episode.title})

func update_episode_flow() -> void:
	for episode in episode_dictionary.keys():
		episode_flow.add_child(episode)

func set_hero(episode: Episode) -> void:
	clear_hero()
	
	hero_preview.texture = episode.preview
	hero_title.text = episode.title

func clear_hero() -> void:
	hero_preview.texture = null
	hero_title.text = "Select an episode..."

func create_tabs(episode: Episode) -> void:
	clear_tabs(episode)
	
	for dir: String in episode.directories:
		var tab: PanelContainer = DETAILS_PANEL.instantiate()
		
		tabs.merge({dir : tab})
		tab_container.add_child(tabs[dir])
		tab.name = dir.to_pascal_case()
	
	#for dir: String in episode.directories:
		#for file_array: PackedStringArray in episode.directories[dir]:
			#for file in file_array:
				#tabs[dir].add_child(file)

func clear_tabs(episode: Episode) -> void:
	for tab in tabs.values():
		tab.queue_free()
	
	tabs.clear()

func clear_zude_tool() -> void:
	episode_dictionary.clear()
	
	for child in episode_flow.get_children():
		child.queue_free()
	
	for child in tab_container.get_children():
		child.queue_free()

func _exit_tree():
	new_episode_button.pressed.disconnect(add_episode)
	open_production_button_mid.pressed.disconnect(open_production_dialog)
	open_production_button_top.pressed.disconnect(open_production_dialog)
