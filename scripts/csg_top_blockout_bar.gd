@tool
class_name CSGTopBlockoutBar extends Control

signal request_create_node(node_type: String)
signal add_ruler_requested()
## Generic action from the bar's buttons/menus, dispatched by the plugin.
signal action_requested(action_id: StringName)

const BASE_ICON_MAX_WIDTH: int = 16
const MORE_SNAP_TO_GRID: int = 0

var _rulers_visible: bool = true
var _grid_option: OptionButton
var _snap_button: Button
var _more_button: MenuButton

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		return
	if not is_in_group(&"csg_blockout_ui"):
		add_to_group(&"csg_blockout_ui")
	var sel: EditorSelection = EditorInterface.get_selection()
	if sel and not sel.selection_changed.is_connected(_on_selection_changed):
		sel.selection_changed.connect(_on_selection_changed)

	var add_ruler_btn: Button = find_child("AddRuler", true, false) as Button
	if add_ruler_btn:
		add_ruler_btn.set_meta("i18n_text_key", "ADD_RULER")
		add_ruler_btn.set_meta("i18n_tooltip_key", "ADD_RULER_TOOLTIP")

	var toggle_rulers_btn: Button = find_child("ToggleRulers", true, false) as Button
	if toggle_rulers_btn:
		toggle_rulers_btn.set_meta("i18n_text_key", "TOGGLE_RULERS")
		toggle_rulers_btn.set_meta("i18n_tooltip_key", "TOGGLE_RULERS_TOOLTIP")

	var refresh_btn: Button = find_child("Refresh", true, false) as Button
	if refresh_btn:
		refresh_btn.set_meta("i18n_text_key", "REFRESH")
		refresh_btn.set_meta("i18n_tooltip_key", "REGEN_PREVIEW_TOOLTIP")

	var bake_btn: Button = find_child("Bake", true, false) as Button
	if bake_btn:
		bake_btn.set_meta("i18n_text_key", "BAKE")
		bake_btn.set_meta("i18n_tooltip_key", "BAKE_INSTANCES_TOOLTIP")

	_build_blockout_tools()
	var grid: CsgBlockoutGrid = CsgBlockoutGrid.get_grid()
	if not grid.changed.is_connected(_sync_grid_controls):
		grid.changed.connect(_sync_grid_controls)

	_apply_editor_scale()
	CsgBlockoutI18n.translate_node(self)
	_sync_grid_controls()
	_on_selection_changed()

## Grid size, snap toggle and the "more" menu, placed before the ruler buttons.
func _build_blockout_tools() -> void:
	if find_child("BlockoutTools", false, false) != null:
		return
	var box: HBoxContainer = HBoxContainer.new()
	box.name = "BlockoutTools"
	add_child(box)
	move_child(box, 0)

	_grid_option = OptionButton.new()
	_grid_option.name = "GridSize"
	_grid_option.flat = true
	_grid_option.set_meta("i18n_tooltip_key", "GRID_SIZE_TOOLTIP")
	for s: float in CsgBlockoutGrid.SIZES:
		var label: String = ("%d m" % int(s)) if s >= 1.0 else ("%s m" % String.num(s, 3))
		_grid_option.add_item(label)
	_grid_option.item_selected.connect(_on_grid_size_selected)
	box.add_child(_grid_option)

	_snap_button = Button.new()
	_snap_button.name = "SnapToggle"
	_snap_button.flat = true
	_snap_button.toggle_mode = true
	_snap_button.text = "SNAP"
	_snap_button.set_meta("i18n_text_key", "SNAP")
	_snap_button.set_meta("i18n_tooltip_key", "SNAP_TOOLTIP")
	_snap_button.icon = editor_icon(&"SnapGrid")
	_snap_button.toggled.connect(_on_snap_toggled)
	box.add_child(_snap_button)

	_more_button = MenuButton.new()
	_more_button.name = "MoreActions"
	_more_button.flat = true
	_more_button.text = "⋯"
	_more_button.set_meta("i18n_tooltip_key", "MORE_ACTIONS_TOOLTIP")
	_more_button.get_popup().id_pressed.connect(_on_more_id_pressed)
	box.add_child(_more_button)
	_rebuild_more_menu()

	var sep: VSeparator = VSeparator.new()
	box.add_child(sep)

## Built-in editor icon by name, or null outside the editor.
static func editor_icon(icon_name: StringName) -> Texture2D:
	if not Engine.is_editor_hint():
		return null
	var theme: Theme = EditorInterface.get_editor_theme()
	if theme != null and theme.has_icon(icon_name, &"EditorIcons"):
		return theme.get_icon(icon_name, &"EditorIcons")
	return null

