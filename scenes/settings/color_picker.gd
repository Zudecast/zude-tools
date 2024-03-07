@tool
class_name ZudeToolsTheme
extends ColorPicker

#region Constants

var ZUDE_TOOLS_THEME: Theme = preload("res://resources/theme/zude_tools_theme.tres")
var PANEL_FLAT: StyleBoxFlat = preload("res://resources/theme/panel_flat.tres")

#endregion

#region Onready Variables

@onready var font_size = %FontSizeLineEdit

#endregion

func _ready() -> void:
	color_changed.connect(set_panel_color)
	font_size.text_submitted.connect(set_global_font_size)
	
	set_global_font_size(font_size.text)

func _exit_tree():
	color_changed.disconnect(set_panel_color)
	font_size.text_submitted.disconnect(set_global_font_size)

# FIXME - # Set font size theme-wide.
func set_global_font_size(text: String) -> void:
	ZUDE_TOOLS_THEME.set_default_font_size(int(text))
	ZUDE_TOOLS_THEME.set_font_size("Label", "Label", int(text))

func set_panel_color(new_color: Color) -> void:
	PANEL_FLAT.bg_color = new_color * Color(0.5, 0.5, 0.5, 0.5)
