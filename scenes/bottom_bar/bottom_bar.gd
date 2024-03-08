@tool
class_name ZudeToolsBottomBar
extends Control

#region Export Variables

@export var hero_panel: ZudeToolsHeroPanel

#endregion

#region Onready Variables

@onready var toggle_hero_button: Button = %ToggleHeroButton
@onready var preview_size_slider: HSlider = %PreviewSizeSlider
@onready var item_count: LineEdit = %ItemCountLineEdit

#endregion

func _ready() -> void:
	toggle_hero_button.pressed.connect(hero_panel.toggle_visibility)

func _exit_tree() -> void:
	toggle_hero_button.pressed.disconnect(hero_panel.toggle_visibility)

## Update the item count with the number of items in the focused tab.
func update_item_count(num: int) -> void:
	item_count.text = str(num)
