class_name ZudeToolsCard
extends Control

#region Variables

## This card's title.
var title: String
## This card's path.
var path: String

#endregion

## Emitted via focus_changed when the focus_entered signal is also emitted.
signal focused(ZudeToolsCard)

## Emit the focused signal (returning self) when the focus_entered signal is also emitted.
func focus_changed() -> void:
	focused.emit(self)

## Receive focus state from the tab and do something with it.
func tab_focused(_is_focused: bool) -> void:
	pass

## Set the minimum size for card.
func set_min_size(value: float) -> void:
	custom_minimum_size.x = value
