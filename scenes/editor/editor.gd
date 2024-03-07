@tool
class_name ZudeToolsEditor
extends ZudeTools

#region Constants

const EPISODE: PackedScene = preload("res://scenes/cards/card_episode.tscn")
const IMAGE: PackedScene = preload("res://scenes/cards/card_image.tscn")
const VIDEO: PackedScene = preload("res://scenes/cards/card_video.tscn")
const DEFAULT_PREVIEW: NoiseTexture2D = preload("res://resources/theme/default_preview.tres")
const TAB: PackedScene = preload("res://scenes/tabs/tab.tscn")
const TEXT_DIALOG: PackedScene = preload("res://scenes/windows/text_dialog.tscn")

#endregion

#region Onready Variables

@onready var menu_bar = $"../MenuBar"

@onready var episode_flow: HFlowContainer = %EpisodeFlow
@onready var load_more_button: Button = %LoadMoreButton
@onready var load_less_button: Button = %LoadLessButton

@onready var hero: ZudeToolsHero = %HeroPanel
@onready var toggle_hero_button: Button = %ToggleHeroButton

@onready var tabs_container: TabContainer = %TabsContainer
@onready var preview_size_slider: HSlider = %PreviewSizeSlider
@onready var item_count_label: LineEdit = %ItemCountLineEdit

#endregion

#region Export Variables

@export var episode_buffer_increment: int = 20: set = set_episode_buffer_increment

#endregion

#region Variables

# TODO - create episode buffer handling
var episode_buffer_size: int = episode_buffer_increment
var episode_buffer: Dictionary
var episode_titles: PackedStringArray
var tabs: Dictionary

#endregions

func _ready() -> void:
	Config.editor_refresh_requested.connect(refresh_interface)
	Config.directory_set.connect(reset_interface)
	Config.preview_set.connect(refresh_interface)
	
	load_more_button.pressed.connect(increment_episode_buffer_size)
	load_less_button.pressed.connect(reset_episode_buffer_size)
	toggle_hero_button.pressed.connect(hero.toggle_visibility)

func _exit_tree() -> void:
	Config.editor_refresh_requested.disconnect(refresh_interface)
	Config.directory_set.disconnect(reset_interface)
	Config.preview_set.disconnect(refresh_interface)
	
	load_more_button.pressed.disconnect(increment_episode_buffer_size)
	load_less_button.pressed.disconnect(reset_episode_buffer_size)
	toggle_hero_button.pressed.disconnect(hero.toggle_visibility)

#region Interface

## Refresh episode flow.
func refresh_interface() -> void:
	refresh_episode_titles()
	refresh_episode_flow()
	refresh_button_visibility()
	print("Editor interface refreshed.")

## Clear and reload all interface properties.
func reset_interface() -> void:
	hero.clear()
	clear_tabs()
	refresh_interface()
	print("Editor interface reset.")

## Check various editor properties and states to show or hide buttons.
func refresh_button_visibility() -> void:
	if episode_buffer_size >= episode_titles.size():
		load_more_button.visible = false
	else:
		load_more_button.visible = true
	
	if episode_buffer_size == episode_buffer_increment:
		load_less_button.visible = false
	else:
		load_less_button.visible = true

## Hide the editor and show the settings menu.
func toggle_interface() -> void:
	visible = !visible

#endregion

#region Episodes

## Popup a text dialog and load a new episode with the provided text.
func new_episode() -> void:
	var dialog = TEXT_DIALOG.instantiate()
	dialog.confirmed.connect(load_episode, CONNECT_ONE_SHOT)
	dialog.confirmed.connect(refresh_interface, CONNECT_ONE_SHOT)
	add_child(dialog)

## Gets all episode directories as a PackedStringArry and sets it to episode_titles.
func refresh_episode_titles() -> PackedStringArray:
	if Config.settings.directory == null:
		print("No directory selected!")
		return []
	
	episode_titles = DirAccess.get_directories_at(Config.settings.directory)
	episode_titles.reverse()
	return episode_titles

# TODO - ## Load or free episodes based on the current state of episode_titles and episode_buffer.
func refresh_episode_flow() -> void:
	free_episodes()
	load_episodes()

## Instantiate an episode instance and add it to the episode buffer.
func buffer_episode(title: String) -> ZudeToolsCardEpisode:
	# Early return if the episode buffer is full.
	if episode_buffer.size() >= episode_buffer_size:
		return
	
	# Early return if the episode is already buffered.
	if episode_buffer.has(title):
		return
	
	# Instantiate and name the CardEpisode.
	var episode: ZudeToolsCardEpisode = EPISODE.instantiate()
	
	# Append episode to the episode buffer.
	episode_buffer.merge({title : episode})
	
	return episode

