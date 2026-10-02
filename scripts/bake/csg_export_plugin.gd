@tool
class_name CsgBlockoutExportPlugin
extends EditorExportPlugin
## Strips CSG Blockout's editor-only data from exported scenes: the packed CSG source
## and shell stored on frozen nodes, so frozen blockout costs nothing at runtime.
## Disable with Project Settings > addons/csg_blockout/bake/strip_source_on_export.

const STRIP_METAS: Array[StringName] = [&"_csg_blockout_source", &"_csg_blockout_shell", &"_csg_blockout_bake", &"_csg_blockout_home"]

func _get_name() -> String:
	return "CSGBlockoutStripEditorData"

func _get_customization_configuration_hash() -> int:
	return hash([_get_name(), CsgBlockoutConfig.get_config().get_strip_source_on_export()])

func _begin_customize_scenes(_platform: EditorExportPlatform, _features: PackedStringArray) -> bool:
	return CsgBlockoutConfig.get_config().get_strip_source_on_export()

func _customize_scene(scene: Node, _path: String) -> Node:
	return scene if strip(scene) else null

## Removes the editor-only metadata from `root` and its descendants.
## Returns true when anything was removed.
static func strip(root: Node) -> bool:
	var changed: bool = false
	var stack: Array[Node] = [root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		for meta: StringName in STRIP_METAS:
			if n.has_meta(meta):
				n.remove_meta(meta)
				changed = true
		stack.append_array(n.get_children())
	return changed

func _customize_resource(_resource: Resource, _path: String) -> Resource:
	return null

func _begin_customize_resources(_platform: EditorExportPlatform, _features: PackedStringArray) -> bool:
	return false
