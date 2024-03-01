class_name ZudeToolsEditor
extends Control

#region Constants

const CONFIG = "res://config.json"
const EPISODE: PackedScene = preload("res://Scenes/episode.tscn")
const TAB_FLOW: PackedScene = preload("res://Scenes/tab_flow.tscn")
const THUMBNAIL: PackedScene = preload("res://Scenes/thumbnail.tscn")
const DEFAULT_THUMBNAIL: String = "res://zudecast.png"

#endregion

#region Onready Variables

@onready var settings: ZudeToolsSettings = $"../ZudeToolsSettings"
@onready var file_dialog: ZudeToolsFileDialog = $"../ZudeToolsFileDialog"

@onready var episode_flow: HFlowContainer = %EpisodesHFlowContainer
@onready var tabs_container: TabContainer = %TabsContainer

@onready var hero_title: Label = %HeroTitle
@onready var hero_preview: TextureRect = %HeroPreview
@onready var hero_video: VideoStreamPlayer = %HeroVideo

@onready var buttons_panel_h_box_left: HBoxContainer = %ButtonsPanelHBoxLeft
@onready var new_episode_button: Button = %NewEpisodeButton
@onready var open_production_button_top: Button = %OpenProductionButtonTop
@onready var buttons_panel_h_box_right: HBoxContainer = %ButtonsPanelHBoxRight
@onready var open_settings_button: Button = %OpenSettingsButton
@onready var open_production_button_mid: Button = %OpenProductionButtonMid

@onready var preview_size_slider: HSlider = %PreviewSizeSlider

#endregion

#region Variables

var episodes: Dictionary
var tab_flows: Dictionary

#endregions

func _ready() -> void:
	open_settings_button.pressed.connect(settings.popup)
	
	new_episode_button.pressed.connect(add_episode)
	open_production_button_mid.pressed.connect(file_dialog.popup_directory_dialog)
	open_production_button_top.pressed.connect(file_dialog.popup_directory_dialog)
	preview_size_slider.value_changed.connect(resize_tab_flow_previews)

func _exit_tree() -> void:
	open_settings_button.pressed.disconnect(settings.popup)
	
	new_episode_button.pressed.disconnect(add_episode)
	open_production_button_mid.pressed.disconnect(file_dialog.popup_directory_dialog)
	open_production_button_top.pressed.disconnect(file_dialog.popup_directory_dialog)
	preview_size_slider.value_changed.disconnect(resize_tab_flow_previews)

## Clear hero, clear tabs, and update episodes. Called when settings directory is updated.
func refresh() -> void:
	update_buttons_visibility()
	clear_hero()
	clear_tab_container()
	update_episodes()

## Show buttons when they're needed, hide them when they're not.
func update_buttons_visibility() -> void:
	if settings.config.directory != null:
		open_production_button_mid.visible = false
	else:
		open_production_button_mid.visible = true

## Instantiate and configure an episode.
func add_episode(title: String = "New Episode") -> void:
	var episode: Episode = EPISODE.instantiate()
	
	episode.title = title
	episode.preview = settings.config.default_preview
	episode.directory = settings.directory.path_join(title)
	
	episode.entered.connect(update_hero)
	episode.entered.connect(update_tabs)
	
	episodes.merge({episode.title : episode})
	episode_flow.add_child(episode)

## Add all episodes in the episodes dictionary to the episode flow.
func update_episodes() -> void:
	clear_episodes()
	
	if settings.directory == null:
		print("No directory selected!")
		return
	
	var list: PackedStringArray = DirAccess.get_directories_at(settings.directory)
	
	list.reverse()
	
	for title in list:
		add_episode(title)

## Free all episodes in the episodes dictionary and clear it.
func clear_episodes() -> void:
	for episode in episode_flow.get_children():
		episode.queue_free()
	
	episodes.clear()

# FIXME - ## Set the hero panel variables to the related variables from the focused episode.
func update_hero(episode: Episode) -> void:
	clear_hero()
	
	hero_title.text = episode.title
	hero_preview.texture = episode.episode_preview.texture
	
	#var stream := FFmpegVideoStream.new()
	#stream.file = episode.video
	#hero_video.stream = load(episode.video)

## Clear the hero panel variables and return them to defaults.
func clear_hero() -> void:
	hero_preview.texture = null
	hero_title.text = "Select an episode..."

## Create and populate tab flows with files for the focused episode. Reuses tab flow instances of the same name.
func update_tabs(episode: Episode) -> void:
	if episode.files.is_empty():
		return
	
	for tab_name: String in tab_flows.keys():
		if episode.directories.has(tab_name):
			clear_tab_flow_items(tab_name)
		else:
			tab_flows[tab_name].queue_free()
			tab_flows.erase(tab_name)
	
	for dir_name: String in episode.directories.keys():
		if tab_flows.has(dir_name) == false:
			var tab_flow: TabFlow = TAB_FLOW.instantiate()
			tab_flow.name = dir_name
			tab_flows.merge({tab_flow.name : tab_flow})
			tabs_container.add_child(tab_flow)
		
		for file_name: String in episode.files[dir_name]:
			if file_name.is_valid_filename() and file_name.ends_with(".png") or file_name.ends_with(".jpg"):
				var image = THUMBNAIL.instantiate()
				image.title = file_name
				image.preview = episode.directories[dir_name].path_join(file_name)
				load_item_into_tab_flow(dir_name, image)
		
		tab_flows[dir_name].check_for_children()

## Add any item to the specified tab flow.
func load_item_into_tab_flow(tab_name: String, node: Node) -> void:
	tab_flows[tab_name].flow.add_child(node)

## Remove any item from the specified tab flow.
func free_item_from_tab_flow(tab_name: String, node: Node) -> void:
	tab_flows[tab_name].flow.get_child(node.name).queue_free()

## Remove all items from the specified tab flow.
func clear_tab_flow_items(tab_name: String) -> void:
	for item in tab_flows[tab_name].flow.get_children():
		item.queue_free()

## Remove all tab flows from the tab container and clear the tab_flows dictionary.
func clear_tab_container() -> void:
	for tab_flow in tabs_container.get_children():
		tab_flow.queue_free()
	
	tab_flows.clear()

# TODO - ## Resize item preview sizes for tab flows.
func resize_tab_flow_previews() -> void:
	pass

