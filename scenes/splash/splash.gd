@tool
class_name ZudeToolsSplash
extends ZudeTools

func _ready() -> void:
	Config.settings_refresh_requested.connect(kill, CONNECT_ONE_SHOT)

func kill() -> void:
	queue_free()
