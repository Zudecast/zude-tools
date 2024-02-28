class_name ZudeTools
extends Control

#region Onready Variables

@onready var zude_tools_editor: ZudeToolsEditor = %ZudeToolsEditor
@onready var zude_tools_splash: ZudeToolsSplash = %ZudeToolsSplash

#endregion

func _ready() -> void:
	await zude_tools_editor.init()
	zude_tools_splash.set_visible(false)