## Buffer an episode instance and add it to the episode flow.
func load_episode(title: String) -> void:
	# Early return if this episode is already loaded.
	if episode_buffer.has(title):
		return
	
	# Configure the the path for the episode based on the config directory.
	var episode = buffer_episode(title)
	var path = Config.settings.directory.path_join(title)
	
	# Early return if buffer_episode returned null.
	if episode == null: return
	
	# Add the episode to the episode flow.
	episode.set_directory(path)
	episode_flow.add_child(episode)
	
	# Configure the episode directory, title, and preview.
	episode.set_title(title)
	if Config.settings.preview != null:
		var image = Image.new()
		image.load(Config.settings.preview)
		var texture = ImageTexture.create_from_image(image)
		episode.set_preview(texture)
	else:
		episode.set_preview(DEFAULT_PREVIEW)
	
	# Connect the episode focused signal to the relevant update methods.
	episode.focused.connect(hero.refresh)
	episode.focused.connect(refresh_tab_flows)
	
	# FIXME - # Create a lambda function to adjust item's size when the slider value changes.
	var set_episode_scale = func(new_scale: int) -> void:
		episode.scale = Vector2(new_scale, new_scale)
	
	# Connect slider to lambda.
	menu_bar.episode_size_slider.value_changed.connect(set_episode_scale)

## Get episode titles and fill the episode flow with an episode instance for each that doesn't yet exist.
func load_episodes() -> void:
	for episode_title: String in episode_titles:
		if episode_buffer.has(episode_title) == false:
			load_episode(episode_title)

## Free an episode instance from the episode buffer.
func unbuffer_episode(title: String) -> ZudeToolsCardEpisode:
	if episode_buffer.has(title):
		var episode: ZudeToolsCardEpisode = episode_buffer.get(title)
		episode_buffer.erase(title)
		return episode
	
	return null

## Unbuffer an episode instance and call queue_free on it.
func free_episode(title: String) -> void:
	var episode = unbuffer_episode(title)
	
	# Early return if buffer_episode returned null.
	if episode == null: return
	
	# Disconnect the episode focused signal from the relevant update methods.
	episode.focused.disconnect(hero.refresh)
	episode.focused.disconnect(refresh_tab_flows)
	
	episode.queue_free()

## Free all episodes from the episode buffer and remove them from the episode flow.
func free_episodes() -> void:
	# Early return if no episodes exist to free.
	if episode_buffer.is_empty():
		return
	
	for episode_title: String in episode_buffer.keys():
		free_episode(episode_title)

## Reset the episode buffer size to its increment size, then refresh the interface.
func reset_episode_buffer_size() -> void:
	episode_buffer_size = episode_buffer_increment
	refresh_interface()

## Set the episode buffer increment size, then refresh the interface.
func set_episode_buffer_increment(value: float) -> void:
	episode_buffer_increment = value
	reset_episode_buffer_size()

## Increment the episode buffer size, then load episodes.
func increment_episode_buffer_size() -> void:
	episode_buffer_size += episode_buffer_increment
	episode_buffer_size = clamp(episode_buffer_size, 0, episode_titles.size())
	load_episodes()
	refresh_button_visibility()

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
	var valid: bool = false
	
	# Early return if item is not a valid file.
	if file_name.is_valid_filename() == false:
		return
	
	# Create a placeholder tab item so we can chose how to handle it.
	var card: ZudeToolsCard
	
	# Handle image files.
	if file_name.get_extension() in ["png", "jpg"]:
		# Instantiate a new CardImage
		card = IMAGE.instantiate()
		tab.flow.add_child(card)
		
		# Configure card.
		card.set_title(file_name)
		var image = Image.new()
		image.load(file_path)
		var texture: Texture2D
		if image.is_empty() == false:
			texture = ImageTexture.create_from_image(image)
		else:
			texture = DEFAULT_PREVIEW
		card.set_preview(texture)
		
		valid = true
	
	# Handle image template files.
	elif file_name.get_extension() in ["psd", "krz", "kra"]:
		# Instantiate a new CardVideo
		card = IMAGE.instantiate()
		tab.flow.add_child(card)
		
		# Configure card.
		card.set_title(file_name)
		var image = Image.new()
		image.load(file_path)
		var texture: Texture2D
		if image.is_empty() == false:
			texture = ImageTexture.create_from_image(image)
		else:
			texture = DEFAULT_PREVIEW
		card.set_preview(texture)
		
		valid = true
	
	# FIXME - Video cards are still comically large
	# Handle video files.
	#elif file_name.get_extension() in ["mp4", "mkv"]:
		## Instantiate a new CardVideo
		#card = VIDEO.instantiate()
		#tab.flow.add_child(card)
		#
		## Configure card.
		#card.set_title(file_name)
		#card.set_preview(file_path)
		#
		#valid = true
	
	if valid:
		# FIXME - # Create a lambda function to adjust item's size when the slider value changes.
		var set_card_scale = func(new_scale: float) -> void:
			card.scale = Vector2(new_scale, new_scale)
		
		# Connect slider to lambda.
		preview_size_slider.value_changed.connect(set_card_scale)

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
