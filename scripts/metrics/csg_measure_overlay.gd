@tool
class_name CsgBlockoutMeasureOverlay
extends CsgBlockoutTool
## Passive overlay: dimension lines with W/H/D labels (meters) on the selected CSG
## shapes and frozen blockout, drawn along the bottom edges nearest the camera.
## Toggled from the top bar; the setting is stored per user.

const MAX_LABELED: int = 8
const META_KEY: String = "show_dimensions"
const COLORS: Array[Color] = [Color(1.0, 0.45, 0.45), Color(0.5, 0.95, 0.5), Color(0.45, 0.65, 1.0)]

static var enabled: bool = true
static var _loaded: bool = false

static func load_state() -> void:
	if _loaded:
		return
	_loaded = true
	var settings: EditorSettings = EditorInterface.get_editor_settings()
	enabled = bool(settings.get_project_metadata(CsgBlockoutGrid.META_SECTION, META_KEY, true))

static func set_enabled(value: bool) -> void:
	enabled = value
	EditorInterface.get_editor_settings().set_project_metadata(CsgBlockoutGrid.META_SECTION, META_KEY, value)

func get_id() -> StringName:
	return &"measure_overlay"

func draw_overlay(overlay: Control, camera: Camera3D) -> void:
	load_state()
	if not enabled or camera == null:
		return
	var count: int = 0
	for n: Node in EditorInterface.get_selection().get_selected_nodes():
		if count >= MAX_LABELED:
			break
		if n is CSGShape3D or CsgBlockoutFreeze.is_frozen(n):
			if _draw_dimensions(overlay, camera, n as Node3D):
				count += 1

## Draws three dimension lines from the bottom corner closest to the camera.
func _draw_dimensions(overlay: Control, camera: Camera3D, n: Node3D) -> bool:
	var box: AABB = CsgBlockoutShapeInfo.local_aabb(n) if n is CSGShape3D else (n as VisualInstance3D).get_aabb()
	if box.size == Vector3.ZERO:
		return false
	var xf: Transform3D = n.global_transform
	var cam_local: Vector3 = xf.affine_inverse() * camera.global_position
	var anchor: Vector3 = Vector3(
		box.end.x if cam_local.x > box.get_center().x else box.position.x,
		box.position.y,
		box.end.z if cam_local.z > box.get_center().z else box.position.z)
	var ends: Array[Vector3] = [
		Vector3(box.position.x + box.end.x - anchor.x, anchor.y, anchor.z),
		Vector3(anchor.x, box.end.y, anchor.z),
		Vector3(anchor.x, anchor.y, box.position.z + box.end.z - anchor.z),
	]
	var scale: float = EditorInterface.get_editor_scale()
	var font: Font = overlay.get_theme_font(&"font", &"Label")
	var font_size: int = int(round(12 * scale))
	var world_size: Vector3 = CsgBlockoutShapeInfo.world_size(n) if n is CSGShape3D else box.size * xf.basis.get_scale()
	var a_world: Vector3 = xf * anchor
	if camera.is_position_behind(a_world):
		return false
	var a2: Vector2 = camera.unproject_position(a_world)
	for axis: int in 3:
		var b_world: Vector3 = xf * ends[axis]
		if camera.is_position_behind(b_world):
			continue
		var b2: Vector2 = camera.unproject_position(b_world)
		if a2.distance_to(b2) < 12.0 * scale:
			continue
		var color: Color = COLORS[axis]
		overlay.draw_line(a2, b2, color, 2.0 * scale, true)
		var dir: Vector2 = (b2 - a2).normalized()
		var tick: Vector2 = Vector2(-dir.y, dir.x) * 5.0 * scale
		overlay.draw_line(a2 - tick, a2 + tick, color, 2.0 * scale, true)
		overlay.draw_line(b2 - tick, b2 + tick, color, 2.0 * scale, true)
		var label: String = "%s %s m" % ["WHD"[axis], CsgBlockoutDrawTool._fmt(world_size[axis])]
		var mid: Vector2 = (a2 + b2) * 0.5 + tick * 3.5
		CsgBlockoutToolManager.draw_label(overlay, font, font_size, mid, label, false)
	return true

## With exactly two nodes selected: adds a ruler between their closest top edges,
## which shows whether the gap is jumpable with the current player metrics.
static func check_jump_between_selection() -> void:
	var nodes: Array[Node3D] = CsgBlockoutSelection.top_level_nodes()
	if nodes.size() != 2:
		CsgBlockoutFreeze._toast(CsgBlockoutI18n.t("WARN_SELECT_TWO"), EditorToaster.SEVERITY_WARNING)
		return
	var a: AABB = CsgBlockoutSelection.world_aabb(nodes[0])
	var b: AABB = CsgBlockoutSelection.world_aabb(nodes[1])
	# Closest points between the two top rectangles (alternate clamping converges for boxes).
	var pa: Vector2 = Vector2(a.get_center().x, a.get_center().z)
	var pb: Vector2 = Vector2(b.get_center().x, b.get_center().z)
	for i: int in 3:
		pb = Vector2(clampf(pa.x, b.position.x, b.end.x), clampf(pa.y, b.position.z, b.end.z))
		pa = Vector2(clampf(pb.x, a.position.x, a.end.x), clampf(pb.y, a.position.z, a.end.z))
	var from: Vector3 = Vector3(pa.x, a.end.y, pa.y)
	var to: Vector3 = Vector3(pb.x, b.end.y, pb.y)
	# Measure from the lower top to the higher one (the direction you'd jump up).
	if from.y > to.y:
		var tmp: Vector3 = from
		from = to
		to = tmp
	var ruler: CSGRuler3D = CSGRuler3D.new()
	var parent: Node = CsgBlockoutSceneOps.edited_root()
	ruler.name = CsgBlockoutSceneOps.unique_child_name(parent, "JumpCheck")
	ruler.target_point = to - from
	CsgBlockoutSceneOps.Action.new(CsgBlockoutI18n.t("CHECK_JUMP_ACTION")).add_node(parent, ruler, -1, Transform3D(Basis.IDENTITY, from)).select([ruler]).commit()
	var gap: float = Vector2(to.x - from.x, to.z - from.z).length()
	var rise: float = to.y - from.y
	var key: String = "JUMP_RESULT_OK" if ruler.is_jump_reachable else "JUMP_RESULT_FAIL"
	CsgBlockoutFreeze._toast(CsgBlockoutI18n.tf(key, [CsgBlockoutDrawTool._fmt(gap), CsgBlockoutDrawTool._fmt(rise)]),
		EditorToaster.SEVERITY_INFO if ruler.is_jump_reachable else EditorToaster.SEVERITY_WARNING)
