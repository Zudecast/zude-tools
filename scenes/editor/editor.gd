@tool
class_name ZudeToolsEditor
extends ZudeTools

#region Constants

const EPISODE: PackedScene = preload("res://scenes/cards/card_episode.tscn")
const IMAGE: PackedScene = preload("res://scenes/cards/card_image.tscn")
const VIDEO: PackedScene = preload("res://scenes/cards/card_video.tscn")
const DEFAULT_PREVIEW: NoiseTexture2D = preload("res://resources/theme/default_preview.tres")
const TAB: PackedScene = preload("res://scenes/tabs/tab.tscn")

#endregion

#region Onready Variables

@onready var editor_bar_top = $"../EditorBarTop"
@onready var episode_flow: HFlowContainer = %EpisodeFlow
@onready var tabs_container: TabContainer = %TabsContainer

@onready var hero_panel: PanelContainer = %HeroPanel
@onready var hero_title: LineEdit = %HeroTitle
@onready var hero_preview: TextureRect = %HeroPreview
@onready var hero_video: VideoStreamPlayer = %HeroVideo

@onready var toggle_hero_button: Button = %ToggleHeroButton
@onready var preview_size_slider: HSlider = %PreviewSizeSlider
@onready var item_count_label: LineEdit = %ItemCountLineEdit

#endregion

#region Variables

var episodes: Dictionary
var tabs: Dictionary

#endregions

func _ready() -> void:
	Config.editor_refresh_requested.connect(refresh_interface)
	
	toggle_hero_button.pressed.connect(toggle_hero)

func _exit_tree() -> void:
	Config.editor_refresh_requested.disconnect(refresh_interface)
	
	toggle_hero_button.pressed.disconnect(toggle_hero)

#region Interface

## Clear hero, free all tabs, and update episode flow.
func refresh_interface() -> void:
	clear_hero()
	clear_tabs()
	clear_episodes()
	refresh_episode_flow()
	print("Editor interface refreshed.")

## Open the settings menu.
func toggle_interface() -> void:
	visible = !visible

#endregion

#region Episodes

## Frees all episodes then loads the episodes dictionary to the episode flow.
func refresh_episode_flow() -> void:
	# Early return if no directory is set in config.
	if Config.settings.directory == null:
		print("No directory selected!")
		return
	
	# Get all episodes in the production directory in reverse alphabetical order.
	var episode_list: PackedStringArray = DirAccess.get_directories_at(Config.settings.directory)
	episode_list.reverse()
	
	# Load all episodes in the list.
	for title: String in episode_list:
		if episodes.has(title) == false:
			load_episode(title)

## Instantiate and configure an episode and add it to the episode flow.
func load_episode(title: String = "New Episode") -> void:
	# Instantiate the episode.
	var episode: ZudeToolsCardEpisode = EPISODE.instantiate()
	episode.directory = Config.settings.directory.path_join(title)
	
	# Merge episode into the episodes dictionary and add it to the episode flow.
	episodes.merge({title : episode})
	episode_flow.add_child(episode)
	
	# Configure the episode title and preview.
	episode.set_title(title)
	if Config.settings.preview != null:
		var image = Image.new()
		image.load(Config.settings.preview)
		var texture = ImageTexture.create_from_image(image)
		episode.set_preview(texture)
	else:
		episode.set_preview(DEFAULT_PREVIEW)
	
	# Connect the episode focused signal to the relevant update methods.
	episode.focused.connect(refresh_hero)
	episode.focused.connect(refresh_tab_flows)
	
	# Create a lambda function to adjust item's size when the slider value changes.
	var set_episode_size = func(new_size: int) -> void:
		episode.custom_minimum_size.x = new_size
	
	# Connect slider to lambda.
	editor_bar_top.episode_size_slider.value_changed.connect(set_episode_size)

## Free and episode from the episode
func free_episode(episode: ZudeToolsCardEpisode) -> void:
	# Disconnect the episode focused signal from the relevant update methods.
	episode.focused.disconnect(refresh_hero)
	episode.focused.disconnect(refresh_tab_flows)
	
	episodes.erase(episodes.find_key(episode))
	episode_flow.remove_child(episode)
	episode.queue_free()

## Free all episodes from the episode flow and the episodes dictionary.
func clear_episodes() -> void:
	if episodes.is_empty() == false:
		for episode: ZudeToolsCardEpisode in episodes.values():
			free_episode(episode)

