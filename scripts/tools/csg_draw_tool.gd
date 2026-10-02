@tool
class_name CsgBlockoutDrawTool
extends CsgBlockoutTool
## Draw a box (or a room) straight in the viewport: drag a rectangle on any surface
## or the ground, release, move the mouse to set the height, click to confirm.
## The current default operation applies, so Subtraction mode is the cut tool: the
## box extrudes into the surface and lands in the combiner that owns it.

enum Mode { BOX, ROOM }
enum State { IDLE, BASE, HEIGHT }

const BASE_PREVIEW_THICKNESS: float = 0.02
## Cutters reach this far past the surface they start on, avoiding coplanar faces.
const CUT_EPSILON: float = 0.01

var mode: Mode = Mode.BOX
var state: State = State.IDLE

var _hover: CsgBlockoutRaycast.Hit
var _start_hit: CsgBlockoutRaycast.Hit
var _origin: Vector3 = Vector3.ZERO
var _basis: Basis = Basis.IDENTITY
var _u: Vector2 = Vector2.ZERO # rectangle extent along _basis.x (min, max)
var _v: Vector2 = Vector2.ZERO # rectangle extent along _basis.z (min, max)
var _height: float = 0.0
var _last_height: float = 0.0
var _ghost: CsgBlockoutGhost = CsgBlockoutGhost.new()

func get_id() -> StringName:
	return &"draw_room" if mode == Mode.ROOM else &"draw_box"

func activate() -> void:
	state = State.IDLE

func deactivate() -> void:
	state = State.IDLE
	_ghost.clear()
	_hover = null

func cancel() -> void:
	if state != State.IDLE:
		state = State.IDLE
		_ghost.clear()
	else:
		manager.deactivate(self)

func _op() -> CSGShape3D.Operation:
	if mode == Mode.ROOM:
		return CSGShape3D.OPERATION_UNION
	var config: CsgBlockoutConfig = CsgBlockoutConfig.get_config()
	return config.default_operation if config else CSGShape3D.OPERATION_UNION

func _is_cut() -> bool:
	return _op() == CSGShape3D.OPERATION_SUBTRACTION

func input(camera: Camera3D, event: InputEvent) -> int:
	if event is InputEventMouseMotion:
		var mm: InputEventMouseMotion = event as InputEventMouseMotion
		match state:
			State.IDLE:
				_hover = manager.cast(mm.position)
				manager.refresh()
				return PASS
			State.BASE:
				_update_base(camera, mm.position, mm)
				return STOP
			State.HEIGHT:
				_update_height(camera, mm.position, mm)
				return STOP
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.button_index != MOUSE_BUTTON_LEFT:
			return PASS
		if mb.pressed:
			match state:
				State.IDLE:
					return _begin(camera, mb.position)
				State.HEIGHT:
					_commit()
					return STOP
		else:
			if state == State.BASE:
				if _u.y - _u.x < 0.0001 or _v.y - _v.x < 0.0001:
					state = State.IDLE
					_ghost.clear()
				else:
					state = State.HEIGHT
					_height = _last_height if not is_zero_approx(_last_height) else _default_height()
					if _is_cut():
						_height = -absf(_height)
					_show_ghost()
				return STOP
			return STOP if state != State.IDLE else PASS
	return PASS

func _default_height() -> float:
	var grid: CsgBlockoutGrid = CsgBlockoutGrid.get_grid()
	return grid.size * (2.0 if mode == Mode.BOX else 3.0)

func _begin(_camera: Camera3D, pos: Vector2) -> int:
	var hit: CsgBlockoutRaycast.Hit = manager.cast(pos)
	if not hit.is_valid():
		return STOP
	var grid: CsgBlockoutGrid = CsgBlockoutGrid.get_grid()
	_start_hit = hit
	_basis = CsgBlockoutNodeFactory.basis_from_normal(hit.normal)
	_origin = grid.snap_in_plane(hit.position, Vector3.ZERO, _basis, grid.snap_enabled)
	_u = Vector2.ZERO
	_v = Vector2.ZERO
	state = State.BASE
	_show_ghost()
	return STOP

## Point on the drawing plane under the cursor, snapped, as plane (u, v).
func _plane_uv(camera: Camera3D, pos: Vector2, event: InputEvent) -> Variant:
	var rp: Vector2 = manager.ray_pos(pos)
	var plane: Plane = Plane(_basis.y, _origin)
	var p: Variant = plane.intersects_ray(camera.project_ray_origin(rp), camera.project_ray_normal(rp))
	if not (p is Vector3):
		return null
	var grid: CsgBlockoutGrid = CsgBlockoutGrid.get_grid()
	var active: bool = grid.is_active(event)
	var rel: Vector3 = (p as Vector3) - _origin
	return Vector2(grid.snap_value(rel.dot(_basis.x), active), grid.snap_value(rel.dot(_basis.z), active))

