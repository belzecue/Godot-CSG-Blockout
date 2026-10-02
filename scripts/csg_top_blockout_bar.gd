@tool
class_name CSGTopBlockoutBar extends Control

signal request_create_node(node_type: String)
signal add_ruler_requested()
## Generic action from the bar's buttons/menus, dispatched by the plugin.
signal action_requested(action_id: StringName)

const BASE_ICON_MAX_WIDTH: int = 16
const MORE_SNAP_TO_GRID: int = 0
const MORE_CHECK_JUMP: int = 1
const MORE_EXPORT_LEGEND: int = 2
const MORE_REPEATER_REFRESH: int = 3
const MORE_REPEATER_BAKE: int = 4
const MORE_EXPORT_MESHLIB: int = 5

var _rulers_visible: bool = true
var _grid_option: OptionButton
var _snap_button: Button
var _more_button: MenuButton
var _tool_buttons: Array[Button] = []
var _freeze_button: Button
var _dimensions_button: Button
var _tag_menu: PopupMenu

func _enter_tree() -> void:
	if not Engine.is_editor_hint():
		return
	if not is_in_group(&"csg_blockout_ui"):
		add_to_group(&"csg_blockout_ui")
	var sel: EditorSelection = EditorInterface.get_selection()
	if sel and not sel.selection_changed.is_connected(_on_selection_changed):
		sel.selection_changed.connect(_on_selection_changed)

	# Icon-only like Godot's own 3D toolbar, so everything fits on one row.
	var add_ruler_btn: Button = find_child("AddRuler", true, false) as Button
	if add_ruler_btn:
		add_ruler_btn.text = ""
		add_ruler_btn.set_meta("i18n_tooltip_key", "ADD_RULER_TOOLTIP")

	var toggle_rulers_btn: Button = find_child("ToggleRulers", true, false) as Button
	if toggle_rulers_btn:
		toggle_rulers_btn.text = ""
		toggle_rulers_btn.icon = editor_icon(&"GuiVisibilityVisible")
		toggle_rulers_btn.set_meta("i18n_tooltip_key", "TOGGLE_RULERS_TOOLTIP")

	# Repeater/Spreader actions live in the "⋯" menu: toolbar buttons that appear and
	# disappear with the selection would make the 3D toolbar re-wrap and the viewport jump.
	for legacy: String in ["RepeaterTools", "VSeparator"]:
		var c: Control = find_child(legacy, true, false) as Control
		if c:
			c.visible = false

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
	# Compact: the popup still lists every size; the button only shows the current one.
	_grid_option.fit_to_longest_item = false
	_grid_option.custom_minimum_size.x = round(64.0 * (EditorInterface.get_editor_scale() if Engine.is_editor_hint() else 1.0))
	for s: float in CsgBlockoutGrid.SIZES:
		var label: String = ("%d m" % int(s)) if s >= 1.0 else ("%s m" % String.num(s, 3))
		_grid_option.add_item(label)
	_grid_option.item_selected.connect(_on_grid_size_selected)
	box.add_child(_grid_option)

	_snap_button = Button.new()
	_snap_button.name = "SnapToggle"
	_snap_button.flat = true
	_snap_button.toggle_mode = true
	_snap_button.set_meta("i18n_tooltip_key", "SNAP_TOOLTIP")
	_snap_button.icon = editor_icon(&"SnapGrid")
	_snap_button.toggled.connect(_on_snap_toggled)
	box.add_child(_snap_button)

	_add_tool_button(box, &"draw_box", editor_icon(&"CSGBox3D"), "DRAW_BOX_TOOLTIP")
	_add_tool_button(box, &"draw_room", editor_icon(&"CSGCombiner3D"), "DRAW_ROOM_TOOLTIP")
	_add_tool_button(box, &"opening_door", load("res://addons/csg_blockout/res/icons/door.svg") as Texture2D, "OPENING_DOOR_TOOLTIP")
	_add_tool_button(box, &"opening_window", load("res://addons/csg_blockout/res/icons/window.svg") as Texture2D, "OPENING_WINDOW_TOOLTIP")

	_dimensions_button = Button.new()
	_dimensions_button.name = "DimensionsToggle"
	_dimensions_button.flat = true
	_dimensions_button.toggle_mode = true
	_dimensions_button.icon = editor_icon(&"Ruler")
	_dimensions_button.set_meta("i18n_tooltip_key", "DIMENSIONS_TOOLTIP")
	CsgBlockoutMeasureOverlay.load_state()
	_dimensions_button.button_pressed = CsgBlockoutMeasureOverlay.enabled
	_dimensions_button.toggled.connect(func(on: bool) -> void:
		CsgBlockoutMeasureOverlay.set_enabled(on)
		action_requested.emit(&"refresh_overlays"))
	box.add_child(_dimensions_button)
	_add_action_button(box, &"validate", editor_icon(&"StatusWarning"), "VALIDATE", "VALIDATE_TOOLTIP")
	_add_action_button(box, &"add_player_ref", editor_icon(&"CharacterBody3D"), "", "PLAYER_REF_TOOLTIP")

	_add_action_button(box, &"play_here", editor_icon(&"Play"), "", "PLAY_HERE_TOOLTIP")
	# One button whose icon follows the selection (freeze CSG / unfreeze frozen): its
	# width never changes, so the toolbar doesn't re-wrap.
	_freeze_button = _add_action_button(box, &"freeze_toggle", _freeze_icon(), "", "FREEZE_TOOLTIP")

	_more_button = MenuButton.new()
	_more_button.name = "MoreActions"
	_more_button.flat = true
	_more_button.text = "⋯"
	_more_button.set_meta("i18n_tooltip_key", "MORE_ACTIONS_TOOLTIP")
	_more_button.get_popup().id_pressed.connect(_on_more_id_pressed)
	_more_button.about_to_popup.connect(_update_more_menu_state)
	box.add_child(_more_button)
	_rebuild_more_menu()


