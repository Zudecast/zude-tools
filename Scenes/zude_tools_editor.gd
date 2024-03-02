class_name ZudeToolsEditor
extends Control

#region Constants

const EPISODE: PackedScene = preload("res://Scenes/zude_tools_episode.tscn")
const TAB: PackedScene = preload("res://Scenes/zude_tools_tab.tscn")
const TAB_ITEM: PackedScene = preload("res://Scenes/zude_tools_tab_item.tscn")

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
var tabs: Dictionary

#endregions

func _ready() -> void:
	new_episode_button.pressed.connect(load_episode)
	open_production_button_top.pressed.connect(file_dialog.popup_directory_dialog)
	refresh_button.pressed.connect(refresh)
	settings_button.pressed.connect(settings.popup)
	open_production_button_mid.pressed.connect(file_dialog.popup_directory_dialog)

func _exit_tree() -> void:
	new_episode_button.pressed.disconnect(load_episode)
	open_production_button_top.pressed.disconnect(file_dialog.popup_directory_dialog)
	refresh_button.pressed.disconnect(refresh)
	settings_button.pressed.disconnect(settings.popup)
	open_production_button_mid.pressed.disconnect(file_dialog.popup_directory_dialog)

#region Directory

## Clear hero, free all tabs, and update episode flow. Called when settings directory is updated.
func refresh() -> void:
	settings.refresh()
	update_buttons_visibility()
	clear_hero()
	free_all_tabs()
	update_episode_flow()

## Show buttons when they're needed, hide them when they're not.
func update_buttons_visibility() -> void:
	if settings.config.directory != null:
		open_production_button_mid.visible = false
	else:
		open_production_button_mid.visible = true

#endregion

#region Episodes

## Instantiate and configure an episode and add it to the episode flow.
func load_episode(title: String = "New Episode") -> void:
	# Instantiate the episode.
	var episode: ZudeToolsEpisode = EPISODE.instantiate()
	episode.directory = settings.directory.path_join(title)
	
	# Add episode to the episode flow.
	episode_flow.add_child(episode)
	
	# Configure the episode title and preview.
	episode.set_title(title)
	episode.set_preview(settings.config.default_preview)
	
	# Connect the episode focused signal to relevant update methods.
	episode.focused.connect(update_hero)
	episode.focused.connect(update_tab_flows)
	
	# Create a lambda function to adjust item's size when the slider value changes.
	var set_episode_size = func(new_size: int) -> void:
		episode.custom_minimum_size.x = new_size
	
	# Connect slider to lambda.
	episode_size_slider.value_changed.connect(set_episode_size)
	
	# Merge episode into the episodes dictionary.
	episodes.merge({episode.title.text : episode})

## Free and episode from the episode
func free_episode(episode: ZudeToolsEpisode) -> void:
	episode.queue_free()
	episodes.erase(episodes.get(episode))

## Free all episodes from the episode flow and the episodes dictionary.
func free_all_episodes() -> void:
	for episode: ZudeToolsEpisode in episodes.values():
		free_episode(episode)

## Frees all episodes then loads the episodes dictionary to the episode flow.
func update_episode_flow() -> void:
	free_all_episodes()
	
	if settings.directory == null:
		print("No directory selected!")
		return
	
	# Get all episodes in the production directory in reverse numerical order.
	var episode_list: PackedStringArray = DirAccess.get_directories_at(settings.directory)
	episode_list.reverse()
	
	# Load all episodes in the list.
	for title: String in episode_list:
		load_episode(title)

#endregion

#region Hero

# FIXME - ## Set the hero panel variables to the related variables from the focused episode.
func update_hero(episode: ZudeToolsEpisode) -> void:
	clear_hero()
	
	hero_title.text = episode.title.text
	hero_preview.texture = episode.preview.texture
	
	#var stream := FFmpegVideoStream.new()
	#stream.file = episode.video
	#hero_video.stream = load(episode.video)

## Clear the hero panel variables and return them to defaults.
func clear_hero() -> void:
	hero_preview.texture = null
	hero_title.text = "Select an episode..."

#endregion

#region Tabs

## Instantiate a tab with the specified name and add it to the node tree and the tabs dictionary.
func load_tab(tab_name: String) -> void:
	var tab: ZudeToolsTab = TAB.instantiate()
	tab.name = tab_name
	tabs.merge({tab.name : tab})
	tabs_container.add_child(tab)

## Free a tab with the specified name from the node tree and erase it from the tabs dictionary.
func free_tab(tab: ZudeToolsTab) -> void:
	tab.queue_free()
	tabs.erase(tabs.find_key(tab))

## Free all tabs from the tab container and the tabs dictionary.
func free_all_tabs() -> void:
	for tab in tabs.values():
		free_tab(tab)

## Create or destroy tabs for to reflect the focused episode's directories. Populate with files if created.
func update_tab_flows(episode: ZudeToolsEpisode) -> void:
	# Discard tabs with names not contained in the episode directories dictionary, else free its items.
	for tab_name: String in tabs.keys():
		if episode.directories.has(tab_name):
			free_all_items_from_tab(tabs[tab_name])
		else:
			free_tab(tabs[tab_name])
	
	# Create a tab for each episode directory name that a tab does not yet exist for.
	for dir_name: String in episode.directories.keys():
		if tabs.has(dir_name) == false:
			load_tab(dir_name)
		
		# Populate each tab's item flow with relevant images.
		for file_name: String in episode.files[dir_name]:
			var file_path: String = episode.directories[dir_name].path_join(file_name)
			load_item_into_tab(tabs[dir_name], file_name, file_path)
	
	# Check each tab's item flow for children to determine if a "nothing here" label should be shown.
	for tab: ZudeToolsTab in tabs.values():
		tab.check_for_items()

#endregion

#region Tab Items

## Add any item to the specified tab.
func load_item_into_tab(tab: ZudeToolsTab, file_name: String, file_path: String) -> void:
	# Early return if item is not a valid file.
	if file_name.is_valid_filename() == false:
		return
	
	# Handle images.
	if file_name.ends_with(".png") or file_name.ends_with(".jpg"):
		# Instantiate a new TabItem.
		var item = TAB_ITEM.instantiate()
		tab.flow.add_child(item)
		
		# Configure item.
		item.set_title(file_name)
		item.set_preview(file_path)
	
		# Create a lambda function to adjust item's size when the slider value changes.
		var set_item_size = func(new_size: int) -> void:
			item.custom_minimum_size.x = new_size
		
		# Connect slider to lambda.
		preview_size_slider.value_changed.connect(set_item_size)

## Remove any item from the specified tab at the specified index.
func free_item_from_tab(tab: ZudeToolsTab, item: Control) -> void:
	tab.flow.remove_child(item)

## Remove all items from the specified tab.
func free_all_items_from_tab(tab: ZudeToolsTab) -> void:
	for child in tab.flow.get_children():
		free_item_from_tab(tab, child)
	
	tab.check_for_items()

#endregion
