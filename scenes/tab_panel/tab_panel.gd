@tool
class_name ZudeToolsTabPanel
extends Control

#region Constants

const TAB: PackedScene = preload("res://scenes/tab_panel/tab.tscn")

#endregion

#region Export Variables

@export var editor: ZudeToolsEditor
@export var hero_panel: ZudeToolsHeroPanel
@export var bottom_bar: ZudeToolsBottomBar

#endregion

#region Variables

var tabs: Dictionary

#endregions

## Load or free tabs for to reflect the focused episode's directories. Populate with files if created.
func refresh() -> void:
	if Focused.card is ZudeToolsCardFolder:
		var push_card: ZudeToolsCardFolder = Focused.card
		free_tabs(push_card)
		load_tabs(push_card)
		refresh_tabs()

## Free all tabs from the tab container and the tabs dictionary.
func clear() -> void:
	if tabs.is_empty() == false:
		for tab_name: String in tabs.keys():
			free_tab(tab_name)

## Instantiate a tab with the specified name and add it to the node tree and the tabs dictionary.
func load_tab(tab_name: String) -> ZudeToolsTab:
	# Instantiate a new tab and add it to the node tree.
	var tab: ZudeToolsTab = TAB.instantiate()
	add_child(tab)
	# Configure tab.
	tab.name = tab_name
	# Connect tab to update_item_count.
	tab.items_counted.connect(bottom_bar.update_item_count)
	# Add tab to the tabs dictionary.
	tabs.merge({tab.name : tab})
	
	return tab

## Create a tab for each episode directory that a tab does not yet exist for.
func load_tabs(focused_folder: ZudeToolsCardFolder) -> void:	
	for dir_name: String in focused_folder.directories.keys():
		# Load a new tab if one with dir_name does not exist, else get the loaded tab with dir_name.
		if not dir_name in tabs:
			load_tab(dir_name)

## Free a tab with the specified name from the node tree and erase it from the tabs dictionary.
func free_tab(tab_name: String) -> void:
	var tab: ZudeToolsTab = tabs[tab_name]
	
	# Disconnect tab from update_item_count.
	tab.items_counted.disconnect(bottom_bar.update_item_count)
	# Erase and queue_free().
	tabs.erase(tab_name)
	tab.queue_free()

## Free tabs with names not listed in the episode directories.
func free_tabs(focused_folder: ZudeToolsCardFolder) -> void:
	for tab_name: String in tabs.keys():
		if focused_folder.directories.has(tab_name) == false:
			free_tab(tab_name)

## Refresh all tabs, freeing their items and loading relevant ones.
func refresh_tabs() -> void:
	for tab: ZudeToolsTab in tabs.values():
		tab.refresh()