## Icon toggle that asks the plugin to (de)activate viewport tool `tool_id`.
func _add_tool_button(parent: Control, tool_id: StringName, icon: Texture2D, tooltip_key: String) -> Button:
	var btn: Button = Button.new()
	btn.name = "Tool_" + String(tool_id)
	btn.flat = true
	btn.toggle_mode = true
	btn.icon = icon
	if btn.icon == null:
		btn.text = String(tool_id)
	btn.set_meta("i18n_tooltip_key", tooltip_key)
	btn.set_meta("tool_id", tool_id)
	btn.toggled.connect(func(_on: bool) -> void: action_requested.emit(tool_id))
	parent.add_child(btn)
	_tool_buttons.append(btn)
	return btn

## Plain (non-toggle) button that asks the plugin to run action `action_id`.
func _add_action_button(parent: Control, action_id: StringName, icon: Texture2D, text_key: String, tooltip_key: String) -> Button:
	var btn: Button = Button.new()
	btn.name = "Action_" + String(action_id)
	btn.flat = true
	btn.icon = icon
	btn.tooltip_text = CsgBlockoutI18n.t(tooltip_key)
	btn.set_meta("i18n_tooltip_key", tooltip_key)
	btn.pressed.connect(func() -> void: action_requested.emit(action_id))
	parent.add_child(btn)
	return btn