#endregion

#region Hero

# FIXME - ## Set the hero panel variables to the related variables from the focused episode.
func refresh_hero(episode: ZudeToolsCardEpisode) -> void:
	clear_hero()
	
	hero_title.text = episode.title.text
	hero_preview.texture = episode.preview.texture
	
	#var stream := FFmpegVideoStream.new()
	#stream.file = episode.video
	#hero_video.stream = load(episode.video)

## Clear the hero panel variables and return them to defaults.
func clear_hero() -> void:
	hero_title.text = "Select an episode..."
	hero_preview.texture = null

## Toggle Hero visibilie=ty
func toggle_hero() -> void:
	hero_panel.visible = !hero_panel.visible

#endregion

#region Tabs

## Load or free tabs for to reflect the focused episode's directories. Populate with files if created.
func refresh_tab_flows(episode: ZudeToolsCardEpisode) -> void:
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

## Instantiate a tab with the specified name and add it to the node tree and the tabs dictionary.
func load_tab(tab_name: String) -> void:
	# Instantiate a new tab and add it to the node tree.
	var tab: ZudeToolsTab = TAB.instantiate()
	tabs_container.add_child(tab)
	
	# Connect tab to update_item_count.
	tab.flow_count.connect(update_item_count)
	
	# Configure tab.
	tab.name = tab_name
	
	# Add tab to the tabs dictionary.
	tabs.merge({tab.name : tab})

## Free a tab with the specified name from the node tree and erase it from the tabs dictionary.
func free_tab(tab: ZudeToolsTab) -> void:
	# Disconnect tab from update_item_count.
	tab.flow_count.disconnect(update_item_count)
	
	tabs.erase(tabs.find_key(tab))
	tabs_container.remove_child(tab)
	tab.queue_free()

## Free all tabs from the tab container and the tabs dictionary.
func clear_tabs() -> void:
	if tabs.is_empty() == false:
		for tab in tabs.values():
			free_tab(tab)

#endregion

#region Tab Items

## Add any item to the specified tab.
func load_item_into_tab(tab: ZudeToolsTab, file_name: String, file_path: String) -> void:
	# Early return if item is not a valid file.
	if file_name.is_valid_filename() == false:
		return
	
	# Create a placeholder tab item so we can chose how to handle it.
	var item: ZudeToolsCard
	
	# Handle image files.
	if file_name.get_extension() in ["png", "jpg"]:
		# Instantiate a new CardImage
		item = IMAGE.instantiate()
		tab.flow.add_child(item)
		
		# Configure item.
		item.set_title(file_name)
		var image = Image.new()
		image.load(file_path)
		var texture = ImageTexture.create_from_image(image)
		item.set_preview(texture)
	
	# Handle template files.
	elif file_name.get_extension() in ["psd", "krz", "kra"]:
		# Instantiate a new CardVideo
		item = IMAGE.instantiate()
		tab.flow.add_child(item)
		
		# Configure item.
		item.set_title(file_name)
		var image = Image.new()
		image.load(file_path)
		var texture = ImageTexture.create_from_image(image)
		item.set_preview(texture)
	
	# Handle video files.
	elif file_name.get_extension() in ["mp4", "mkv"]:
		# Instantiate a new CardVideo
		item = VIDEO.instantiate()
		tab.flow.add_child(item)
		
		# Configure item.
		item.set_title(file_name)
		item.set_video(file_path)
	
	if item != null:
		# Create a lambda function to adjust item's size when the slider value changes.
		var set_item_size = func(new_size: int) -> void:
			item.custom_minimum_size.x = new_size
		
		# Connect slider to lambda.
		preview_size_slider.value_changed.connect(set_item_size)

## Remove any item from the specified tab at the specified index.
func free_item_from_tab(tab: ZudeToolsTab, item: Control) -> void:
	tab.flow.remove_child(item)
	item.queue_free()

## Remove all items from the specified tab.
func free_all_items_from_tab(tab: ZudeToolsTab) -> void:
	for child in tab.flow.get_children():
		free_item_from_tab(tab, child)
	
	tab.check_for_items()

#endregion

#region Bottom Bar

func update_item_count(num: int) -> void:
	item_count_label.text = str(num)

#endregion
