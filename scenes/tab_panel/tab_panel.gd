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
func refresh(episode: ZudeToolsCardEpisode) -> void:
	free_tabs(episode)
	load_tabs(episode)

## Free all tabs from the tab container and the tabs dictionary.
func clear() -> void:
	if tabs.is_empty() == false:
		for tab in tabs.values():
			free_tab(tab)

## Instantiate a tab with the specified name and add it to the node tree and the tabs dictionary.
func load_tab(tab_name: String) -> void:
	# Instantiate a new tab and add it to the node tree.
	var tab: ZudeToolsTab = TAB.instantiate()
	add_child(tab)
	# Configure tab.
	tab.name = tab_name
	# Connect tab to update_item_count.
	tab.items_counted.connect(bottom_bar.update_item_count)
	# Add tab to the tabs dictionary.
	tabs.merge({tab.name : tab})

## Create a tab for each episode directory that a tab does not yet exist for.
func load_tabs(episode: ZudeToolsCardEpisode) -> void:
	for dir_name: String in episode.directories.keys():
		if tabs.has(dir_name) == false:
			load_tab(dir_name)
		
		# Populate each tab's item flow with relevant files.
		for file_name: String in episode.files[dir_name]:
			var file_path: String = episode.directories[dir_name].path_join(file_name)
			tabs[dir_name].load_item(file_name, file_path)

## Free a tab with the specified name from the node tree and erase it from the tabs dictionary.
func free_tab(tab_name: String) -> void:
	var tab = tabs[tab_name]
	# Disconnect tab from update_item_count.
	tab.items_counted.disconnect(bottom_bar.update_item_count)
	
	tabs.erase(tab_name)
	tab.queue_free()

## Free tabs with names not listed in the episode directories, else free its items for reuse.
func free_tabs(episode: ZudeToolsCardEpisode) -> void:
	for tab_name: String in tabs.keys():
		var tab: ZudeToolsTab = tabs.get(tab_name)
		if episode.directories.has(tab_name):
			tab.free_items()
		else:
			free_tab(tab_name)
