@tool
class_name ZudeToolsHeroPanel
extends Control

#region Enumerations

enum {TEMPLATE}

#endregion

#region Onready Variables

@onready var label: Label = %Label
@onready var link: LinkButton = %Link
@onready var preview: TextureRect = %Preview

@onready var templates_menu: MenuButton = %MenuButton
@onready var templates_popup: PopupMenu = templates_menu.get_popup()

#endregion

#region Variables

var card: ZudeToolsCard
var mouse_position: Vector2

#endregion

func _ready() -> void:
	Config.settings_refresh_requested.connect(refresh_templates)
	
	templates_popup.index_pressed.connect(generate_template)
	
	label.text = "Select an item..."
	link.uri = ""

func _exit() -> void:
	Config.settings_refresh_requested.disconnect(refresh_templates)
	
	templates_popup.index_pressed.disconnect(generate_template)

## Refresh the hero panel with the focused card.
func refresh() -> void:
	clear()
	
	card = Focused.card
	
	label.text = card.label.text
	preview.texture = card.preview.texture
	
	if card is ZudeToolsCardFolder:
		link.uri = card.path
	else:
		link.uri = card.directory

## Clear the hero panel.
func clear() -> void:
	card = null
	label.text = "Select an item..."
	preview.texture = null
	link.uri = ""

## Toggle hero panel visibility.
func toggle_visibility() -> void:
	visible = !visible

## Populate the templates popup with values from Config.templates.
func refresh_templates() -> void:
	templates_popup.clear()
	
	var template_path: String
	
	for template_name: String in Config.templates.keys():
		template_path = Config.templates.get(template_name)
		templates_popup.add_item(template_name)
		templates_popup.set_item_metadata(-1, template_path)

## Generate the selected template menu item using the card name and directory.
func generate_template(index: int) -> void:
	if card == null:
		return
	
	var template_path: String = templates_popup.get_item_metadata(index)
	var extension: String = template_path.get_extension()
	var title: String = card.title.get_basename()
	var path: String
	
	if card is ZudeToolsCardFolder:
		path = card.path.path_join(title)
	else:
		path = card.directory.path_join(title)
	
	path = ".".join([path, extension])
	
	if FileAccess.file_exists(path):
		OS.shell_open(path.get_base_dir())
	else:
		DirAccess.copy_absolute(template_path, path)
		OS.shell_open(path.get_base_dir())
