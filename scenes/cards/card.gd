@tool
class_name ZudeToolsCard
extends Button

#region Onready Variables

@onready var preview: TextureRect = %Preview
@onready var panel: PanelContainer = %Panel
@onready var margin: MarginContainer = %Margin
@onready var label: Label = %Label

#endregion

#region Variables

## This card's file title.
var title: String
## This card's file path.
var path: String
## This card's file directory.
var directory: String

#endregion

#region Signals

## Emitted via focus_changed when the focus_entered signal is also emitted.
signal focused(card: ZudeToolsCard)

#endregion

func _ready() -> void:
	
	focus_entered.connect(focus_changed)
	mouse_entered.connect(show_panel)
	mouse_exited.connect(hide_panel)
	
	update_label()
	update_preview()

func _exit_tree() -> void:
	focus_entered.disconnect(focus_changed)
	mouse_entered.disconnect(show_panel)
	mouse_exited.disconnect(hide_panel)

## Emit the focused signal (returning self) when the focus_entered signal is also emitted.
func focus_changed() -> void:
	focused.emit(self)

## Receive visibility state from parent tab. Override this and do something with it.
func tab_visible(_visibility: bool) -> void:
	pass

## Set the label text.
func update_label() -> void:
	name = title
	label.text = title
	tooltip_text = title

## Set the card texture.
func update_preview() -> void:
	var new_image := Image.new()
	var new_texture: Texture2D
	
	if path == null:
		path = Config.preview
	
	new_image.load(path)
	new_texture = ImageTexture.create_from_image(new_image)
	preview.texture = new_texture

## Show the overlay panel.
func show_panel() -> void:
	panel.visible = true

## Hide the overlay panel.
func hide_panel() -> void:
	panel.visible = false

## Set the minimum size for card.
func set_min_size(value: float) -> void:
	custom_minimum_size = Vector2(1.6, 0.9) * value
