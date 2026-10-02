@tool
class_name CsgBlockoutFreeze
extends RefCounted
## Reversible bake ("freeze"). A CSG root is swapped in place for a plain
## MeshInstance3D (+ StaticBody3D collision when the CSG used collision) with the
## same name and transform. The original CSG subtree is stored, packed, in the
## frozen node's editor-only metadata, so "unfreeze" brings it back exactly.
## Non-CSG nodes living inside the CSG tree (lights, markers, ...) are moved onto the
## frozen node and back again, so they never disappear while frozen.
## Unfreezing stashes the frozen node itself (script, groups, layers, extra children
## the user added) as a "shell"; freezing again reuses it, so the node keeps its
## customizations and its path.

const META_SOURCE: StringName = &"_csg_blockout_source"
const META_SHELL: StringName = &"_csg_blockout_shell"
const META_BAKE: StringName = &"_csg_blockout_bake"
const META_HOME: StringName = &"_csg_blockout_home"
const META_GENERATED: StringName = &"_csg_blockout_generated"
const COLLISION_NAME: String = "Collision"
const TEMP_SUFFIX: String = "__csg_swap"

static func is_frozen(n: Node) -> bool:
	return n is MeshInstance3D and n.has_meta(META_SOURCE)

## CSG roots and frozen nodes the current selection refers to.
static func selection_targets() -> Dictionary:
	var roots: Array[CSGShape3D] = []
	var frozen: Array[MeshInstance3D] = []
	for n: Node in EditorInterface.get_selection().get_selected_nodes():
		if is_frozen(n):
			if not frozen.has(n):
				frozen.append(n as MeshInstance3D)
			continue
		var root: CSGShape3D = CsgBlockoutShapeInfo.csg_root_of(n)
		if root != null and not roots.has(root):
			roots.append(root)
	return {"roots": roots, "frozen": frozen}

# --- freeze ---------------------------------------------------------------------

## Freezes the CSG roots in the selection as one undo step.
static func freeze_selection() -> void:
	var targets: Dictionary = selection_targets()
	await freeze(targets["roots"])

static func freeze(roots: Array[CSGShape3D]) -> void:
	var scene_root: Node = EditorInterface.get_edited_scene_root()
	if scene_root == null or roots.is_empty():
		return
	# CSG meshes update one frame after edits.
	await scene_root.get_tree().process_frame
	var action: CsgBlockoutSceneOps.Action = CsgBlockoutSceneOps.Action.new(CsgBlockoutI18n.t("FREEZE_ACTION"))
	var frozen_nodes: Array[Node] = []
	for root: CSGShape3D in roots:
		if not is_instance_valid(root) or not root.is_inside_tree():
			continue
		if root == scene_root:
			_toast(CsgBlockoutI18n.t("WARN_FREEZE_SCENE_ROOT"), EditorToaster.SEVERITY_WARNING)
			continue
		var mesh: ArrayMesh = root.bake_static_mesh()
		if mesh == null or mesh.get_surface_count() == 0:
			_toast(CsgBlockoutI18n.tf("WARN_FREEZE_EMPTY", [root.name]), EditorToaster.SEVERITY_WARNING)
			continue
		_warn_external_references(root, scene_root)
		var frozen: MeshInstance3D = _build_frozen(root, mesh)
		frozen.set_meta(META_SOURCE, _pack_source(root, scene_root))
		# Swap under a temporary name, then take over the original name once the CSG
		# root is gone (two siblings can't share a name).
		var final_name: String = String(root.name)
		frozen.name = final_name + TEMP_SUFFIX
		var parent: Node = root.get_parent()
		action.add_node(parent, frozen, root.get_index(), root.global_transform, "packed")
		for extra: Node in _extras(root):
			action.assign_meta(extra, META_HOME, String(root.get_path_to(extra.get_parent())))
			action.reparent(extra, frozen)
		action.remove_node(root)
		action.rename(frozen, final_name)
		frozen_nodes.append(frozen)
	if action.is_empty():
		return
	action.select(frozen_nodes)
	action.commit()

## Frozen node: the stashed shell (if this CSG was frozen before) or a new
## MeshInstance3D, with the baked mesh and generated collision.
static func _build_frozen(root: CSGShape3D, mesh: ArrayMesh) -> MeshInstance3D:
	var frozen: MeshInstance3D = null
	if root.has_meta(META_SHELL) and root.get_meta(META_SHELL) is PackedScene:
		frozen = (root.get_meta(META_SHELL) as PackedScene).instantiate() as MeshInstance3D
	if frozen == null:
		frozen = MeshInstance3D.new()
		frozen.layers = root.layers
		frozen.cast_shadow = root.cast_shadow
		frozen.gi_mode = root.gi_mode
	frozen.name = root.name
	frozen.mesh = mesh
	for child: Node in frozen.get_children():
		if child.has_meta(META_GENERATED):
			frozen.remove_child(child)
			child.free()
	var options: Dictionary = {"collision": "trimesh" if root.use_collision else "none"}
	frozen.set_meta(META_BAKE, options)
	if root.use_collision:
		var shape: ConcavePolygonShape3D = root.bake_collision_shape()
		if shape != null:
			var body: StaticBody3D = StaticBody3D.new()
			body.name = COLLISION_NAME
			body.collision_layer = root.collision_layer
			body.collision_mask = root.collision_mask
			body.set_meta(META_GENERATED, true)
			var col: CollisionShape3D = CollisionShape3D.new()
			col.name = "Shape"
			col.shape = shape
			body.add_child(col)
			frozen.add_child(body)
			frozen.move_child(body, 0)
			# Owners must be ancestors, so set them once the body hangs under `frozen`.
			body.owner = frozen
			col.owner = frozen
	return frozen

