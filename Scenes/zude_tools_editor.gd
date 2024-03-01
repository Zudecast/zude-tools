class_name ZudeToolsEditor
extends Control

#region Constants

const EPISODE: PackedScene = preload("res://Scenes/episode.tscn")
const TAB_FLOW: PackedScene = preload("res://Scenes/tab_flow.tscn")
const THUMBNAIL: PackedScene = preload("res://Scenes/thumbnail.tscn")

#endregion

#region Onready Variables

@onready var settings: ZudeToolsSettings = $"../ZudeToolsSettings"
@onready var file_dialog: ZudeToolsFileDialog = $"../ZudeToolsFileDialog"

@onready var episode_size_slider = %EpisodeSizeSlider
@onready var episode_flow: HFlowContainer = %EpisodesHFlowContainer
@onready var tabs_container: TabContainer = %TabsContainer

@onready var hero_title: Label = %HeroTitle
@onready var hero_preview: TextureRect = %HeroPreview
@onready var hero_video: VideoStreamPlayer = %HeroVideo

@onready var buttons_panel_h_box_left: HBoxContainer = %ButtonsPanelHBoxLeft
@onready var new_episode_button: Button = %NewEpisodeButton
@onready var open_production_button_top: Button = %OpenProductionButtonTop
@onready var buttons_panel_h_box_right: HBoxContainer = %ButtonsPanelHBoxRight
@onready var refresh_button: Button = %RefreshButton
@onready var settings_button: Button = %SettingsButton
@onready var open_production_button_mid: Button = %OpenProductionButtonMid

@onready var preview_size_slider: HSlider = %PreviewSizeSlider
# TODO - item count for tabs
@onready var item_count_label = %ItemCountLabel

#endregion

#region Variables

var episodes: Dictionary
var tab_flows: Dictionary

#endregions

func _ready() -> void:
	new_episode_button.pressed.connect(add_episode)
	open_production_button_top.pressed.connect(file_dialog.popup_directory_dialog)
	refresh_button.pressed.connect(refresh)
	settings_button.pressed.connect(settings.popup)
	open_production_button_mid.pressed.connect(file_dialog.popup_directory_dialog)

func _exit_tree() -> void:
	new_episode_button.pressed.disconnect(add_episode)
	open_production_button_top.pressed.disconnect(file_dialog.popup_directory_dialog)
	refresh_button.pressed.disconnect(refresh)
	settings_button.pressed.disconnect(settings.popup)
	open_production_button_mid.pressed.disconnect(file_dialog.popup_directory_dialog)

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

## Configure and instantiate an episode.
func add_episode(title: String = "New Episode") -> void:
	var episode: Episode = EPISODE.instantiate()
	
	episode.title = title
	episode.preview = settings.config.default_preview
	episode.directory = settings.directory.path_join(title)
	
	episode.entered.connect(update_hero)
	episode.entered.connect(update_tabs)
	
	var set_episode_size = func(size: int) -> void:
		episode.custom_minimum_size.x = size
	
	episode_size_slider.value_changed.connect(set_episode_size)
	
	episodes.merge({episode.title : episode})
	episode_flow.add_child(episode)

## Add all episodes in the episodes dictionary to the episode flow.
func update_episodes() -> void:
	clear_episodes()
	
	if settings.directory == null:
		print("No directory selected!")
		return
	
	var episode_list: PackedStringArray = DirAccess.get_directories_at(settings.directory)
	
	episode_list.reverse()
	
	for title in episode_list:
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
	
	# Reuse tab flows instances with the same name as ones to be created, discard unneeded ones.
	for tab_name: String in tab_flows.keys():
		if episode.directories.has(tab_name):
			clear_tab_flow_items(tab_name)
		else:
			tab_flows[tab_name].queue_free()
			tab_flows.erase(tab_name)
	
	# Loop through all of the directory names in the focused episode.
	for dir_name: String in episode.directories.keys():
		# Create a tab flow for each directory name that a tab flow does not already exist for.
		if tab_flows.has(dir_name) == false:
			var tab_flow: TabFlow = TAB_FLOW.instantiate()
			tab_flow.name = dir_name
			tab_flows.merge({tab_flow.name : tab_flow})
			tabs_container.add_child(tab_flow)
		
		# Populate each tab flow with relevant images.
		for file_name: String in episode.files[dir_name]:
			if file_name.is_valid_filename() and file_name.ends_with(".png") or file_name.ends_with(".jpg"):
				var image = THUMBNAIL.instantiate()
				image.title = file_name
				image.preview = episode.directories[dir_name].path_join(file_name)
				load_item_into_tab_flow(dir_name, image)
	
	# Check each tab flow for children to determine if a "nothing here" label should be shown.
	for tab_flow in tab_flows.values():
		tab_flow.check_for_children()

## Add any item to the specified tab flow.
func load_item_into_tab_flow(tab_name: String, item: Control) -> void:
	var set_item_size = func(size: float) -> void:
		item.custom_minimum_size.x = size
	
	preview_size_slider.value_changed.connect(set_item_size)
	
	tab_flows[tab_name].flow.add_child(item)

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


