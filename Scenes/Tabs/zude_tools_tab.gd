@tool
class_name ZudeToolsTab
extends ZudeTools

#region Onready Variables

@onready var flow: HFlowContainer = %DetailsFlow
@onready var nothing_label: Label = %NothingLabel

#endregion

#region Signals

## Emitted when the flow child_order_changed signal is also emitted and this tab is visible.
signal flow_count(int)

#endregion

func _ready() -> void:
	visibility_changed.connect(check_flow_count)

func _exit_tree():
	visibility_changed.disconnect(check_flow_count)

## Update the nothing_label's visibility based on if there are children in the flow node.
func check_for_items() -> void:
	if flow.get_child_count() == 0:
		nothing_label.set_visible(true)
	else:
		nothing_label.set_visible(false)

## Get the number of children in the flow, emit child count through visibility_changed.
func check_flow_count() -> void:
	if visible:
		flow_count.emit(flow.get_child_count())
