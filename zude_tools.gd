@tool
class_name ZudeTools
extends Control

# TODO - Write new FFMPEG plugin, the existing one is old and sucks.
# TODO - Implement episode flow buffer size as a settings option.
# BUG - Adjusting split panels somehow crashes the program.

func _ready() -> void:
	print("-- Welcome to Zude Tools. --")
	Config.read()

func _exit_tree() -> void:
	Config.write()
	print("-- Exiting Zude Tools. --")
