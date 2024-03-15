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
func refresh(episode: ZudeToolsCardFolder) -> void:
	free_tabs(episode)
	load_tabs(episode)
	refresh_tabs(episode)

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
func load_tabs(from_episode: ZudeToolsCardFolder) -> void:
	for dir_name: String in from_episode.directories.keys():
		# Load a new tab if one with dir_name does not exist, else get the loaded tab with dir_name.
		# Update the reference to the focused episode so the tab can refresh its items.
		if not dir_name in tabs:
			load_tab(dir_name).episode = from_episode
		else:
			tabs[dir_name].episode = from_episode

## Free a tab with the specified name from the node tree and erase it from the tabs dictionary.
func free_tab(tab_name: String) -> void:
	var tab: ZudeToolsTab = tabs[tab_name]
	
	# Disconnect tab from update_item_count.
	tab.items_counted.disconnect(bottom_bar.update_item_count)
	# Erase and queue_free().
	tabs.erase(tab_name)
	tab.queue_free()

## Free tabs with names not listed in the episode directories.
func free_tabs(using_episode: ZudeToolsCardFolder) -> void:
	for tab_name: String in tabs.keys():
		if using_episode.directories.has(tab_name) == false:
			free_tab(tab_name)

## Refresh all tabs, freein their items and loding relevant ones.
func refresh_tabs(episode: ZudeToolsCardFolder) -> void:
	for tab: ZudeToolsTab in tabs.values():
		tab.refresh(episode)
