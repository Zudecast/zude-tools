@tool
class_name ZudeToolsCard
extends Button

#region Onready Variables

@onready var panel: PanelContainer = %Panel
@onready var margin: MarginContainer = %Margin
@onready var label: Label = %Label

#endregion

#region Variables

## This card's title.
var title: String
## This card's path.
var path: String

#endregion

#region Signals

## Emitted via focus_changed when the focus_entered signal is also emitted.
signal focused(ZudeToolsCard)

#endregion

func _ready() -> void:
	focus_entered.connect(focus_changed)
	mouse_entered.connect(show_panel)
	mouse_exited.connect(hide_panel)
	
	update_label()
	update_texture()

func _exit_tree() -> void:
	focus_entered.disconnect(focus_changed)
	mouse_entered.disconnect(show_panel)
	mouse_exited.disconnect(hide_panel)

## Emit the focused signal (returning self) when the focus_entered signal is also emitted.
func focus_changed() -> void:
	focused.emit(self)

## Receive focus state from parent tab. Override this and do something with it.
func tab_focused(_is_focused: bool) -> void:
	pass

## Set the label text.
func update_label() -> void:
	name = title
	label.text = title
	tooltip_text = title

## Set the card texture.
func update_texture(new_texture: Texture2D = Config.DEFAULT_PREVIEW) -> void:
	var image = Image.new()
	image.load(path)
	
	if image.is_empty() == false:
		new_texture = ImageTexture.create_from_image(image)
	
	icon = new_texture

## Show the overlay panel.
func show_panel() -> void:
	panel.visible = true

## Hide the overlay panel.
func hide_panel() -> void:
	panel.visible = false

## Set the minimum size for card.
func set_min_size(value: float) -> void:
	custom_minimum_size = Vector2(1.6, 0.9) * value