## Packs a copy of the CSG subtree (without the non-CSG extras and the shell).
static func _pack_source(root: CSGShape3D, scene_root: Node) -> PackedScene:
	var copy: Node = root.duplicate()
	_mirror_owners(root, copy, scene_root, copy)
	var extra_paths: Array[NodePath] = []
	for extra: Node in _extras(root):
		extra_paths.append(root.get_path_to(extra))
	for p: NodePath in extra_paths:
		var dup: Node = copy.get_node_or_null(p)
		if dup != null:
			dup.get_parent().remove_child(dup)
			dup.free()
	if copy.has_meta(META_SHELL):
		copy.remove_meta(META_SHELL)
	var packed: PackedScene = PackedScene.new()
	packed.pack(copy)
	copy.free()
	return packed

## Copies ownership: nodes the scene owns in `original` are owned by `new_owner` in `copy`.
static func _mirror_owners(original: Node, copy: Node, scene_root: Node, new_owner: Node) -> void:
	var count: int = mini(original.get_child_count(), copy.get_child_count())
	for i: int in count:
		var o: Node = original.get_child(i)
		var c: Node = copy.get_child(i)
		if o.owner == scene_root:
			c.owner = new_owner
		_mirror_owners(o, c, scene_root, new_owner)

## Topmost non-CSG nodes inside a CSG tree (each moves with its own subtree).
static func _extras(root: Node) -> Array[Node]:
	var out: Array[Node] = []
	for child: Node in root.get_children():
		if child is CSGShape3D:
			out.append_array(_extras(child))
		elif child.owner != null:
			out.append(child)
	return out

## Warns when nodes outside the tree point (NodePath properties) into it.
static func _warn_external_references(root: Node, scene_root: Node) -> void:
	var hits: PackedStringArray = []
	var stack: Array[Node] = [scene_root]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n == root:
			continue
		stack.append_array(n.get_children())
		for prop: Dictionary in n.get_property_list():
			if prop["type"] != TYPE_NODE_PATH or not (prop["usage"] & PROPERTY_USAGE_STORAGE):
				continue
			var path: NodePath = n.get(prop["name"])
			if path.is_empty():
				continue
			var target: Node = n.get_node_or_null(path)
			if target != null and target != root and root.is_ancestor_of(target):
				hits.append("%s.%s" % [scene_root.get_path_to(n), prop["name"]])
	if not hits.is_empty():
		_toast(CsgBlockoutI18n.tf("WARN_FREEZE_REFERENCES", [root.name, ", ".join(hits)]), EditorToaster.SEVERITY_WARNING)

# --- unfreeze -----------------------------------------------------------------------

static func unfreeze_selection() -> void:
	var targets: Dictionary = selection_targets()
	unfreeze(targets["frozen"])

static func unfreeze(frozen_nodes: Array[MeshInstance3D]) -> void:
	var scene_root: Node = EditorInterface.get_edited_scene_root()
	if scene_root == null or frozen_nodes.is_empty():
		return
	var action: CsgBlockoutSceneOps.Action = CsgBlockoutSceneOps.Action.new(CsgBlockoutI18n.t("UNFREEZE_ACTION"))
	var restored: Array[Node] = []
	for frozen: MeshInstance3D in frozen_nodes:
		var packed: PackedScene = frozen.get_meta(META_SOURCE) as PackedScene
		if packed == null:
			continue
		var root: Node3D = packed.instantiate() as Node3D
		if root == null:
			continue
		var final_name: String = String(frozen.name)
		root.name = final_name + TEMP_SUFFIX
		root.set_meta(META_SHELL, _pack_shell(frozen, scene_root))
		var parent: Node = frozen.get_parent()
		action.add_node(parent, root, frozen.get_index(), frozen.global_transform, "packed")
		for extra: Node in frozen.get_children():
			if not extra.has_meta(META_HOME):
				continue
			var home: Node = root.get_node_or_null(NodePath(String(extra.get_meta(META_HOME))))
			if home == null:
				home = root
			action.reparent(extra, home)
			action.assign_meta(extra, META_HOME, null)
		action.remove_node(frozen)
		action.rename(root, final_name)
		restored.append(root)
	if action.is_empty():
		return
	action.select(restored)
	action.commit()

## The frozen node minus generated content (mesh, collision, extras, source), so a
## later freeze can restore the user's customizations.
static func _pack_shell(frozen: MeshInstance3D, scene_root: Node) -> PackedScene:
	var copy: MeshInstance3D = frozen.duplicate() as MeshInstance3D
	_mirror_owners(frozen, copy, scene_root, copy)
	copy.mesh = null
	for meta: StringName in [META_SOURCE, META_BAKE]:
		if copy.has_meta(meta):
			copy.remove_meta(meta)
	for child: Node in copy.get_children():
		if child.has_meta(META_GENERATED) or child.has_meta(META_HOME):
			copy.remove_child(child)
			child.free()
	var packed: PackedScene = PackedScene.new()
	packed.pack(copy)
	copy.free()
	return packed

static func _toast(message: String, severity: EditorToaster.Severity) -> void:
	var toaster: EditorToaster = EditorInterface.get_editor_toaster()
	if toaster != null:
		toaster.push_toast(message, severity)
	else:
		push_warning(message)
