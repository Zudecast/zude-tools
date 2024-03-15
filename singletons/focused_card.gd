@tool
extends Node

#region Variables

var card: ZudeToolsCard

#endregion

## Set the title, get directories and files.
func set_focused(focused_card: ZudeToolsCard) -> void:
	card = focused_card
