class_name TabFlow
extends Control

#region Onready Variables

@onready var flow = %DetailsFlow
@onready var nothing_label = %NothingLabel

#endregion

## Connect all signals.
func _ready() -> void:
	flow.child_entered_tree.connect(check_for_children)
	flow.child_exiting_tree.connect(check_for_children)

## Update the nothing_label node's visibility based on the amount of children in the flow node.
func check_for_children(node: Node = null) -> void:
	if flow.get_children().size() == 0:
		nothing_label.set_visible(true)
	else:
		nothing_label.set_visible(false)

## Disconnect all signals.
func _exit_tree() -> void:
	flow.child_entered_tree.disconnect(check_for_children)
	flow.child_exiting_tree.disconnect(check_for_children)
