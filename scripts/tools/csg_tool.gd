@tool
class_name CsgBlockoutTool
extends RefCounted
## Base class for viewport tools.
## Modal tools are activated through CsgBlockoutToolManager.activate() and own the
## mouse until they finish or are cancelled. Passive tools stay registered and get
## every event the active tool didn't consume (hotkeys, hover interactions).

const PASS: int = EditorPlugin.AFTER_GUI_INPUT_PASS
const STOP: int = EditorPlugin.AFTER_GUI_INPUT_STOP

var manager: CsgBlockoutToolManager

func get_id() -> StringName:
	return &""

## Called when the tool becomes the active modal tool.
func activate() -> void:
	pass

## Called when the tool stops being active (finished, cancelled or replaced).
func deactivate() -> void:
	pass

## Esc / right click: abort the current step. Modal tools usually end themselves.
func cancel() -> void:
	manager.deactivate(self)

## Returns PASS or STOP like EditorPlugin._forward_3d_gui_input().
func input(_camera: Camera3D, _event: InputEvent) -> int:
	return PASS

## Draws on the viewport overlay (screen space).
func draw_overlay(_overlay: Control, _camera: Camera3D) -> void:
	pass

## One-line usage hint shown at the bottom of the viewport while active.
func hint() -> String:
	return ""
