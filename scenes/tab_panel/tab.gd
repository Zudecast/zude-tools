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

func _exit_tree():
	visibility_changed.disconnect(count_items)

## Update the nothing_label's visibility based on if there are children in the flow node.
func refresh_button_visibility() -> void:
	if flow.get_child_count() == 0:
		nothing_label.set_visible(true)
	else:
		nothing_label.set_visible(false)

## Add any item to the specified tab.
func load_item(file_name: String, file_path: String) -> void:
	# Early return if item is not a valid file.
	if file_name.is_valid_filename() == false:
		return
	
	# Create a placeholder tab item so we can chose how to handle it.
	var card: ZudeToolsCard
	var image: = Image.new()
	var texture: Texture2D = Config.DEFAULT_PREVIEW
	
	# Handle image files.
	if file_name.get_extension() in ["png", "jpg"]:
		# Instantiate a new CardImage.
		card = IMAGE.instantiate()
		# Configure card title and path.
		card.title = file_name
		card.path = file_path
		# Add card to item flow.
		flow.add_child(card)
	
	# Handle image template files.
	elif file_name.get_extension() in ["psd", "krz", "kra"]:
		# Instantiate a new CardImage.
		card = IMAGE.instantiate()
		# Configure card title and path.
		card.title = file_name
		card.path = file_path
		# Add card to item flow.
		flow.add_child(card)
	
	##  Handle video files.
	elif file_name.get_extension() in ["mp4", "mkv"]:
		# Instantiate a new CardVideo
		card = VIDEO.instantiate()
		# Configure card title and path.
		card.title = file_name
		card.path = file_path
		# Add card to item flow.
		flow.add_child(card)
	
	refresh_button_visibility()

## Remove any item from the specified tab at the specified index.
func free_item(item: Control) -> void:
	item.queue_free()
	
	refresh_button_visibility()

## Remove all items from the specified tab.
func free_items() -> void:
	for child in flow.get_children():
		free_item(child)

## Get the number of children in the flow, emit child count through visibility_changed.
func count_items() -> void:
	if visible:
		items_counted.emit(flow.get_child_count())
	
	refresh_button_visibility()