func _update_base(camera: Camera3D, pos: Vector2, event: InputEvent) -> void:
	var uv: Variant = _plane_uv(camera, pos, event)
	if uv == null:
		return
	var c: Vector2 = uv
	_u = Vector2(minf(0.0, c.x), maxf(0.0, c.x))
	_v = Vector2(minf(0.0, c.y), maxf(0.0, c.y))
	_show_ghost()

func _update_height(camera: Camera3D, pos: Vector2, event: InputEvent) -> void:
	var rp: Vector2 = manager.ray_pos(pos)
	var o: Vector3 = camera.project_ray_origin(rp)
	var d: Vector3 = camera.project_ray_normal(rp)
	var center: Vector3 = _rect_center()
	var n: Vector3 = _basis.y
	# Closest point between the extrusion axis and the mouse ray.
	var w0: Vector3 = center - o
	var b: float = n.dot(d)
	var denom: float = 1.0 - b * b
	if denom < 0.0001:
		return
	var t: float = (b * d.dot(w0) - n.dot(w0)) / denom
	var grid: CsgBlockoutGrid = CsgBlockoutGrid.get_grid()
	var h: float = grid.snap_value(t, grid.is_active(event))
	if is_zero_approx(h):
		h = grid.size * (-1.0 if _is_cut() else 1.0)
	_height = h
	_show_ghost()

func _rect_center() -> Vector3:
	return _origin + _basis.x * ((_u.x + _u.y) * 0.5) + _basis.z * ((_v.x + _v.y) * 0.5)

func _footprint() -> Vector2:
	return Vector2(_u.y - _u.x, _v.y - _v.x)

## Final box in world space: {"xform": Transform3D (basis unscaled), "size": Vector3}.
func _box() -> Dictionary:
	var fp: Vector2 = _footprint()
	var h: float = _height if state == State.HEIGHT else BASE_PREVIEW_THICKNESS
	var size: Vector3 = Vector3(fp.x, absf(h), fp.y)
	var center: Vector3 = _rect_center() + _basis.y * (h * 0.5)
	if state == State.HEIGHT and _is_cut() and h < 0.0:
		# Reach slightly out of the surface the cut starts on.
		size.y += CUT_EPSILON
		center += _basis.y * (CUT_EPSILON * 0.5)
	return {"xform": Transform3D(_basis, center), "size": size}

func _show_ghost() -> void:
	var box: Dictionary = _box()
	var xf: Transform3D = box["xform"]
	var scaled: Transform3D = Transform3D(xf.basis.scaled_local(box["size"]), xf.origin)
	var style: CsgBlockoutGhost.Style = CsgBlockoutGhost.Style.SUBTRACT if _is_cut() else CsgBlockoutGhost.Style.UNION
	var boxes: Array[Transform3D] = [scaled]
	if mode == Mode.ROOM and state == State.HEIGHT:
		var inner: Dictionary = _room_inner(box["size"])
		boxes.append(Transform3D(xf.basis.scaled_local(inner["size"]), xf * (inner["offset"] as Vector3)))
	_ghost.show_boxes(boxes, style)
	manager.refresh()

## Hollow part of a room, relative to the room center: {"size", "offset"}.
func _room_inner(outer: Vector3) -> Dictionary:
	var config: CsgBlockoutConfig = CsgBlockoutConfig.get_config()
	var wall: float = config.get_room_wall_thickness()
	var floor_t: float = config.get_room_floor_thickness()
	var open_top: bool = config.get_room_open_top()
	var inner: Vector3 = Vector3(maxf(outer.x - wall * 2.0, 0.01), 0.0, maxf(outer.z - wall * 2.0, 0.01))
	var bottom: float = -outer.y * 0.5 + floor_t
	var top: float = outer.y * 0.5 + (CUT_EPSILON if open_top else -floor_t)
	inner.y = maxf(top - bottom, 0.01)
	return {"size": inner, "offset": Vector3(0.0, (bottom + top) * 0.5, 0.0)}

