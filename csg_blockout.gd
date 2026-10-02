@tool
class_name CsgBlockout extends EditorPlugin
var config: CsgBlockoutConfig:
	get: return CsgBlockoutConfig.get_config()

var sidebar: CSGSideBlockoutBar
var topbar: CSGTopBlockoutBar
var ruler_gizmo_plugin: CSGRulerGizmoPlugin
var tools: CsgBlockoutToolManager

static var csg_plugin_path: String
static var undo_manager: EditorUndoRedoManager

var pie_menu: CsgPieMenu
var pie_menu_tab_pressed_time: int = 0
# Viewport camera and cursor position where the pie menu was opened; new shapes
# are placed on the surface under that point.
var _pie_camera: Camera3D
var _pie_screen_pos: Vector2 = Vector2.ZERO

func _get_shape_menu() -> Array[Dictionary]:
	return [
		{"label": CsgBlockoutI18n.t("BOX"), "type": "create_csg", "csg_type": "CSGBox3D"},
		{"label": CsgBlockoutI18n.t("CYLINDER"), "type": "create_csg", "csg_type": "CSGCylinder3D"},
		{"label": CsgBlockoutI18n.t("MESH"), "type": "create_csg", "csg_type": "CSGMesh3D"},
		{"label": CsgBlockoutI18n.t("POLYGON"), "type": "create_csg", "csg_type": "CSGPolygon3D"},
		{"label": CsgBlockoutI18n.t("SPHERE"), "type": "create_csg", "csg_type": "CSGSphere3D"},
		{"label": CsgBlockoutI18n.t("TORUS"), "type": "create_csg", "csg_type": "CSGTorus3D"},
		{"label": CsgBlockoutI18n.t("STAIRS"), "type": "create_csg", "csg_type": "CSGStairs3D"}
	]

func _get_pie_menu_items() -> Array[Dictionary]:
	return [
		{
			"label": CsgBlockoutI18n.t("UNION"), "type": "submenu",
			"operation": 0,
			"children": _get_shape_menu()
		},
		{
			"label": CsgBlockoutI18n.t("INTERSECTION"), "type": "submenu",
			"operation": 1,
			"children": _get_shape_menu()
		},
		{
			"label": CsgBlockoutI18n.t("SUBTRACTION"), "type": "submenu",
			"operation": 2,
			"children": _get_shape_menu()
		}
	]

func _enter_tree() -> void:
	csg_plugin_path = get_script().get_path().get_base_dir()
	undo_manager = get_undo_redo()

	# Custom Nodes
	add_custom_type("CSGRepeater3D", "CSGCombiner3D", preload("res://addons/csg_blockout/scripts/csg_repeater_3d.gd"), null)
	add_custom_type("CSGSpreader3D", "CSGCombiner3D", preload("res://addons/csg_blockout/scripts/csg_spreader_3d.gd"), null)
	add_custom_type("CSGStairs3D", "CSGPolygon3D", preload("res://addons/csg_blockout/scripts/csg_stairs_3d.gd"), preload("res://addons/csg_blockout/res/icons/stairs.svg"))
	add_custom_type("CSGRuler3D", "Node3D", preload("res://addons/csg_blockout/scripts/csg_ruler_3d.gd"), preload("res://addons/csg_blockout/res/icons/ruler.svg"))

	# Gizmo Plugin
	ruler_gizmo_plugin = CSGRulerGizmoPlugin.new()
	add_node_3d_gizmo_plugin(ruler_gizmo_plugin)

	# Sidebar
	var sidebar_scene: PackedScene = preload("res://addons/csg_blockout/scenes/csg_side_blockout_bar.tscn")
	sidebar = sidebar_scene.instantiate() as CSGSideBlockoutBar
	sidebar.request_create_node.connect(_on_create_requested)
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_LEFT, sidebar)

	# Topbar
	var topbar_scene: PackedScene = preload("res://addons/csg_blockout/scenes/csg_top_blockout_bar.tscn")
	topbar = topbar_scene.instantiate() as CSGTopBlockoutBar
	topbar.request_create_node.connect(_on_create_requested)
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, topbar)

	# Viewport tools: input is forwarded even with nothing selected, and the HUD is
	# drawn over every 3D viewport.
	CsgBlockoutShortcuts.register_all()
	tools = CsgBlockoutToolManager.new(self)
	tools.add_passive(CsgBlockoutTransformHotkeys.new())
	set_input_event_forwarding_always_enabled()
	set_force_draw_over_forwarding_enabled()
	var grid: CsgBlockoutGrid = CsgBlockoutGrid.get_grid()
	if not grid.changed.is_connected(update_overlays):
		grid.changed.connect(update_overlays)
	var selection: EditorSelection = EditorInterface.get_selection()
	if not selection.selection_changed.is_connected(_on_selection_changed):
		selection.selection_changed.connect(_on_selection_changed)

func _handles(object: Object) -> bool:
	return object is Node3D

func _on_selection_changed() -> void:
	update_overlays()

func _forward_3d_gui_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	var result: int = _pie_menu_input(viewport_camera, event)
	if result != EditorPlugin.AFTER_GUI_INPUT_PASS:
		return result
	return tools.handle_input(viewport_camera, event)

func _forward_3d_force_draw_over_viewport(viewport_control: Control) -> void:
	if tools != null:
		tools.draw_overlay(viewport_control)

