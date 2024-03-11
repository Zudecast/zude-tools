@tool
class_name ZudeToolsTab
extends Control

#region Constants

const CARD: PackedScene = preload("res://scenes/cards/card.tscn")
const CardImage: Script = preload("res://scenes/cards/card_image.gd")
const CardVideo: Script = preload("res://scenes/cards/card_video.gd")

#endregion

#region Onready Variables

@onready var flow: HFlowContainer = %TabFlow
@onready var nothing_label: Label = %NothingLabel

#endregion

#region Variables

var episode: ZudeToolsCardEpisode: set = refresh

#endregion

#region Signals

## Emitted via count_items when the visibility_changed signal is also emitted.
signal items_counted(int)
## Emitted via check_visible when the visibility_changed signal is also emitted.
signal visibility(bool)

#endregion

func _ready() -> void:
	visibility_changed.connect(check_visible)
	visibility_changed.connect(count_items)
	visibility_changed.connect(refresh_label_visibility)

func _exit_tree():
	visibility_changed.disconnect(check_visible)
	visibility_changed.disconnect(count_items)
	visibility_changed.disconnect(refresh_label_visibility)

## Free all items, load new ones from episode, then refresh label.
func refresh(from_episode: ZudeToolsCardEpisode = episode) -> void:
	episode = from_episode
	free_items()
	load_items(from_episode)
	refresh_label_visibility()

## Update the nothing_label's visibility based on if there are children in the flow.
func refresh_label_visibility() -> void:
	if flow.get_child_count() == 0:
		nothing_label.set_visible(true)
	else:
		nothing_label.set_visible(false)

## Add any item to the specified tab.
func load_item(file_name: String, file_path: String) -> void:
	# Early return if item is not a valid file.
	if file_name.is_valid_filename() == false:
		return
	
	# Get file extension so we can chose how to handle the file.
	var extension: String = file_name.get_extension()
	var tab_panel: ZudeToolsTabPanel = get_parent()
	var new_card: ZudeToolsCard
	
	# Define lamba function to configure card and add it to the episode flow.
	var add_card = func(card: ZudeToolsCard) -> void:
		# Configure card and add it to the episode flow.
		card.title = file_name
		card.path = file_path
		flow.add_child(card)
		
		# Define lambda function for disconnecting signals on tree exit.
		var disconnect_signals = func() -> void:
			visibility.disconnect(card.tab_visible)
			card.focused.disconnect(tab_panel.hero_panel.refresh)
			tab_panel.bottom_bar.preview_size_slider.value_changed.disconnect(card.set_min_size)
		
		# Connect signals.
		visibility.connect(card.tab_visible)
		card.focused.connect(tab_panel.hero_panel.refresh)
		tab_panel.bottom_bar.preview_size_slider.value_changed.connect(card.set_min_size)
		card.tree_exiting.connect(disconnect_signals)
	
	# Handle image files.
	if extension in ["png", "jpg", "webp"]:
		new_card = CARD.instantiate()
		new_card.set_script(CardImage)
		add_card.call(new_card)
	
	# Handle image template files.
	elif extension in ["psd", "krz", "kra"]:
		new_card = CARD.instantiate()
		new_card.set_script(CardImage)
		add_card.call(new_card)
	
	#  Handle video files.
	elif extension in ["mp4"]:
		new_card = CARD.instantiate()
		new_card.set_script(CardVideo)
		add_card.call(new_card)

## Loads items when the episode reference is set.
func load_items(from_episode: ZudeToolsCardEpisode = episode) -> void:
	var file_path: String
	
	# Populate each tab's item flow with relevant files.
	for file_name: String in from_episode.files[name]:
		file_path = from_episode.directories[name].path_join(file_name)
		load_item(file_name, file_path)

## Remove an item from the flow at the specified index.
func free_item(item: Control) -> void:
	item.queue_free()

## Remove all items from the flow.
func free_items() -> void:
	for child in flow.get_children():
		free_item(child)

## Emit item count to bottom_bar through items_counted so it can refresh its label.
func count_items() -> void:
	if visible:
		items_counted.emit(flow.get_child_count())

## Emit this tab's visibility to its children through focused.
func check_visible() -> void:
	if visible:
		visibility.emit(true)
	else:
		visibility.emit(false)
	
	refresh_label_visibility()