func _commit() -> void:
	var box: Dictionary = _box()
	var xf: Transform3D = box["xform"]
	var size: Vector3 = box["size"]
	_last_height = _height
	var op: CSGShape3D.Operation = _op()
	var target: Dictionary = CsgBlockoutNodeFactory.parent_for_hit(_start_hit, op)
	var action: CsgBlockoutSceneOps.Action = CsgBlockoutSceneOps.Action.new(
		CsgBlockoutI18n.tf("CREATE_NODE", [CsgBlockoutI18n.t("ROOM" if mode == Mode.ROOM else "BOX")]))
	var parent: Node = target["parent"]
	if target["wrap"] != null:
		parent = CsgBlockoutNodeFactory.wrap_in_combiner(action, target["wrap"])
	var config: CsgBlockoutConfig = CsgBlockoutConfig.get_config()
	var material: Material = config.get_active_material() if config else null
	var created: Node3D
	if mode == Mode.ROOM:
		var room: CSGCombiner3D = CSGCombiner3D.new()
		room.name = CsgBlockoutSceneOps.unique_child_name(parent, "Room")
		var shell: CSGBox3D = CSGBox3D.new()
		shell.name = "Shell"
		shell.size = size
		shell.material = material
		room.add_child(shell)
		var inner: Dictionary = _room_inner(size)
		var hollow: CSGBox3D = CSGBox3D.new()
		hollow.name = "Hollow"
		hollow.operation = CSGShape3D.OPERATION_SUBTRACTION
		hollow.size = inner["size"]
		hollow.position = inner["offset"]
		hollow.material = material
		room.add_child(hollow)
		created = room
	else:
		var shape: CSGBox3D = CSGBox3D.new()
		shape.size = size
		shape.operation = op
		shape.material = material
		shape.name = CsgBlockoutSceneOps.unique_child_name(parent, _box_name(size, op))
		created = shape
	action.add_node(parent, created, target["index"], xf)
	action.select([created])
	action.commit()
	state = State.IDLE
	_ghost.clear()

## Readable default name from the box proportions (refined by the outliner later).
func _box_name(size: Vector3, op: CSGShape3D.Operation) -> String:
	if op == CSGShape3D.OPERATION_SUBTRACTION:
		return "Cut"
	var flat: bool = size.y <= 0.5 and size.y < minf(size.x, size.z) * 0.5
	if flat and _basis.y.dot(Vector3.UP) > 0.7:
		return "Floor"
	var thin: float = minf(size.x, size.z)
	if thin <= 0.5 and size.y >= 1.5:
		return "Wall"
	return "Block"

func draw_overlay(overlay: Control, camera: Camera3D) -> void:
	if camera == null:
		return
	var scale: float = EditorInterface.get_editor_scale()
	var font: Font = overlay.get_theme_font(&"font", &"Label")
	var font_size: int = int(round(13 * scale))
	if state == State.IDLE:
		if _hover != null and _hover.is_valid() and not camera.is_position_behind(_hover.position):
			var grid: CsgBlockoutGrid = CsgBlockoutGrid.get_grid()
			var b: Basis = CsgBlockoutNodeFactory.basis_from_normal(_hover.normal)
			var p: Vector3 = grid.snap_in_plane(_hover.position, Vector3.ZERO, b, grid.snap_enabled)
			var sp: Vector2 = camera.unproject_position(p)
			var color: Color = Color(1.0, 0.45, 0.4) if _is_cut() else Color(0.55, 0.8, 1.0)
			overlay.draw_arc(sp, 6.0 * scale, 0.0, TAU, 24, color, 2.0 * scale, true)
			overlay.draw_line(sp - Vector2(10, 0) * scale, sp + Vector2(10, 0) * scale, color, 1.0 * scale)
			overlay.draw_line(sp - Vector2(0, 10) * scale, sp + Vector2(0, 10) * scale, color, 1.0 * scale)
		return
	var box: Dictionary = _box()
	var center: Vector3 = (box["xform"] as Transform3D).origin
	if camera.is_position_behind(center):
		return
	var fp: Vector2 = _footprint()
	var text: String = "%s × %s m" % [_fmt(fp.x), _fmt(fp.y)]
	if state == State.HEIGHT:
		text = "%s × %s × %s m" % [_fmt(fp.x), _fmt(fp.y), _fmt(absf(_height))]
	CsgBlockoutToolManager.draw_label(overlay, font, font_size, camera.unproject_position(center) + Vector2(12, -12) * scale, text, true)

static func _fmt(v: float) -> String:
	return String.num(v, 2).trim_suffix(".00") if absf(v - roundf(v)) < 0.005 else String.num(v, 2)

func hint() -> String:
	match state:
		State.IDLE:
			return CsgBlockoutI18n.t("HINT_DRAW_IDLE")
		State.BASE:
			return CsgBlockoutI18n.t("HINT_DRAW_BASE")
		_:
			return CsgBlockoutI18n.t("HINT_DRAW_HEIGHT")
