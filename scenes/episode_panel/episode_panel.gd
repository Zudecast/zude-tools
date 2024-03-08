@tool
class_name ZudeToolsEpisodePanel
extends Control

#region Constants

const TEXT_DIALOG: PackedScene = preload("res://scenes/windows/text_dialog.tscn")
const EPISODE: PackedScene = preload("res://scenes/cards/card_episode.tscn")
const DEFAULT_PREVIEW: NoiseTexture2D = preload("res://resources/theme/default_preview.tres")

#endregion

#region Export Variables

@export var editor: ZudeToolsEditor

#endregion

#region Onready Variables

@onready var flow: HFlowContainer = %EpisodeFlow
@onready var load_more_button: Button = %LoadMoreButton
@onready var load_less_button: Button = %LoadLessButton

#endregion

#region Export Variables

@export var buffer_increment: int = 20: set = set_buffer_increment

#endregion

#region Variables

var buffer_size: int = buffer_increment
var buffer: Dictionary
var titles: PackedStringArray

#endregion

func _ready() -> void:
	load_more_button.pressed.connect(increment_buffer_size)
	load_less_button.pressed.connect(reset_buffer_size)

func _exit_tree() -> void:
	load_more_button.pressed.disconnect(increment_buffer_size)
	load_less_button.pressed.disconnect(reset_buffer_size)

## Refresh episode flow.
func refresh() -> void:
	refresh_episode_titles()
	refresh_episode_flow()
	refresh_button_visibility()
	print("Episode panel refreshed.")

## Gets all episode directories as a PackedStringArry and sets it to titles.
func refresh_episode_titles() -> void:
	if Config.settings.directory == null:
		print("No directory selected!")
		return
	
	titles = DirAccess.get_directories_at(Config.settings.directory)
	# NOTE - is this useful? -> #titles.sort()
	titles.reverse()

## Load or free episodes based on the current state of the titles and buffer properties.
func refresh_episode_flow() -> void:
	free_unlisted_episodes()
	load_episodes()

## Check which buttons should be visible.
func refresh_button_visibility() -> void:
	if buffer_size >= titles.size():
		load_more_button.visible = false
	else:
		load_more_button.visible = true
	
	if buffer_size == buffer_increment:
		load_less_button.visible = false
	else:
		load_less_button.visible = true

## Popup a text dialog and load a new episode with the provided text.
func new_episode() -> void:
	var dialog = TEXT_DIALOG.instantiate()
	dialog.confirmed.connect(load_episode, CONNECT_ONE_SHOT)
	dialog.confirmed.connect(refresh, CONNECT_ONE_SHOT)
	add_child(dialog)

## Instantiate an episode instance and add it to the episode buffer.
func buffer_episode(title: String) -> ZudeToolsCardEpisode:
	# Early return if the episode buffer is full.
	if buffer.size() >= buffer_size:
		return
	
	# Early return if the episode is already buffered.
	if buffer.has(title):
		return
	
	# Instantiate and name the CardEpisode.
	var episode: ZudeToolsCardEpisode = EPISODE.instantiate()
	
	# Append episode to the episode buffer.
	buffer.merge({title : episode})
	
	return episode

## Buffer an episode instance and add it to the episode flow.
func load_episode(title: String) -> void:
	# Early return if this episode is already loaded.
	if buffer.has(title):
		return
	
	# Configure the the path for the episode based on the config directory.
	var episode = buffer_episode(title)
	var path = Config.settings.directory.path_join(title)
	
	# Early return if buffer_episode returned null.
	if episode == null: return
	
	# Add the episode to the episode flow.
	episode.set_directory(path)
	flow.add_child(episode)
	
	# Configure the episode directory, title, and preview.
	episode.set_title(title)
	if Config.settings.preview != null:
		var image = Image.new()
		image.load(Config.settings.preview)
		var texture = ImageTexture.create_from_image(image)
		episode.set_preview(texture)
	else:
		episode.set_preview(DEFAULT_PREVIEW)
	
	# Connect the episode focused signal to the relevant update methods.
	episode.focused.connect(editor.refresh_btm)

## Get episode titles and fill the episode flow with an episode instance for each that doesn't yet exist.
func load_episodes() -> void:
	for episode_title: String in titles:
		if buffer.has(episode_title) == false:
			load_episode(episode_title)

## Free an episode instance from the episode buffer.
func unbuffer_episode(title: String) -> ZudeToolsCardEpisode:
	if buffer.has(title):
		var episode: ZudeToolsCardEpisode = buffer.get(title)
		buffer.erase(title)
		return episode
	
	return null

## Unbuffer an episode instance and call queue_free on it.
func free_episode(title: String) -> void:
	var episode = unbuffer_episode(title)
	
	# Early return if buffer_episode returned null.
	if episode == null: return
	
	# Disconnect the episode focused signal from the relevant update methods.
	episode.focused.disconnect(editor.refresh_btm)
	
	episode.queue_free()

## Free all episodes from the episode buffer and remove them from the episode flow.
func free_episodes() -> void:
	# Early return if no episodes exist to free.
	if buffer.is_empty():
		return
	
	for episode_title: String in buffer.keys():
		free_episode(episode_title)

## TODO - ## Free episodes that are no longer listed in titles
func free_unlisted_episodes() -> void:
	free_episodes()

## Reset the episode buffer size to its increment size, then refresh the interface.
func reset_buffer_size() -> void:
	buffer_size = buffer_increment
	refresh()

## Set the episode buffer increment size, then refresh the interface.
func set_buffer_increment(increment: int) -> void:
	buffer_increment = increment
	reset_buffer_size()

## Increment the episode buffer size, then load episodes.
func increment_buffer_size() -> void:
	buffer_size += buffer_increment
	buffer_size = clamp(buffer_size, buffer_increment, titles.size())
	load_episodes()
	refresh_button_visibility()
