class_name TabFlow
extends Control

#region Onready Variables

@onready var flow = %DetailsFlow
@onready var nothing_label = %NothingLabel

#endregion

## Update the nothing_label node's visibility based on the amount of children in the flow node.
func check_for_children() -> void:
	if flow.get_children().size() == 0:
		nothing_label.set_visible(true)
	else:
		nothing_label.set_visible(false)

