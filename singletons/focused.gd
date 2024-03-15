@tool
extends Node

#region Onready Variables

@onready var menu_bar: ZudeToolsMenuBar = $"../ZudeTools/ZudeToolsMargin/ZudeToolsVBox/ZudeToolsMenuBar"
@onready var editor: ZudeToolsEditor = $"../ZudeTools/ZudeToolsMargin/ZudeToolsVBox/ZudeToolsEditor"
@onready var settings: ZudeToolsSettings = $"../ZudeTools/ZudeToolsMargin/ZudeToolsVBox/ZudeToolsSettings"

#endregion

#region Variables

var card: ZudeToolsCard

#endregion

## Set the focused card and perform the relevant refresh methods.
func set_card(focus_card: ZudeToolsCard) -> void:
	card = focus_card
	
	editor.hero_panel.refresh()
	editor.tab_panel.refresh()
