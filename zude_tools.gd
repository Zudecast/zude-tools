class_name ZudeTools
extends Control

#region Onready Variable

@onready var splash: ZudeToolsSplash = $ZudeToolsSplash

#endregion

func _ready() -> void:
	splash.set_visible(false)
