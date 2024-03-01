class_name ZudeTools
extends Control

@onready var splash: ZudeToolsSplash = $ZudeToolsSplash

func _ready() -> void:
	splash.set_visible(false)
