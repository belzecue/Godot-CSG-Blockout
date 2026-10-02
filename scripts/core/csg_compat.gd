@tool
class_name CsgBlockoutCompat
extends RefCounted
## Every engine-version-sensitive call goes through here, so lowering the minimum
## Godot version only touches this file.
##   EditorDock / add_dock ............ 4.6+ (add_control_to_dock before that)
##   EditorSettings.add_shortcut ...... 4.6+ (see CsgBlockoutShortcuts fallback)
##   TriangleMesh.intersect_ray ....... 4.5+

static func has_editor_dock() -> bool:
	return ClassDB.class_exists(&"EditorDock")

## Adds `content` as a dock and returns the handle to pass to remove_dock().
static func add_dock(plugin: EditorPlugin, content: Control, title: String, icon: Texture2D) -> Control:
	if has_editor_dock():
		var dock: Control = ClassDB.instantiate(&"EditorDock") as Control
		dock.set(&"title", title)
		if icon != null:
			dock.set(&"dock_icon", icon)
		dock.set(&"default_slot", 3) # EditorDock.DOCK_SLOT_RIGHT_UL
		dock.add_child(content)
		plugin.call(&"add_dock", dock)
		return dock
	content.name = title
	plugin.call(&"add_control_to_dock", EditorPlugin.DOCK_SLOT_RIGHT_UL, content)
	return content

static func remove_dock(plugin: EditorPlugin, handle: Control) -> void:
	if handle == null or not is_instance_valid(handle):
		return
	if has_editor_dock() and handle.is_class("EditorDock"):
		plugin.call(&"remove_dock", handle)
	else:
		plugin.call(&"remove_control_from_docks", handle)
	handle.queue_free()
