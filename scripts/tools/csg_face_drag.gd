@tool
class_name CsgBlockoutFaceDrag
extends CsgBlockoutTool
## TrenchBroom-style face push/pull on selected CSG primitives: hold Shift to
## highlight the face under the cursor, Shift+drag to move it along its normal.
## The opposite face stays put, axis-aligned faces land on grid lines, and the
## drag is one undo step. A Shift+click without dragging behaves like Godot's
## Shift+click (toggles the node out of the selection).
## Supported: CSGBox3D (6 faces), CSGCylinder3D (caps -> height, side -> radius),
## CSGStairs3D (top -> height, front -> depth, sides -> width).

const DRAG_THRESHOLD: float = 4.0
const MIN_EXTENT: float = 0.01

var _hover: Dictionary = {}
var _drag: Dictionary = {}
var _shift_held: bool = false
var _press_pos: Vector2 = Vector2.ZERO

func get_id() -> StringName:
	return &"face_drag"

static func supports(n: Node) -> bool:
	return n is CSGBox3D or n is CSGCylinder3D or n is CSGStairs3D

func input(camera: Camera3D, event: InputEvent) -> int:
	if manager.active != null:
		_hover = {}
		return PASS
	if event is InputEventKey and (event as InputEventKey).keycode == KEY_SHIFT:
		_shift_held = event.is_pressed()
		_hover = _pick(camera, manager.mouse_pos) if _shift_held else {}
		manager.refresh()
		return PASS
	if event is InputEventMouseMotion:
		var mm: InputEventMouseMotion = event as InputEventMouseMotion
		if not _drag.is_empty():
			if not _drag["moved"] and mm.position.distance_to(_press_pos) < DRAG_THRESHOLD:
				return STOP
			_drag["moved"] = true
			_update_drag(camera, mm.position, mm)
			return STOP
		_shift_held = mm.shift_pressed
		var previous: bool = not _hover.is_empty()
		_hover = _pick(camera, mm.position) if _shift_held else {}
		if previous or not _hover.is_empty():
			manager.refresh()
		return PASS
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.pressed:
			if not mb.shift_pressed or mb.ctrl_pressed or mb.alt_pressed:
				return PASS
			var face: Dictionary = _pick(camera, mb.position)
			if face.is_empty():
				return PASS
			_begin(face, mb.position)
			return STOP
		if not _drag.is_empty():
			_finish()
			return STOP
	return PASS

# --- picking ---------------------------------------------------------------------

## Closest face of a selected supported primitive under `pos`.
func _pick(camera: Camera3D, pos: Vector2) -> Dictionary:
	if camera == null:
		return {}
	var rp: Vector2 = manager.ray_pos(pos)
	var origin: Vector3 = camera.project_ray_origin(rp)
	var dir: Vector3 = camera.project_ray_normal(rp)
	var best: Dictionary = {}
	var best_t: float = INF
	for n: Node in EditorInterface.get_selection().get_selected_nodes():
		if not supports(n) or not (n as Node3D).is_visible_in_tree():
			continue
		var node: Node3D = n as Node3D
		var inv: Transform3D = node.global_transform.affine_inverse()
		var res: Dictionary = _intersect(node, inv * origin, inv.basis * dir)
		if res.is_empty():
			continue
		var world_point: Vector3 = node.global_transform * (res["point"] as Vector3)
		var t: float = origin.distance_to(world_point)
		if t < best_t:
			best_t = t
			best = {"node": node, "face": res["face"], "point": world_point}
	return best

## Local-space ray hit: {"point", "face"} where face is a push_faces() entry.
func _intersect(n: Node3D, o: Vector3, d: Vector3) -> Dictionary:
	if n is CSGCylinder3D:
		return _intersect_cylinder(n as CSGCylinder3D, o, d)
	var box: AABB = CsgBlockoutShapeInfo.local_aabb(n)
	var res: Dictionary = _intersect_aabb(box, o, d)
	if res.is_empty():
		return {}
	var axis: int = res["axis"]
	var side: int = res["side"]
	for f: Dictionary in CsgBlockoutShapeInfo.push_faces(n):
		if f["axis"] == axis and f["sign"] == side and not f["radial"]:
			return {"point": res["point"], "face": f}
	return {}