func _pie_menu_input(viewport_camera: Camera3D, event: InputEvent) -> int:
	if event is InputEventMouse:
		tools.camera = viewport_camera
		tools.mouse_pos = (event as InputEventMouse).position
		tools.has_mouse = true
	if event is InputEventKey and event.keycode == KEY_A and not event.echo and _is_action_key_held(event):
		if event.pressed:
			if not is_instance_valid(pie_menu):
				# Prevent menu from opening during viewport fly navigation
				if not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
					_open_pie_menu(viewport_camera)
				else:
					return EditorPlugin.AFTER_GUI_INPUT_PASS
			return EditorPlugin.AFTER_GUI_INPUT_STOP
		else:
			if is_instance_valid(pie_menu):
				if Time.get_ticks_msec() - pie_menu_tab_pressed_time > 200:
					# Hold mode release
					pie_menu.execute_active_item(true)
				return EditorPlugin.AFTER_GUI_INPUT_STOP

	if is_instance_valid(pie_menu):
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
				pie_menu.execute_active_item(true)
				return EditorPlugin.AFTER_GUI_INPUT_STOP
			elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				pie_menu.execute_back()
				return EditorPlugin.AFTER_GUI_INPUT_STOP
			return EditorPlugin.AFTER_GUI_INPUT_STOP

		if event is InputEventMouseMotion:
			pie_menu.set_pointer_global(tools.to_global((event as InputEventMouseMotion).position))
			return EditorPlugin.AFTER_GUI_INPUT_STOP

	return EditorPlugin.AFTER_GUI_INPUT_PASS

func _is_action_key_held(event: InputEventWithModifiers) -> bool:
	var key: Key = config.action_key if config else KEY_SHIFT
	return (key == KEY_SHIFT and event.shift_pressed) \
		or (key == KEY_CTRL and event.ctrl_pressed) \
		or (key == KEY_ALT and event.alt_pressed) \
		or (key == KEY_META and event.meta_pressed)

func _open_pie_menu(viewport_camera: Camera3D) -> void:
	pie_menu = CsgPieMenu.new()
	pie_menu.action_triggered.connect(_on_pie_menu_action_triggered)
	pie_menu.close_requested.connect(_close_pie_menu)

	var ed_scale: float = EditorInterface.get_editor_scale() if Engine.is_editor_hint() else 1.0
	pie_menu.apply_editor_scale(ed_scale)

	var base_control: Control = EditorInterface.get_base_control()
	base_control.add_child(pie_menu)

	_pie_camera = viewport_camera
	_pie_screen_pos = tools.mouse_pos
	var global_pos: Vector2 = tools.to_global(tools.mouse_pos) if tools.has_mouse else base_control.get_global_mouse_position()
	var mouse_pos: Vector2 = base_control.get_global_transform().affine_inverse() * global_pos

	# Clamp position
	var margin: float = pie_menu.outer_radius + 10.0 * ed_scale
	var rect_size: Vector2 = base_control.get_rect().size
	mouse_pos.x = clampf(mouse_pos.x, margin, rect_size.x - margin)
	mouse_pos.y = clampf(mouse_pos.y, margin, rect_size.y - margin)

	pie_menu.position = mouse_pos
	pie_menu.set_pointer_global(global_pos)
	pie_menu.setup(_get_pie_menu_items(), ed_scale)
	pie_menu_tab_pressed_time = Time.get_ticks_msec()

func _close_pie_menu() -> void:
	if is_instance_valid(pie_menu):
		if pie_menu.action_triggered.is_connected(_on_pie_menu_action_triggered):
			pie_menu.action_triggered.disconnect(_on_pie_menu_action_triggered)
		if pie_menu.close_requested.is_connected(_close_pie_menu):
			pie_menu.close_requested.disconnect(_close_pie_menu)
		pie_menu.queue_free()
		pie_menu = null

func _on_pie_menu_action_triggered(item: Dictionary) -> void:
	var action_type: String = item.get("type", "")

	if action_type == "submenu" and item.has("operation"):
		var op: CSGShape3D.Operation = item.get("operation") as CSGShape3D.Operation
		if config:
			config.default_operation = op
		CsgBlockoutNodeFactory.set_operation_on_selection(op)

	elif action_type == "create_csg":
		var csg_type: String = item.get("csg_type", "")
		if not csg_type.is_empty():
			var hit: CsgBlockoutRaycast.Hit = null
			if is_instance_valid(_pie_camera):
				tools.camera = _pie_camera
				hit = tools.cast(_pie_screen_pos)
			CsgBlockoutNodeFactory.create(csg_type, hit)

func _on_create_requested(csg_type: String) -> void:
	CsgBlockoutNodeFactory.create(csg_type)

func _exit_tree() -> void:
	if tools != null:
		tools.deactivate()
		tools = null
	var grid: CsgBlockoutGrid = CsgBlockoutGrid.get_grid()
	if grid.changed.is_connected(update_overlays):
		grid.changed.disconnect(update_overlays)
	var selection: EditorSelection = EditorInterface.get_selection()
	if selection.selection_changed.is_connected(_on_selection_changed):
		selection.selection_changed.disconnect(_on_selection_changed)
	CsgBlockoutRaycast.clear_cache()

	if ruler_gizmo_plugin != null:
		remove_node_3d_gizmo_plugin(ruler_gizmo_plugin)
		ruler_gizmo_plugin = null

	remove_custom_type("CSGRepeater3D")
	remove_custom_type("CSGSpreader3D")
	remove_custom_type("CSGStairs3D")
	remove_custom_type("CSGRuler3D")
	undo_manager = null

	_close_pie_menu()

	if sidebar and is_instance_valid(sidebar):
		if sidebar.request_create_node.is_connected(_on_create_requested):
			sidebar.request_create_node.disconnect(_on_create_requested)
		remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_SIDE_LEFT, sidebar)
		sidebar.queue_free()
		sidebar = null
	if topbar and is_instance_valid(topbar):
		if topbar.request_create_node.is_connected(_on_create_requested):
			topbar.request_create_node.disconnect(_on_create_requested)
		remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, topbar)
		topbar.queue_free()
		topbar = null
