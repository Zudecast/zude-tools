@tool
class_name ZudeToolsTheme
extends ColorPicker

#region Constants

var ZUDE_TOOLS_THEME: Theme = preload("res://resources/theme/zude_tools_theme.tres")
var PANEL_FLAT: StyleBoxFlat = preload("res://resources/theme/panel_flat.tres")

#endregion

#region Onready Variables

@onready var font_size: LineEdit = %FontSizeLineEdit

#endregion

func _ready() -> void:
	Config.settings_refresh_requested.connect(update_theme_color)
	Config.theme_color_set.connect(update_theme_color)
	
	color_changed.connect(Config.set_color)
	
	# TODO - font_size.text_submitted.connect(set_global_font_size)

func _exit_tree() -> void:
	Config.settings_refresh_requested.disconnect(update_theme_color)
	Config.theme_color_set.disconnect(update_theme_color)
	
	color_changed.disconnect(Config.set_color)
	
	# TODO - font_size.text_submitted.disconnect(set_global_font_size)

# TODO - # Set font size theme-wide.
func set_global_font_size(text: String) -> void:
	ZUDE_TOOLS_THEME.set_default_font_size(int(text))
	ZUDE_TOOLS_THEME.set_font_size("Label", "Label", int(text))

## Set interface theme color.
func update_theme_color(color_html: String = Config.color) -> void:
	color = Color(color_html)
	PANEL_FLAT.bg_color = color * Color(1, 1, 1, 0.5)
