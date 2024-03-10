@tool
class_name ZudeToolsTab
extends Control

#region Constants

const IMAGE: PackedScene = preload("res://scenes/cards/card_image.tscn")
const VIDEO: PackedScene = preload("res://scenes/cards/card_video.tscn")

#endregion

#region Onready Variables

@onready var flow: HFlowContainer = %TabFlow
@onready var nothing_label: Label = %NothingLabel

#endregion

#region Signals

## Emitted via count_items when the visibility_changed signal is also emitted.
signal items_counted(int)
## Emitted via check_focus when the visibility_changed signal is also emitted.
signal focused(bool)

#endregion

func _ready() -> void:
	visibility_changed.connect(check_focus)
	visibility_changed.connect(count_items)
	visibility_changed.connect(refresh_label_visibility)

func _exit_tree():
	visibility_changed.disconnect(check_focus)
	visibility_changed.disconnect(count_items)
	visibility_changed.disconnect(refresh_label_visibility)

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
	
	# Define lamba function to configure card and add it to the episode flow.
	var add_card = func(card: ZudeToolsCard) -> void:
		# Configure card and add it to the episode flow.
		card.title = file_name
		card.path = file_path
		flow.add_child(card)
		
		# Define lambda function for disconnecting signals on tree exit.
		var disconnect_signals = func() -> void:
			focused.disconnect(card.tab_focused)
			card.focused.disconnect(tab_panel.hero_panel.refresh)
			tab_panel.bottom_bar.preview_size_slider.value_changed.disconnect(card.set_min_size)
		
		# Connect signals.
		focused.connect(card.tab_focused)
		card.focused.connect(tab_panel.hero_panel.refresh)
		tab_panel.bottom_bar.preview_size_slider.value_changed.connect(card.set_min_size)
		card.tree_exiting.connect(disconnect_signals)
	
	# Handle image files.
	if extension in ["png", "jpg", "webp"]:
		add_card.call(IMAGE.instantiate())
	
	# Handle image template files.
	elif extension in ["psd", "krz", "kra"]:
		add_card.call(IMAGE.instantiate())
	
	#  Handle video files.
	elif extension in ["mp4"]:
		add_card.call(VIDEO.instantiate())

## Remove an item from the flow at the specified index.
func free_item(item: Control) -> void:
	item.queue_free()

## Remove all items from the flow.
func free_items() -> void:
	for child in flow.get_children():
		free_item(child)

## Get the number of items in the flow, emit item count through items_counted.
func count_items() -> void:
	if visible:
		items_counted.emit(flow.get_child_count())

## Get the visiblity of this tab and emit its state through focused.
func check_focus() -> void:
	if visible:
		focused.emit(true)
	else:
		focused.emit(false)
