@tool
class_name CsgBlockoutStatus
extends RefCounted
## One line of feedback at the top of the 3D viewport: what just happened, optionally
## with one clickable action ("Next ›"). Replaces info toasts, which pile up at the
## bottom of the editor where nobody is looking. Warnings and errors stay toasts.

const DEFAULT_SECONDS: float = 3.0

static var text: String = ""
static var warning: bool = false
static var action_label: String = ""
static var action: Callable = Callable()
static var _serial: int = 0

static func show(message: String, is_warning: bool = false, p_action_label: String = "", p_action: Callable = Callable(), seconds: float = DEFAULT_SECONDS) -> void:
	text = message
	warning = is_warning
	action_label = p_action_label
	action = p_action
	_serial += 1
	var serial: int = _serial
	CsgBlockoutToolManager.refresh_all()
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree != null:
		tree.create_timer(seconds).timeout.connect(func() -> void:
			if serial == _serial:
				clear())

static func clear() -> void:
	text = ""
	action_label = ""
	action = Callable()
	CsgBlockoutToolManager.refresh_all()

static func is_visible() -> bool:
	return not text.is_empty()

## Runs the action (if any) and hides the line.
static func trigger() -> void:
	var a: Callable = action
	clear()
	if a.is_valid():
		a.call()
