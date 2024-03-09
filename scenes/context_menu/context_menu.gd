@tool
class_name ZudeToolsContextMenu
extends Control

enum {TEMPLATE}

@onready var popup_menu = %PopupMenu

#region Variables

var mouse_position: Vector2

#endregion

func _ready() -> void:
	Config.settings_refresh_requested.connect(popup_menu.clear)
	Config.settings_refresh_requested.connect(populate_templates)
	
	popup_menu.index_pressed.connect(handle_metadata)

func _exit() -> void:
	Config.settings_refresh_requested.disconnect(popup_menu.clear)
	Config.settings_refresh_requested.disconnect(populate_templates)
	
	popup_menu.index_pressed.disconnect(handle_metadata)

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_RIGHT:
			mouse_position = get_global_mouse_position()
			popup_menu.popup_on_parent(Rect2(mouse_position.x, mouse_position.y, popup_menu.size.x, popup_menu.size.y))

func populate_templates() -> void:
	popup_menu.add_separator("Templates")
	for template_name in Config.settings.templates.keys():
		var template_path = Config.settings.templates.get(template_name)
		popup_menu.add_item(template_name)
		popup_menu.set_item_metadata(-1, {TEMPLATE : template_path})

func handle_metadata(index: int) -> void:
	var metadata = popup_menu.get_item_metadata(index)
	var meta_value = metadata.values()[0]
	match metadata.keys()[0]:
		TEMPLATE:
			# FIXME - generate_template(meta_value)
			pass

func generate_template(title: String, path: String, template_path: String) -> void:
	pass
