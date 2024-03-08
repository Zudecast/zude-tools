class_name ZudeToolsCard
extends Control

## Emitted by focus_changed() when the focus_entered signal is also emitted.
signal focused(ZudeToolsCard)

## Emit the focused signal (returning self) when the focus_entered signal is also emitted.
func focus_changed() -> void:
	focused.emit(self)
