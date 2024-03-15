@tool
class_name ZudeToolsContextMenu
extends MenuButton

#region Enumerations

enum {TEMPLATE}

#endregion

#region Onready Variables

@onready var popup_menu: PopupMenu = get_popup()

#endregion

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

func populate_templates() -> void:
	popup_menu.add_separator("Templates")
	var template_path: String
	
	for template_name: String in Config.templates.keys():
		template_path = Config.templates.get(template_name)
		popup_menu.add_item(template_name)
		popup_menu.set_item_metadata(-1, {TEMPLATE : template_path})

func handle_metadata(index: int) -> void:
	var metadata: Dictionary = popup_menu.get_item_metadata(index)
	var meta_value: String = metadata.values()[0]
	match metadata.keys()[0]:
		TEMPLATE:
			# FIXME - generate_template(meta_value)
			pass

# TODO - Generate tempalte with naming conventions.
func generate_template(title: String, path: String, template_path: String) -> void:
	pass