## Slab test; returns entry point and entry face (axis, side) or {}.
static func _intersect_aabb(box: AABB, o: Vector3, d: Vector3) -> Dictionary:
	var tmin: float = -INF
	var tmax: float = INF
	var axis: int = -1
	var side: int = 0
	for a: int in 3:
		var lo: float = box.position[a]
		var hi: float = box.end[a]
		if absf(d[a]) < 0.000001:
			if o[a] < lo or o[a] > hi:
				return {}
			continue
		var t1: float = (lo - o[a]) / d[a]
		var t2: float = (hi - o[a]) / d[a]
		var near: float = minf(t1, t2)
		var far: float = maxf(t1, t2)
		if near > tmin:
			tmin = near
			axis = a
			side = -1 if d[a] > 0.0 else 1
		tmax = minf(tmax, far)
	if axis < 0 or tmax < tmin or tmin < 0.0:
		return {}
	return {"point": o + d * tmin, "axis": axis, "side": side}

func _intersect_cylinder(c: CSGCylinder3D, o: Vector3, d: Vector3) -> Dictionary:
	var faces: Array[Dictionary] = CsgBlockoutShapeInfo.push_faces(c)
	var best_t: float = INF
	var best_face: Dictionary = {}
	var h: float = c.height * 0.5
	var r: float = c.radius
	if absf(d.y) > 0.000001:
		for cap: int in [1, -1]:
			var t: float = (h * cap - o.y) / d.y
			var p: Vector3 = o + d * t
			if t > 0.0 and Vector2(p.x, p.z).length() <= r and t < best_t:
				best_t = t
				best_face = faces[0] if cap > 0 else faces[1]
	var a: float = d.x * d.x + d.z * d.z
	if a > 0.000001:
		var b: float = 2.0 * (o.x * d.x + o.z * d.z)
		var cc: float = o.x * o.x + o.z * o.z - r * r
		var disc: float = b * b - 4.0 * a * cc
		if disc >= 0.0:
			var t: float = (-b - sqrt(disc)) / (2.0 * a)
			var p: Vector3 = o + d * t
			if t > 0.0 and absf(p.y) <= h and t < best_t:
				best_t = t
				best_face = faces[2]
	if best_face.is_empty():
		return {}
	return {"point": o + d * best_t, "face": best_face}

# --- dragging ----------------------------------------------------------------------

func _begin(hover: Dictionary, pos: Vector2) -> void:
	var node: Node3D = hover["node"]
	var face: Dictionary = hover["face"]
	var world_normal: Vector3 = (node.global_transform.basis * (face["normal"] as Vector3)).normalized()
	if face["radial"]:
		var radial: Vector3 = (hover["point"] as Vector3) - node.global_position
		radial = radial - node.global_transform.basis.y.normalized() * radial.dot(node.global_transform.basis.y.normalized())
		world_normal = radial.normalized() if radial.length() > 0.0001 else world_normal
	var props: Dictionary = {}
	for p: StringName in _props_for(node):
		props[p] = node.get(p)
	_press_pos = pos
	_drag = {
		"node": node,
		"face": face,
		"normal": world_normal,
		"start_point": hover["point"],
		"start_props": props,
		"start_xform": node.global_transform,
		"delta": 0.0,
		"moved": false,
	}
	_hover = hover

static func _props_for(n: Node3D) -> Array[StringName]:
	if n is CSGBox3D:
		return [&"size"]
	if n is CSGCylinder3D:
		return [&"height", &"radius"]
	if n is CSGStairs3D:
		return [&"total_height", &"total_depth", &"width"]
	return []

func _update_drag(camera: Camera3D, pos: Vector2, event: InputEvent) -> void:
	var rp: Vector2 = manager.ray_pos(pos)
	var o: Vector3 = camera.project_ray_origin(rp)
	var d: Vector3 = camera.project_ray_normal(rp)
	var n: Vector3 = _drag["normal"]
	var p0: Vector3 = _drag["start_point"]
	var w0: Vector3 = p0 - o
	var b: float = n.dot(d)
	var denom: float = 1.0 - b * b
	if denom < 0.0001:
		return
	var t: float = (b * d.dot(w0) - n.dot(w0)) / denom
	var grid: CsgBlockoutGrid = CsgBlockoutGrid.get_grid()
	var active: bool = grid.is_active(event)
	var delta: float = t
	if active:
		var axis_index: int = n.abs().max_axis_index()
		if absf(n[axis_index]) > 0.9999 and not _drag["face"]["radial"]:
			# World-aligned face: put the face itself on a grid line.
			var face_coord: float = _face_world_coord(axis_index)
			var target: float = snappedf(face_coord + t * signf(n[axis_index]), grid.size)
			delta = (target - face_coord) * signf(n[axis_index])
		else:
			delta = snappedf(t, grid.size)
	_drag["delta"] = _apply(delta)
	manager.refresh()

