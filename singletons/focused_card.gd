@tool
extends Node

#region Variables

## The name of the selected card.
var title: String: set = set_title
## Contains a directory name as key and its path as value.
var directories: Dictionary
## Contains a directory name as key and a PackedStringArray of file paths as value.
var files: Dictionary

#endregion

## Set the title, get directories and files.
func set_title(text: String) -> void:
	title = text
	get_directories()

## Get all directories within this episode's directory. Directory name is key and its path is value.
func get_directories(path: String = Config.directory.path_join(title)) -> void:
	var dir_names: PackedStringArray = DirAccess.get_directories_at(path)
	
	for dir_name: String in dir_names:
		var dir_path: String = path.path_join(dir_name)
		directories.merge({dir_name : dir_path})
		
		get_directories(dir_path)
		get_files(dir_name, dir_path)

## Get all files at the specified directory.
func get_files(dir_name: String, dir_path: String) -> void:
	var dir_files: PackedStringArray = DirAccess.get_files_at(dir_path)
	files.merge({dir_name : dir_files})