## Reflects the active viewport tool on the toggle buttons.
func set_active_tool(tool_id: StringName) -> void:
	for btn: Button in _tool_buttons:
		btn.set_pressed_no_signal(btn.get_meta("tool_id") == tool_id)

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
	popup.add_item(CsgBlockoutI18n.t("CHECK_JUMP_MENU"), MORE_CHECK_JUMP)
	popup.add_separator()
	if _tag_menu == null:
		_tag_menu = PopupMenu.new()
		_tag_menu.name = "TagMenu"
		_tag_menu.id_pressed.connect(_on_tag_id_pressed)
	_tag_menu.clear()
	for i: int in CsgBlockoutTags.TAGS.size():
		var tag: StringName = CsgBlockoutTags.TAGS[i]
		var swatch: GradientTexture2D = GradientTexture2D.new()
		swatch.width = 12
		swatch.height = 12
		swatch.gradient = Gradient.new()
		swatch.gradient.set_color(0, CsgBlockoutTags.COLORS[tag])
		swatch.gradient.set_color(1, CsgBlockoutTags.COLORS[tag])
		_tag_menu.add_icon_item(swatch, CsgBlockoutTags.label(tag), i)
	_tag_menu.add_separator()
	_tag_menu.add_item(CsgBlockoutI18n.t("TAG_CLEAR"), CsgBlockoutTags.TAGS.size())
	popup.add_submenu_node_item(CsgBlockoutI18n.t("TAG_MENU"), _tag_menu)
	popup.add_item(CsgBlockoutI18n.t("EXPORT_LEGEND"), MORE_EXPORT_LEGEND)
	popup.add_separator()
	popup.add_item(CsgBlockoutI18n.t("EXPORT_MESHLIB"), MORE_EXPORT_MESHLIB)
	popup.add_separator()
	popup.add_item("%s (Repeater/Spreader)" % CsgBlockoutI18n.t("REFRESH"), MORE_REPEATER_REFRESH)
	popup.add_item("%s (Repeater/Spreader)" % CsgBlockoutI18n.t("BAKE"), MORE_REPEATER_BAKE)

## Greys out entries that don't apply to the current selection.
func _update_more_menu_state() -> void:
	var popup: PopupMenu = _more_button.get_popup()
	var has_repeater: bool = EditorInterface.get_selection().get_selected_nodes().any(func(n: Node) -> bool: return n is CSGRepeater3D or n is CSGSpreader3D)
	for id: int in [MORE_REPEATER_REFRESH, MORE_REPEATER_BAKE]:
		var idx: int = popup.get_item_index(id)
		if idx >= 0:
			popup.set_item_disabled(idx, not has_repeater)
	var check_idx: int = popup.get_item_index(MORE_CHECK_JUMP)
	if check_idx >= 0:
		popup.set_item_disabled(check_idx, CsgBlockoutSelection.top_level_nodes().size() != 2)
	var meshlib_idx: int = popup.get_item_index(MORE_EXPORT_MESHLIB)
	if meshlib_idx >= 0:
		popup.set_item_disabled(meshlib_idx, CsgBlockoutMeshLibraryExport.selection_nodes().is_empty())

func _on_tag_id_pressed(id: int) -> void:
	var tag: StringName = CsgBlockoutTags.TAGS[id] if id < CsgBlockoutTags.TAGS.size() else &""
	CsgBlockoutTags.apply_to_selection(tag)

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
		MORE_CHECK_JUMP:
			CsgBlockoutMeasureOverlay.check_jump_between_selection()
		MORE_EXPORT_LEGEND:
			CsgBlockoutTags.export_legend_with_dialog()
		MORE_EXPORT_MESHLIB:
			CsgBlockoutMeshLibraryExport.export_selection_with_dialog()
		MORE_REPEATER_REFRESH:
			_on_refresh_pressed()
		MORE_REPEATER_BAKE:
			_on_bake_pressed()

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
	if _freeze_button == null:
		return
	var targets: Dictionary = CsgBlockoutFreeze.selection_targets()
	var can_unfreeze: bool = not (targets["frozen"] as Array).is_empty()
	var can_freeze: bool = not (targets["roots"] as Array).is_empty()
	_freeze_button.icon = _freeze_icon(can_unfreeze)
	_freeze_button.set_meta("i18n_tooltip_key", "UNFREEZE_TOOLTIP" if can_unfreeze else "FREEZE_TOOLTIP")
	_freeze_button.tooltip_text = CsgBlockoutI18n.t(_freeze_button.get_meta("i18n_tooltip_key"))
	_freeze_button.disabled = not (can_freeze or can_unfreeze)

static func _freeze_icon(unfreeze: bool = false) -> Texture2D:
	return load("res://addons/csg_blockout/res/icons/%s.svg" % ("unfreeze" if unfreeze else "freeze")) as Texture2D

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