## World coordinate (along axis) of the dragged face at drag start.
func _face_world_coord(axis_index: int) -> float:
	var node: Node3D = _drag["node"]
	var xf: Transform3D = _drag["start_xform"]
	var face: Dictionary = _drag["face"]
	var center: Vector3 = face["center"]
	# Face centers in push_faces() reflect the current size; rebuild from start values.
	if node is CSGBox3D:
		var s: Vector3 = _drag["start_props"][&"size"]
		center = (face["normal"] as Vector3) * s[face["axis"]] * 0.5
	elif node is CSGCylinder3D:
		center = Vector3(0, float(_drag["start_props"][&"height"]) * 0.5 * float(face["sign"]), 0)
	return (xf * center)[axis_index]

## Applies a world-space push of `delta` meters (clamped so the shape never inverts).
## Returns the delta actually applied.
func _apply(delta: float) -> float:
	var node: Node3D = _drag["node"]
	var face: Dictionary = _drag["face"]
	var start: Dictionary = _drag["start_props"]
	var xf: Transform3D = _drag["start_xform"]
	var axis: int = face["axis"]
	var axis_scale: float = maxf(xf.basis[axis].length(), 0.0001)
	var axis_dir: Vector3 = xf.basis[axis].normalized()
	var applied: float = delta
	if node is CSGBox3D:
		var size: Vector3 = start[&"size"]
		var new_len: float = maxf(size[axis] + delta / axis_scale, MIN_EXTENT)
		applied = (new_len - size[axis]) * axis_scale
		size[axis] = new_len
		(node as CSGBox3D).size = size
		node.global_position = xf.origin + axis_dir * (float(face["sign"]) * applied * 0.5)
	elif node is CSGCylinder3D:
		var c: CSGCylinder3D = node as CSGCylinder3D
		if face["radial"]:
			var new_r: float = maxf(float(start[&"radius"]) + delta / axis_scale, MIN_EXTENT)
			applied = (new_r - float(start[&"radius"])) * axis_scale
			c.radius = new_r
		else:
			var y_scale: float = maxf(xf.basis.y.length(), 0.0001)
			var new_h: float = maxf(float(start[&"height"]) + delta / y_scale, MIN_EXTENT)
			applied = (new_h - float(start[&"height"])) * y_scale
			c.height = new_h
			node.global_position = xf.origin + xf.basis.y.normalized() * (float(face["sign"]) * applied * 0.5)
	elif node is CSGStairs3D:
		var s: CSGStairs3D = node as CSGStairs3D
		match int(face["id"]):
			3:
				var new_h: float = maxf(float(start[&"total_height"]) + delta / axis_scale, MIN_EXTENT)
				applied = (new_h - float(start[&"total_height"])) * axis_scale
				s.total_height = new_h
			1:
				var new_d: float = maxf(float(start[&"total_depth"]) + delta / axis_scale, MIN_EXTENT)
				applied = (new_d - float(start[&"total_depth"])) * axis_scale
				s.total_depth = new_d
			4, 5:
				var new_w: float = maxf(float(start[&"width"]) + delta / axis_scale, MIN_EXTENT)
				applied = (new_w - float(start[&"width"])) * axis_scale
				s.width = new_w
				if int(face["id"]) == 4:
					# Extrusion runs toward -Z from the origin: growing the +Z side moves the origin.
					node.global_position = xf.origin + axis_dir * applied
	return applied

