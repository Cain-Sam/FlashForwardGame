@tool
extends Node
class_name SceneEXPORTER


## The scene to export. [br] This will put the scene and all its dependencies into a zip folder file at [member export_path].
@export var target_scene: PackedScene
## The exported zip file with all the files required for the new project.
@export var export_path: String = "res://scene_bundle.zip"
## Include UID files if available
@export var include_uid_files: bool = true
## Search all script files for [method preload] and [method load] and also include those strings in the dependencies.
@export var search_scripts_for_references: bool = true
## Prints all packed files in the console
@export var show_packed_logs: bool = false
## List of extra scenes to export.[br][br]So you can export several scenes at once.
@export var multiple_scenes: Array[PackedScene]

@export_tool_button("Export Assets")
var export_scene = package_scene_to_zip

func package_scene_to_zip() -> void:
	pressClearButton()
	print("Cleared console.")
	await get_tree().create_timer(0.2).timeout

	if not target_scene and multiple_scenes.is_empty():
		push_error("No scene assigned.")
		return

	if not export_path:
		push_error("No export path")
		return

	if not export_path.ends_with(".zip"):
		export_path = export_path + ".zip"

	var packer := ZIPPacker.new()
	var err := packer.open(export_path)

	if err != OK:
		push_error("Failed to create ZIP. Error: ", err)
		return

	var scene_path : String
	var files_to_include: Array[String] = []
	if target_scene:
		scene_path = target_scene.resource_path

		# Start recursive collection
		_collect_dependencies_recursive(scene_path, files_to_include)

	if not multiple_scenes.is_empty():
		for scene in multiple_scenes:
			if not scene: continue
			scene_path = scene.resource_path
			_collect_dependencies_recursive(scene_path, files_to_include)

	for file_path in files_to_include:
		_add_file_to_zip(packer, file_path)

		if include_uid_files:
			var uid_file_path := file_path + ".uid"
			if FileAccess.file_exists(uid_file_path):
				_add_file_to_zip(packer, uid_file_path)

	packer.close()

	if not export_path.begins_with("user://") and not export_path.begins_with("res://"):
		# Sets defaul res:// so that globalize shows full path
		export_path = "res://" + export_path

	var absolute_path := ProjectSettings.globalize_path(export_path)
	var absolute_folder := "/".join(absolute_path.split("/").slice(0,-1))

	#print("Bundle created successfully at: ", export_path)
	#print("Full path: ", ProjectSettings.globalize_path(export_path))
	#print_rich("[url=", absolute_folder,"]", "Folder path:[/url] [color=teal][b][url=", absolute_path, "]", absolute_path, "[/url][/b][/color]")
	print_rich("Folder: [color=teal][b][url=", absolute_folder, "]", absolute_folder, "[/url][/b][/color]")
	print_rich("Bundle created successfully at: [color=teal][b][url=", absolute_path, "]", export_path, "[/url][/b][/color]")



func _collect_dependencies_recursive(path: String, list: Array[String]) -> void:
	var actual_path := path

	# Resolve UID strings to res:// paths
	if path.begins_with("uid://"):
		var id := ResourceUID.text_to_id(path)
		if ResourceUID.has_id(id):
			actual_path = ResourceUID.get_id_path(id)
		else:
			push_warning("UID not found in database: ", path)
			return

	if actual_path == "" or list.has(actual_path):
		return

	list.append(actual_path)

	# 1. Recursively check for nested dependencies
	var deps := ResourceLoader.get_dependencies(actual_path)
	for dep in deps:
		var clean_dep := dep.split("::")[0]
		_collect_dependencies_recursive(clean_dep, list)

	# 2. Manual Script Parsing (for preload/load)
	if search_scripts_for_references:
		if actual_path.ends_with(".gd"):
			_extract_dependencies_from_script(actual_path, list)

func _add_file_to_zip(packer: ZIPPacker, file_path: String) -> void:
	if FileAccess.file_exists(file_path):
		var file_data := FileAccess.get_file_as_bytes(file_path)
		var internal_path := file_path.replace("res://", "")

		packer.start_file(internal_path)
		packer.write_file(file_data)
		packer.close_file()
		if show_packed_logs: print("Packed: ", internal_path)


#region Script dependencies
func _extract_dependencies_from_script(script_path: String, list: Array[String]) -> void:
	var file := FileAccess.open(script_path, FileAccess.READ)
	if not file:
		return

	var content := file.get_as_text()
	var regex := RegEx.new()
	# Pattern matches: preload("path") or load("path")
	regex.compile("(?:preload|load)\\s*\\(\\s*[\"'](.*?)[\"']\\s*\\)")

	var results := regex.search_all(content)
	for found in results:
		var inner_path := found.get_string(1)
		if inner_path.begins_with("res://") or inner_path.begins_with("uid://"):
			_collect_dependencies_recursive(inner_path, list)

#endregion


#region clear console hack
# Hacky want to clear the editor console.
func pressClearButton()->void:
	var shortcut:= EditorInterface.get_editor_settings().get_shortcut("editor/clear_output").get_as_text()
	var root:=EditorInterface.get_inspector().get_tree().root
	_pressClearButton(root, shortcut)


func _pressClearButton(node:Node, shortcutText:String)->bool:
	for i in node.get_child_count():
		var child:= node.get_child(i)
		if child is Button:
			var b:= child as Button
			if b.shortcut:
				if b.shortcut.get_as_text() == shortcutText:
					b.pressed.emit()
					return true
		if child.get_child_count() > 0:
			if _pressClearButton(child, shortcutText):
				return true
	return false
#endregion
