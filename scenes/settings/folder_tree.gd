@tool
class_name ZudeToolsFolderTree
extends Tree

#region Variables

var tree: Dictionary

#endregion

#region Signals

signal tree_updated(Dictionary)

#endregion

func _ready() -> void:
	set_column_title(0, "Folder Name")
	set_column_title_alignment(0, HORIZONTAL_ALIGNMENT_LEFT)
	set_column_title(1, "Tags")
	set_column_title_alignment(1, HORIZONTAL_ALIGNMENT_LEFT)
	
	item_edited.connect(update_tree)
	tree_updated.connect(Config.set_folder_tree)
	button_clicked.connect(handle_buttons)

func _exit_tree() -> void:
	item_edited.disconnect(update_tree)
	tree_updated.disconnect(Config.set_folder_tree)
	button_clicked.disconnect(handle_buttons)

## Clear the folder tree then rebuild it from config.
func refresh_folder_tree_menu() -> void:
	clear()
	create_tree_root()
	build_tree()

## Create the root tree item.
func create_tree_root() -> void:
	var root: TreeItem = create_item()
	
	root.set_text(0, "root")
	
	root.set_selectable(0, false)
	root.set_editable(0, false)

## Create the a tree item witht the specified parameters.
func create_tree_item(parent: TreeItem = null, folder_name: String = "new_folder", tags: String = "") -> TreeItem:
	var selected = get_selected()
	var item: TreeItem
	
	if parent != null:
		item = create_item(parent)
	else:
		item = create_item(selected)
	
	item.set_text(0, folder_name)
	item.set_editable(0, true)

	item.set_text(1, tags)
	item.set_editable(1, true)
	
	item.add_button(1, PlaceholderTexture2D.new(), 0, false, "up")
	item.add_button(1, PlaceholderTexture2D.new(), 1, false, "down")
	item.add_button(1, PlaceholderTexture2D.new(), 2, false, "delete")
	
	return item

## Recursively build children of the specified item as defined in the config file.
func build_tree(item: TreeItem = get_root()) -> void:
	var item_name = item.get_text(0)
	for parent_name: String in Config.settings.folder_tree:
		var child_dict_array: Array = Config.settings.folder_tree.get(parent_name)
		if parent_name == item_name:
			for child_dict: Dictionary in child_dict_array:
				var child_name: String = child_dict.keys()[0]
				var child_tags: String = child_dict.values()[0]
				var child: TreeItem = create_tree_item(item, child_name, child_tags)
				build_tree(child)

## Recursively collect children of the specified item and store them in the tree dictionary.
func collect_tree(item: TreeItem = get_root()) -> void:
	var item_name = item.get_text(0)
	tree.merge({item_name : []}, true)
	
	for child: TreeItem in item.get_children():
		var child_name: String = child.get_text(0)
		var child_tags: String = child.get_text(1)
		var child_dict: Dictionary = {child_name : child_tags}
		
		tree[item_name].append(child_dict)
		
		if child.get_child_count() > 0:
			collect_tree(child)

## Sends tree dictionary to config.
func update_tree() -> void:
	collect_tree()
	tree_updated.emit(tree)

## Handle which button clicks to what for a gven item.
func handle_buttons(item: TreeItem, _column: int, id: int, _mouse_button_index: int) -> void:
	if id == 0:
		item.move_before(item.get_prev_in_tree())
	if id == 1:
		item.move_after(item.get_next_in_tree())
	if id == 2:
		var parent = item.get_parent()
		parent.remove_child(item)
		tree.erase(item)
	
	update_tree()