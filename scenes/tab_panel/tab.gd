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

## Emitted when the flow child_order_changed signal is also emitted and this tab is visible.
signal items_counted(int)

#endregion

func _ready() -> void:
	visibility_changed.connect(count_items)
	visibility_changed.connect(refresh_label_visibility)

func _exit_tree():
	visibility_changed.disconnect(count_items)
	visibility_changed.disconnect(refresh_label_visibility)

## Update the nothing_label's visibility based on if there are children in the flow node.
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
	
	var add_card = func(card: ZudeToolsCard) -> void:
		card.title = file_name
		card.path = file_path
		card.focused.connect(get_parent().hero_panel.refresh)
		flow.add_child(card)
	
	# Handle image files.
	if extension in ["png", "jpg"]:
		add_card.call(IMAGE.instantiate())
	
	# Handle image template files.
	elif extension in ["psd", "krz", "kra"]:
		add_card.call(IMAGE.instantiate())
	
	#  Handle video files.
	elif extension in ["mp4", "mkv"]:
		add_card.call(VIDEO.instantiate())

## Remove any item from the specified tab at the specified index.
func free_item(item: Control) -> void:
	item.queue_free()

## Remove all items from the specified tab.
func free_items() -> void:
	for child in flow.get_children():
		free_item(child)

## Get the number of items in the flow, emit item count through items_counted.
func count_items() -> void:
	if visible:
		items_counted.emit(flow.get_child_count())
