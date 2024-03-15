@tool
class_name ZudeTools
extends Control

# TODO - Create the ability to save and load folder structures as json files.
# TODO - Remove tags from folder structure saving and loading, as I've found a simpler system.
# TODO - Write new FFMPEG plugin, the existing one is old and sucks.
# TODO - Implement episode flow buffer size as a settings option.

func _ready() -> void:
	print("-- Welcome to Zude Tools. --")
	# Config is read after children are ready. Config updates send signals to the rest of Zude Tools.
	Config.read()

func _exit_tree() -> void:
	Config.write()
	print("-- Exiting Zude Tools. --")
