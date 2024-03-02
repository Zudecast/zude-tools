class_name ZudeToolsTab
extends Control

#region Onready Variables

@onready var flow: HFlowContainer = %DetailsFlow
@onready var nothing_label: Label = %NothingLabel

#endregion

## Update the nothing_label's visibility based on if there are children in the flow node.
func check_for_items() -> void:
	if flow.get_child_count() == 0:
		nothing_label.set_visible(true)
	else:
		nothing_label.set_visible(false)
