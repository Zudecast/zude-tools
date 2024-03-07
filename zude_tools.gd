@tool
class_name ZudeTools
extends Control

func _ready() -> void:
	print("-- Welcome to Zude Tools. --")
	Config.read()

func _exit_tree() -> void:
	#Config.write()
	print("-- Exiting Zude Tools. --")