func _finish() -> void:
	var node: Node3D = _drag["node"]
	if not _drag["moved"]:
		# Plain Shift+click: same as Godot's Shift+click on a selected node.
		EditorInterface.get_selection().remove_node(node)
		_drag = {}
		return
	var final_props: Dictionary = {}
	for p: StringName in _drag["start_props"]:
		final_props[p] = node.get(p)
	var final_pos: Vector3 = node.global_position
	# Restore, then record start -> final as a single undo step.
	for p: StringName in _drag["start_props"]:
		node.set(p, _drag["start_props"][p])
	node.global_transform = _drag["start_xform"]
	var action: CsgBlockoutSceneOps.Action = CsgBlockoutSceneOps.Action.new(CsgBlockoutI18n.t("PUSH_FACE_ACTION"))
	for p: StringName in final_props:
		if final_props[p] != _drag["start_props"][p]:
			action.set_property(node, p, final_props[p])
	if not final_pos.is_equal_approx(node.global_position):
		action.set_property(node, &"global_position", final_pos)
	action.commit()
	_drag = {}
	manager.refresh()

# --- overlay -------------------------------------------------------------------------

func draw_overlay(overlay: Control, camera: Camera3D) -> void:
	if camera == null:
		return
	var current: Dictionary = _drag if not _drag.is_empty() else _hover
	if current.is_empty() or not is_instance_valid(current.get("node")):
		return
	var node: Node3D = current["node"]
	var face: Dictionary = current["face"]
	var scale: float = EditorInterface.get_editor_scale()
	# Cyan, so it never blends with Godot's orange selection box.
	var color: Color = Color(0.3, 0.9, 1.0)
	var outline: PackedVector2Array = _face_outline(node, face, camera)
	if outline.size() >= 3:
		var fill: Color = color
		fill.a = 0.35
		if not Geometry2D.triangulate_polygon(outline).is_empty():
			overlay.draw_colored_polygon(outline, fill)
		var closed: PackedVector2Array = outline.duplicate()
		closed.append(outline[0])
		overlay.draw_polyline(closed, color, 3.0 * scale, true)
	if not _drag.is_empty() and _drag["moved"]:
		var font: Font = overlay.get_theme_font(&"font", &"Label")
		var world: Vector3 = (_drag["start_point"] as Vector3) + (_drag["normal"] as Vector3) * float(_drag["delta"])
		if not camera.is_position_behind(world):
			var size: Vector3 = CsgBlockoutShapeInfo.world_size(node)
			var text: String = "%+.2f m  ·  %s × %s × %s m" % [float(_drag["delta"]), CsgBlockoutDrawTool._fmt(size.x), CsgBlockoutDrawTool._fmt(size.y), CsgBlockoutDrawTool._fmt(size.z)]
			CsgBlockoutToolManager.draw_label(overlay, font, int(round(13 * scale)), camera.unproject_position(world) + Vector2(14, -14) * scale, text, true)

## Screen-space outline of a face (empty if any corner is behind the camera).
func _face_outline(node: Node3D, face: Dictionary, camera: Camera3D) -> PackedVector2Array:
	var pts3: PackedVector3Array = PackedVector3Array()
	var xf: Transform3D = node.global_transform
	if node is CSGCylinder3D:
		var c: CSGCylinder3D = node as CSGCylinder3D
		if face["radial"]:
			for i: int in 2:
				var y: float = c.height * 0.5 * (1.0 if i == 0 else -1.0)
				pts3.append(Vector3(-c.radius, y, 0))
				pts3.append(Vector3(c.radius, y, 0))
			pts3 = PackedVector3Array([pts3[0], pts3[1], pts3[3], pts3[2]])
		else:
			var y: float = c.height * 0.5 * float(face["sign"])
			for i: int in 24:
				var a: float = TAU * float(i) / 24.0
				pts3.append(Vector3(cos(a) * c.radius, y, sin(a) * c.radius))
	else:
		var box: AABB = CsgBlockoutShapeInfo.local_aabb(node)
		var corners: PackedVector3Array = CsgBlockoutShapeInfo.box_face_corners(box.size * 0.5, face["axis"], face["sign"])
		for p: Vector3 in corners:
			pts3.append(p + box.get_center())
	var out: PackedVector2Array = PackedVector2Array()
	for p: Vector3 in pts3:
		var w: Vector3 = xf * p
		if camera.is_position_behind(w):
			return PackedVector2Array()
		out.append(camera.unproject_position(w))
	return out
