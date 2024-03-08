@tool
class_name ZudeToolsTab
extends Control

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
func check_for_items() -> void:
	if flow.get_child_count() == 0:
		nothing_label.set_visible(true)
	else:
		nothing_label.set_visible(false)

## Get the number of children in the flow, emit child count through visibility_changed.
func count_items() -> void:
	if visible:
		items_counted.emit(flow.get_child_count())
