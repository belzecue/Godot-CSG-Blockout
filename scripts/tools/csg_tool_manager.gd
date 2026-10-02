@tool
class_name CsgBlockoutToolManager
extends RefCounted
## Routes 3D viewport input to the active modal tool, then to passive tools, and
## draws the shared HUD (grid badge, tool hint) on the viewport overlay.

signal active_tool_changed(tool_id: StringName)

const PASS: int = EditorPlugin.AFTER_GUI_INPUT_PASS
const STOP: int = EditorPlugin.AFTER_GUI_INPUT_STOP
const RMB_CLICK_SLOP: float = 4.0
const BASE_FONT_SIZE: int = 13
const BASE_PADDING: float = 6.0

var plugin: EditorPlugin
var active: CsgBlockoutTool
var passives: Array[CsgBlockoutTool] = []
var _modal_tools: Dictionary = {}
## Camera and mouse position of the viewport that received the last event.
var camera: Camera3D
var mouse_pos: Vector2 = Vector2.ZERO
var has_mouse: bool = false

var _rmb_down_pos: Vector2 = Vector2.ZERO
var _rmb_moved: bool = false

func _init(p_plugin: EditorPlugin) -> void:
	plugin = p_plugin

func add_passive(tool: CsgBlockoutTool) -> void:
	tool.manager = self
	passives.append(tool)

## Registers a modal tool so passive tools (hotkeys) can start it by id.
func register_tool(tool_id: StringName, tool: CsgBlockoutTool) -> void:
	tool.manager = self
	_modal_tools[tool_id] = tool

func get_tool(tool_id: StringName) -> CsgBlockoutTool:
	return _modal_tools.get(tool_id)

func activate(tool: CsgBlockoutTool) -> void:
	if active == tool:
		return
	if active != null:
		var previous: CsgBlockoutTool = active
		active = null
		previous.deactivate()
	tool.manager = self
	active = tool
	tool.activate()
	active_tool_changed.emit(tool.get_id())
	refresh()

func deactivate(tool: CsgBlockoutTool = null) -> void:
	if active == null or (tool != null and tool != active):
		return
	var previous: CsgBlockoutTool = active
	active = null
	previous.deactivate()
	active_tool_changed.emit(&"")
	refresh()

func is_active(tool_id: StringName) -> bool:
	return active != null and active.get_id() == tool_id

func refresh() -> void:
	if plugin != null:
		plugin.update_overlays()

## Converts an event position to the SubViewport pixel space used by camera rays
## (differs when the viewport renders at half resolution).
func ray_pos(pos: Vector2) -> Vector2:
	if camera == null:
		return pos
	var container: SubViewportContainer = camera.get_viewport().get_parent() as SubViewportContainer
	if container != null and container.stretch_shrink > 1:
		return pos / float(container.stretch_shrink)
	return pos

## Position of a viewport-local point in the editor's root window.
func to_global(pos: Vector2) -> Vector2:
	if camera == null:
		return pos
	var container: Control = camera.get_viewport().get_parent() as Control
	return container.get_global_rect().position + pos if container != null else pos

func cast(pos: Vector2, exclude: Array = [], use_plane: bool = true, plane_height: float = 0.0) -> CsgBlockoutRaycast.Hit:
	if camera == null:
		return CsgBlockoutRaycast.Hit.new()
	return CsgBlockoutRaycast.cast(camera, ray_pos(pos), exclude, use_plane, plane_height)

func handle_input(cam: Camera3D, event: InputEvent) -> int:
	camera = cam
	if event is InputEventMouse:
		mouse_pos = (event as InputEventMouse).position
		has_mouse = true
	# Right mouse belongs to Godot's freelook; a click without movement cancels the tool.
	if event is InputEventMouseButton and (event as InputEventMouseButton).button_index == MOUSE_BUTTON_RIGHT:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.pressed:
			_rmb_down_pos = mb.position
			_rmb_moved = false
		elif not _rmb_moved and active != null:
			active.cancel()
			refresh()
		return PASS
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		if event is InputEventMouseMotion and (event as InputEventMouseMotion).position.distance_to(_rmb_down_pos) > RMB_CLICK_SLOP:
			_rmb_moved = true
		return PASS
	if active != null:
		if event is InputEventKey and event.is_pressed() and (event as InputEventKey).keycode == KEY_ESCAPE:
			active.cancel()
			refresh()
			return STOP
		var r: int = active.input(cam, event)
		if r != PASS:
			refresh()
			return r
	for tool: CsgBlockoutTool in passives:
		var r: int = tool.input(cam, event)
		if r != PASS:
			refresh()
			return r
	return PASS

func draw_overlay(overlay: Control) -> void:
	var cam: Camera3D = _camera_for_overlay(overlay)
	if cam == null:
		cam = camera
	for tool: CsgBlockoutTool in passives:
		tool.draw_overlay(overlay, cam)
	if active != null:
		active.draw_overlay(overlay, cam)
	_draw_hud(overlay)

## The editor overlay sits next to the SubViewportContainer that renders its camera.
func _camera_for_overlay(overlay: Control) -> Camera3D:
	var parent: Node = overlay.get_parent()
	if parent == null:
		return null
	for child: Node in parent.get_children():
		if child is SubViewportContainer:
			for sub: Node in child.get_children():
				if sub is SubViewport:
					return (sub as SubViewport).get_camera_3d()
	return null

func _show_grid_badge() -> bool:
	if active != null:
		return true
	for n: Node in EditorInterface.get_selection().get_selected_nodes():
		if n is CSGShape3D:
			return true
	return false

func _draw_hud(overlay: Control) -> void:
	var scale: float = EditorInterface.get_editor_scale()
	var font: Font = overlay.get_theme_font(&"font", &"Label")
	var font_size: int = int(round(BASE_FONT_SIZE * scale))
	var pad: float = BASE_PADDING * scale
	if _show_grid_badge():
		var grid: CsgBlockoutGrid = CsgBlockoutGrid.get_grid()
		var text: String = CsgBlockoutI18n.tf("HUD_GRID", [grid.label()])
		if not grid.snap_enabled:
			text += " · " + CsgBlockoutI18n.t("HUD_SNAP_OFF")
		var pos: Vector2 = Vector2(pad * 2.0, overlay.size.y - pad * 2.0)
		draw_label(overlay, font, font_size, pos, text, false)
	if active != null:
		var hint: String = active.hint()
		if not hint.is_empty():
			var size: Vector2 = font.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
			var pos: Vector2 = Vector2((overlay.size.x - size.x) * 0.5, overlay.size.y - pad * 2.0)
			draw_label(overlay, font, font_size, pos, hint, true)

## Text with a dark rounded backdrop; `pos` is the left end of the baseline.
static func draw_label(overlay: Control, font: Font, font_size: int, pos: Vector2, text: String, accent: bool = false) -> Rect2:
	var scale: float = EditorInterface.get_editor_scale()
	var pad: Vector2 = Vector2(6.0, 3.0) * scale
	var size: Vector2 = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var rect: Rect2 = Rect2(pos + Vector2(-pad.x, -font.get_ascent(font_size) - pad.y), size + pad * 2.0)
	var bg: Color = Color(0.08, 0.1, 0.14, 0.82) if not accent else Color(0.12, 0.2, 0.34, 0.9)
	overlay.draw_rect(rect, bg, true)
	overlay.draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.95, 0.96, 1.0))
	return rect
