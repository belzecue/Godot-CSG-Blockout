@tool
class_name CsgBlockoutPlayHere
extends RefCounted
## Editor side of "Play From Here": picks the spawn point under the cursor (or the
## viewport center), writes the request read by the launcher scene, saves the scenes
## like Godot does before running, and starts the launcher.

const REQUEST_PATH: String = "user://csg_blockout/play_here.json"
const REPORT_PATH: String = "user://csg_blockout/play_here_report.json"
const SCREENSHOT_PATH: String = "user://csg_blockout/play_here.png"
const LAUNCHER_SCENE: String = "scenes/play_here_launcher.tscn"
const FLOOR_OFFSET: float = 0.05

static func launcher_path() -> String:
	var base: String = CsgBlockoutConfig.plugin_path if not CsgBlockoutConfig.plugin_path.is_empty() else "res://addons/csg_blockout"
	return base.path_join(LAUNCHER_SCENE)

## Spawn transform for a view: surface under `screen_pos`, facing the camera direction.
static func spawn_for(camera: Camera3D, screen_pos: Vector2) -> Transform3D:
	var forward: Vector3 = -camera.global_transform.basis.z
	var yaw: float = atan2(-forward.x, -forward.z)
	var hit: CsgBlockoutRaycast.Hit = CsgBlockoutRaycast.cast(camera, screen_pos)
	var pos: Vector3 = camera.global_position
	if hit.is_valid():
		if hit.normal.y > 0.5:
			pos = hit.position + Vector3.UP * FLOOR_OFFSET
		else:
			# A wall or ceiling: stand just in front of it and let gravity do the rest.
			var radius: float = CsgBlockoutConfig.get_config().get_capsule_radius()
			pos = hit.position + Vector3(hit.normal.x, 0.0, hit.normal.z).normalized() * (radius + 0.1)
	return Transform3D(Basis(Vector3.UP, yaw), pos)

## Starts the game from `spawn`. Returns OK or the reason it couldn't start.
static func launch(spawn: Transform3D, test_mode: bool = false) -> Error:
	var root: Node = EditorInterface.get_edited_scene_root()
	if root == null or root.scene_file_path.is_empty():
		CsgBlockoutFreeze._toast(CsgBlockoutI18n.t("WARN_PLAY_HERE_SAVE"), EditorToaster.SEVERITY_WARNING)
		return ERR_UNCONFIGURED
	var settings: EditorSettings = EditorInterface.get_editor_settings()
	if settings.has_setting("run/auto_save/save_before_running") and bool(settings.get_setting("run/auto_save/save_before_running")):
		EditorInterface.save_all_scenes()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(REQUEST_PATH.get_base_dir()))
	for stale: String in [REPORT_PATH, SCREENSHOT_PATH]:
		if FileAccess.file_exists(stale):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(stale))
	var request: Dictionary = {
		"scene": root.scene_file_path,
		"position": [spawn.origin.x, spawn.origin.y, spawn.origin.z],
		"yaw": spawn.basis.get_euler().y,
		"metrics": CsgBlockoutConfig.get_config().get_player_metrics(),
		"test_mode": test_mode,
		"hud": CsgBlockoutI18n.t("PLAY_HERE_HUD"),
	}
	var f: FileAccess = FileAccess.open(REQUEST_PATH, FileAccess.WRITE)
	if f == null:
		return FileAccess.get_open_error()
	f.store_string(JSON.stringify(request))
	f.close()
	EditorInterface.play_custom_scene(launcher_path())
	return OK
