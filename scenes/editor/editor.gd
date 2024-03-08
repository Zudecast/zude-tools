@tool
class_name ZudeToolsEditor
extends Control

#region Constants

const IMAGE: PackedScene = preload("res://scenes/cards/card_image.tscn")
const VIDEO: PackedScene = preload("res://scenes/cards/card_video.tscn")
const DEFAULT_PREVIEW: NoiseTexture2D = preload("res://resources/theme/default_preview.tres")
const TAB: PackedScene = preload("res://scenes/tabs/tab.tscn")

#endregion

#region Onready Variables

@onready var episode_panel: ZudeToolsEpisodePanel = %EpisodePanel
@onready var hero_panel: ZudeToolsHeroPanel = %HeroPanel
@onready var tabs_container: TabContainer = %TabsContainer

@onready var toggle_hero_button: Button = %ToggleHeroButton
@onready var preview_size_slider: HSlider = %PreviewSizeSlider
@onready var item_count_label: LineEdit = %ItemCountLineEdit

#endregion

#region Variables

var tabs: Dictionary

#endregions

func _ready() -> void:
	Config.editor_refresh_requested.connect(refresh_top)
	Config.directory_set.connect(reset_interface)
	Config.preview_set.connect(refresh_top)
	
	toggle_hero_button.pressed.connect(hero_panel.toggle_visibility)

func _exit_tree() -> void:
	Config.editor_refresh_requested.disconnect(refresh_top)
	Config.directory_set.disconnect(reset_interface)
	Config.preview_set.disconnect(refresh_top)
	
	toggle_hero_button.pressed.disconnect(hero_panel.toggle_visibility)

#region Interface

## Refresh episode panel.
func refresh_top() -> void:
	episode_panel.refresh()

## Refresh hero panel and tabs container.
func refresh_btm(episode: ZudeToolsCardEpisode) -> void:
	hero_panel.refresh(episode)
	refresh_tab_flows(episode)

## Clear and reload all interface properties.
func reset_interface() -> void:
	hero_panel.clear()
	clear_tabs()
	refresh_top()

## Hide the editor and show the settings menu.
func toggle_interface() -> void:
	visible = !visible

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
