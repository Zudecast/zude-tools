class_name ZudeTools
extends Control

#region Onready Variable

@onready var splash: ZudeToolsSplash = $ZudeToolsSplash

#endregion

func _ready() -> void:
	if splash:
		splash.set_visible(false)