func _rebuild_more_menu() -> void:
	if _more_button == null:
		return
	var popup: PopupMenu = _more_button.get_popup()
	popup.clear()
	popup.add_item(CsgBlockoutI18n.t("SNAP_SELECTION_TO_GRID"), MORE_SNAP_TO_GRID)

func _sync_grid_controls() -> void:
	var grid: CsgBlockoutGrid = CsgBlockoutGrid.get_grid()
	if _grid_option != null:
		var idx: int = CsgBlockoutGrid.SIZES.find(grid.size)
		if idx >= 0 and _grid_option.selected != idx:
			_grid_option.select(idx)
	if _snap_button != null:
		_snap_button.set_pressed_no_signal(grid.snap_enabled)

func _on_grid_size_selected(index: int) -> void:
	CsgBlockoutGrid.get_grid().set_size(CsgBlockoutGrid.SIZES[index])

func _on_snap_toggled(pressed: bool) -> void:
	CsgBlockoutGrid.get_grid().set_snap_enabled(pressed)

func _on_more_id_pressed(id: int) -> void:
	match id:
		MORE_SNAP_TO_GRID:
			CsgBlockoutTransformHotkeys.snap_selection_to_grid()

func _apply_editor_scale() -> void:
	var ed_scale: float = 1.0
	if Engine.is_editor_hint():
		ed_scale = EditorInterface.get_editor_scale()
	ed_scale = maxf(ed_scale, 0.1)
	var add_ruler_btn: Button = find_child("AddRuler", true, false) as Button
	if add_ruler_btn:
		add_ruler_btn.add_theme_constant_override("icon_max_width", int(round(BASE_ICON_MAX_WIDTH * ed_scale)))

func update_language() -> void:
	CsgBlockoutI18n.translate_node(self)
	_rebuild_more_menu()

func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		return
	if is_in_group(&"csg_blockout_ui"):
		remove_from_group(&"csg_blockout_ui")
	var sel: EditorSelection = EditorInterface.get_selection()
	if sel and sel.selection_changed.is_connected(_on_selection_changed):
		sel.selection_changed.disconnect(_on_selection_changed)
	var grid: CsgBlockoutGrid = CsgBlockoutGrid.get_grid()
	if grid.changed.is_connected(_sync_grid_controls):
		grid.changed.disconnect(_sync_grid_controls)

func _on_selection_changed() -> void:
	if not Engine.is_editor_hint():
		return
	var sel: EditorSelection = EditorInterface.get_selection()
	var selection: Array[Node] = sel.get_selected_nodes() if sel != null else []
	var has_repeater: bool = selection.any(func(node: Node) -> bool: return node is CSGRepeater3D or node is CSGSpreader3D)

	var repeater_tools: Control = find_child("RepeaterTools", true, false) as Control
	if repeater_tools:
		repeater_tools.visible = has_repeater
	var vsep: Control = find_child("VSeparator", true, false) as Control
	if vsep:
		vsep.visible = has_repeater

func _on_add_ruler_pressed() -> void:
	if not _rulers_visible:
		var toggle_btn: Button = find_child("ToggleRulers", true, false) as Button
		if toggle_btn:
			toggle_btn.button_pressed = true
	add_ruler_requested.emit()
	request_create_node.emit("CSGRuler3D")

func _on_toggle_rulers_toggled(toggled_on: bool) -> void:
	_rulers_visible = toggled_on
	var tree: SceneTree = get_tree()
	if tree != null:
		tree.set_group(&"csg_rulers", &"visible", toggled_on)
		tree.call_group(&"csg_rulers", &"update_gizmos")

func _on_refresh_pressed() -> void:
	var sel: EditorSelection = EditorInterface.get_selection()
	if not sel:
		return
	var selection: Array[Node] = sel.get_selected_nodes()
	for node: Node in selection:
		if node is CSGRepeater3D:
			(node as CSGRepeater3D).repeat_template()
			break
		elif node is CSGSpreader3D:
			(node as CSGSpreader3D).spread_template()
			break

func _on_bake_pressed() -> void:
	var sel: EditorSelection = EditorInterface.get_selection()
	if not sel:
		return
	var selection: Array[Node] = sel.get_selected_nodes()
	for node: Node in selection:
		if node is CSGRepeater3D or node is CSGSpreader3D:
			if node.has_method(&"bake_instances"):
				node.call(&"bake_instances")
			break
