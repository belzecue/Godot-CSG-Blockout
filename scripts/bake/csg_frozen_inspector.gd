@tool
class_name CsgBlockoutFrozenInspector
extends EditorInspectorPlugin
## Inspector panel for frozen blockout: bake options (collision type, lightmap UV2,
## occluder, LODs), rebake in place, unfreeze.

const COLLISION_KEYS: Dictionary = {
	"auto": "COLLISION_AUTO",
	"none": "COLLISION_NONE",
	"trimesh": "COLLISION_TRIMESH",
	"primitives": "COLLISION_PRIMITIVES",
	"convex": "COLLISION_CONVEX",
}

func _can_handle(object: Object) -> bool:
	return object is MeshInstance3D and CsgBlockoutFreeze.is_frozen(object as Node)

func _parse_begin(object: Object) -> void:
	add_custom_control(_build_panel(object as MeshInstance3D))

static func _build_panel(frozen: MeshInstance3D) -> Control:
	var opts: Dictionary = CsgBlockoutBakePipeline.normalized(frozen.get_meta(CsgBlockoutFreeze.META_BAKE, {}))
	var panel: VBoxContainer = VBoxContainer.new()
	panel.name = "CsgBlockoutFrozenPanel"
	var title: Label = Label.new()
	title.text = CsgBlockoutI18n.t("FROZEN_PANEL_TITLE")
	title.add_theme_color_override(&"font_color", Color(0.55, 0.85, 1.0))
	panel.add_child(title)

	var grid: GridContainer = GridContainer.new()
	grid.columns = 2
	panel.add_child(grid)

	var collision: OptionButton = OptionButton.new()
	collision.name = "Collision"
	for mode: String in CsgBlockoutBakePipeline.COLLISION_MODES:
		collision.add_item(CsgBlockoutI18n.t(COLLISION_KEYS[mode]))
	collision.select(CsgBlockoutBakePipeline.COLLISION_MODES.find(String(opts["collision"])))
	collision.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_row(grid, "BAKE_COLLISION", collision)

	var uv2: CheckBox = CheckBox.new()
	uv2.name = "UV2"
	uv2.button_pressed = bool(opts["uv2"])
	_row(grid, "BAKE_UV2", uv2)

	var texel: SpinBox = SpinBox.new()
	texel.name = "Texel"
	texel.min_value = 0.01
	texel.max_value = 4.0
	texel.step = 0.01
	texel.value = float(opts["texel"])
	texel.suffix = "m"
	_row(grid, "BAKE_TEXEL", texel)

	var occluder: CheckBox = CheckBox.new()
	occluder.name = "Occluder"
	occluder.button_pressed = bool(opts["occluder"])
	_row(grid, "BAKE_OCCLUDER", occluder)

	var lod: CheckBox = CheckBox.new()
	lod.name = "LOD"
	lod.button_pressed = bool(opts["lod"])
	_row(grid, "BAKE_LOD", lod)

	var buttons: HBoxContainer = HBoxContainer.new()
	panel.add_child(buttons)
	var rebake: Button = Button.new()
	rebake.name = "Rebake"
	rebake.text = CsgBlockoutI18n.t("REBAKE")
	rebake.icon = load("res://addons/csg_blockout/res/icons/freeze.svg") as Texture2D
	rebake.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rebake.pressed.connect(func() -> void:
		var chosen: Dictionary = {
			"collision": CsgBlockoutBakePipeline.COLLISION_MODES[collision.selected],
			"uv2": uv2.button_pressed,
			"texel": texel.value,
			"occluder": occluder.button_pressed,
			"lod": lod.button_pressed,
		}
		CsgBlockoutFreeze.rebake([frozen], chosen))
	buttons.add_child(rebake)
	var unfreeze: Button = Button.new()
	unfreeze.name = "Unfreeze"
	unfreeze.text = CsgBlockoutI18n.t("UNFREEZE")
	unfreeze.icon = load("res://addons/csg_blockout/res/icons/unfreeze.svg") as Texture2D
	unfreeze.pressed.connect(func() -> void: CsgBlockoutFreeze.unfreeze([frozen]))
	buttons.add_child(unfreeze)
	panel.add_child(HSeparator.new())
	return panel

static func _row(grid: GridContainer, label_key: String, control: Control) -> void:
	var label: Label = Label.new()
	label.text = CsgBlockoutI18n.t(label_key)
	grid.add_child(label)
	grid.add_child(control)
