@tool
extends Node

## Get all directories recursively at the specified path. Name is key and path is value.
func get_directories(path: String = Config.directory) -> Dictionary:
	var directories: Dictionary = {}
	
	for dir_name: String in DirAccess.get_directories_at(path):
		var dir_path: String = path.path_join(dir_name)
		directories.merge({dir_name : dir_path})
		directories.merge(get_directories(dir_path))
	
	return directories

## Build directories based on the folders settings menu for new episodes.
func make_directories(path: String) -> void:
	for parent_name: String in Config.folders.keys():
		var parent_path: String
		if parent_name == "root":
			parent_path = path
		else:
			parent_path = path.path_join(parent_name)
		
		var child_names: Array = Config.folders.get(parent_name)
		for child_name: String in child_names:
			var child_path: String = parent_path.path_join(child_name)
			DirAccess.make_dir_recursive_absolute(child_path)
	
	prints("Created directories at:", path)
	Config.editor_refresh_requested.emit()

## Get all files in the specified dictionary. Looks for name as key and path as value.
func get_files(directories: Dictionary) -> Dictionary:
	var files: Dictionary = {}
	
	for dir_name: String in directories.keys():
		var dir_path: String = directories.get(dir_name)
		var dir_files: Dictionary = get_files_at(dir_name, dir_path)
		files.merge(dir_files)
	
	return files

## Get all files at the specified directory. Directory name is key and a PackedStringArray of file paths is value.
func get_files_at(dir_name: String, dir_path: String) -> Dictionary:
	var dir_files: PackedStringArray = DirAccess.get_files_at(dir_path)
	
	return {dir_name : dir_files}
