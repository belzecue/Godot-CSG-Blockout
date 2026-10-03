@tool
extends Node
## Reproducible CSG Blockout benchmarks, run inside the editor (see BENCHMARKS.md):
##   edit    - time Godot takes to rebuild a CSG tree after one wall moves (booleans,
##             mesh and collision: the work behind every gizmo drag step), with the
##             whole level in one CSG tree vs one tree per room;
##   freeze  - time to freeze the level (mesh + collision + stored CSG source);
##   runtime - startup and frame time of the level in a running game, live CSG vs
##             frozen with the editor data stripped (what an exported game gets).
## Levels are generated: rooms of 8 primitives (floor, four walls, a door and a window
## cut, a pillar) on a grid. Temporary scenes live in res://csg_blockout_benchmark_tmp
## and are deleted at the end; results go to user://csg_blockout/benchmarks/.

const ROOM_COUNTS: PackedInt32Array = [3, 6, 12, 25, 50]
const PARTS_PER_ROOM: int = 8
const EDITS: int = 15
const RUNTIME_SECONDS: float = 3.0
const TMP_DIR: String = "res://csg_blockout_benchmark_tmp"
const OUT_DIR: String = "user://csg_blockout/benchmarks"
const PROBE_REQUEST: String = "user://csg_blockout/benchmarks/runtime_request.json"
const PROBE_REPORT: String = "user://csg_blockout/benchmarks/runtime_report.json"
const ROOM_SIZE: float = 6.0
const ROOM_GAP: float = 0.5
const WALL: float = 0.3
const HEIGHT: float = 3.0
const SEED: int = 20261003

var _floor_mat: Material
var _wall_mat: Material

## Runs everything, writes the results and frees the runner.
func run_and_report() -> void:
	var results: Dictionary = await run()
	var md: String = write_results(results)
	print(md)
	print("CSG Blockout benchmarks written to %s" % ProjectSettings.globalize_path(OUT_DIR))
	queue_free()

func run() -> Dictionary:
	var base: String = (get_script() as Script).resource_path.get_base_dir().get_base_dir()
	_floor_mat = load(base.path_join("res/materials/mat_grid_orange.tres")) as Material
	_wall_mat = load(base.path_join("res/materials/mat_grid_light.tres")) as Material
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(TMP_DIR))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT_DIR))
	var results: Dictionary = {"machine": machine_info(), "edit": [], "freeze": [], "runtime": []}
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	rng.seed = SEED
	await _warm_up()
	for rooms: int in ROOM_COUNTS:
		var count: int = rooms * PARTS_PER_ROOM
		var scenes: Dictionary = {}
		for layout: String in ["single", "split"]:
			# Binary scenes, as exported games get them.
			var path: String = TMP_DIR.path_join("level_%03d_%s.scn" % [count, layout])
			_save(build_level(rooms, layout), path)
			scenes[layout] = path
			var root: Node = await _open(path)
			var edit: Dictionary = await _edit_latency(root, layout, rooms, rng)
			edit.merge({"primitives": count, "layout": layout})
			results["edit"].append(edit)
			var freeze_ms: float = await _freeze_time(root, layout)
			results["freeze"].append({"primitives": count, "layout": layout, "ms": freeze_ms})
			if layout == "split":
				scenes["frozen"] = TMP_DIR.path_join("level_%03d_frozen.scn" % count)
				_save_stripped(root, scenes["frozen"])
			EditorInterface.close_scene()
			await _frames(4)
		for variant: String in ["single", "split", "frozen"]:
			var report: Dictionary = await _run_probe(scenes[variant])
			report.merge({"primitives": count, "variant": variant})
			results["runtime"].append(report)
	_cleanup()
	return results

# --- level --------------------------------------------------------------------------

## `rooms` rooms on a grid. "single": all under one CSGCombiner3D; "split": every
## room is its own CSG tree under a plain Node3D.
func build_level(rooms: int, layout: String) -> Node3D:
	var root: Node3D = Node3D.new()
	root.name = "Benchmark"
	var level: Node3D = CSGCombiner3D.new() if layout == "single" else Node3D.new()
	level.name = "Level"
	root.add_child(level)
	if level is CSGShape3D:
		(level as CSGShape3D).use_collision = true
	var columns: int = ceili(sqrt(float(rooms)))
	var pitch: float = ROOM_SIZE + ROOM_GAP
	var half: float = ROOM_SIZE / 2.0 - WALL / 2.0
	for i: int in rooms:
		var room: CSGCombiner3D = CSGCombiner3D.new()
		room.name = "Room%02d" % (i + 1)
		room.position = Vector3((i % columns) * pitch, 0.0, floori(float(i) / columns) * pitch)
		room.use_collision = layout == "split"
		level.add_child(room)
		_box(room, "Floor", Vector3(ROOM_SIZE, 0.2, ROOM_SIZE), Vector3(0, -0.1, 0), _floor_mat)
		_box(room, "WallN", Vector3(ROOM_SIZE, HEIGHT, WALL), Vector3(0, HEIGHT / 2.0, -half), _wall_mat)
		_box(room, "WallS", Vector3(ROOM_SIZE, HEIGHT, WALL), Vector3(0, HEIGHT / 2.0, half), _wall_mat)
		_box(room, "WallE", Vector3(WALL, HEIGHT, ROOM_SIZE), Vector3(half, HEIGHT / 2.0, 0), _wall_mat)
		_box(room, "WallW", Vector3(WALL, HEIGHT, ROOM_SIZE), Vector3(-half, HEIGHT / 2.0, 0), _wall_mat)
		_box(room, "Door", Vector3(1.2, 2.2, WALL * 3.0), Vector3(0, 1.1, -half), _wall_mat, CSGShape3D.OPERATION_SUBTRACTION)
		_box(room, "Window", Vector3(WALL * 3.0, 1.2, 1.6), Vector3(half, 1.6, 0), _wall_mat, CSGShape3D.OPERATION_SUBTRACTION)
		var pillar: CSGCylinder3D = CSGCylinder3D.new()
		pillar.name = "Pillar"
		pillar.radius = 0.3
		pillar.height = HEIGHT
		pillar.sides = 12
		pillar.position = Vector3(1.2, HEIGHT / 2.0, 1.2)
		pillar.material = _wall_mat
		room.add_child(pillar)
	_own(root, root)
	return root

func _box(parent: Node, box_name: String, size: Vector3, pos: Vector3, mat: Material, op: int = CSGShape3D.OPERATION_UNION) -> void:
	var b: CSGBox3D = CSGBox3D.new()
	b.name = box_name
	b.size = size
	b.position = pos
	b.material = mat
	b.operation = op
	parent.add_child(b)

func _own(node: Node, owner_node: Node) -> void:
	for c: Node in node.get_children():
		c.owner = owner_node
		_own(c, owner_node)

func _save(root: Node, path: String) -> void:
	var packed: PackedScene = PackedScene.new()
	packed.pack(root)
	root.free()
	ResourceSaver.save(packed, path)
	EditorInterface.get_resource_filesystem().update_file(path)

func _open(path: String) -> Node:
	EditorInterface.open_scene_from_path(path)
	EditorInterface.set_main_screen_editor("3D")
	await _frames(10)
	return EditorInterface.get_edited_scene_root()

## Frozen level as an exported game gets it: editor-only data stripped.
func _save_stripped(scene_root: Node, path: String) -> void:
	var packed: PackedScene = PackedScene.new()
	packed.pack(scene_root)
	var copy: Node = packed.instantiate()
	CsgBlockoutExportPlugin.strip(copy)
	_save(copy, path)

# --- measurements -------------------------------------------------------------------

## One unrecorded edit + freeze, so first-use costs (loading scripts, icons, panels)
## don't land in the first measurement.
func _warm_up() -> void:
	var path: String = TMP_DIR.path_join("warm_up.scn")
	_save(build_level(2, "split"), path)
	var root: Node = await _open(path)
	var level: Node = root.get_node("Level")
	var room: CSGShape3D = level.get_child(0) as CSGShape3D
	(room.get_node("WallN") as Node3D).position.x += 0.5
	room.call(&"_update_shape")
	await _frames(2)
	var roots: Array[CSGShape3D] = [room, level.get_child(1) as CSGShape3D]
	CsgBlockoutFreeze.freeze_now(roots)
	await _frames(4)
	EditorInterface.close_scene()
	await _frames(4)

## Moves one wall of a random room and times the rebuild of the CSG tree it belongs
## to (CSGShape3D._update_shape: booleans, mesh surfaces, collision faces). Godot
## defers this rebuild to the end of the frame; calling it directly times exactly it.
func _edit_latency(scene_root: Node, layout: String, rooms: int, rng: RandomNumberGenerator) -> Dictionary:
	var level: Node = scene_root.get_node("Level")
	await _frames(4)
	var samples: PackedFloat64Array = []
	for i: int in EDITS:
		var room: CSGShape3D = level.get_child(rng.randi_range(0, rooms - 1)) as CSGShape3D
		var tree_root: CSGShape3D = level as CSGShape3D if layout == "single" else room
		var wall: CSGBox3D = room.get_node("WallN") as CSGBox3D
		wall.position.x += 0.5
		var t0: int = Time.get_ticks_usec()
		tree_root.call(&"_update_shape")
		samples.append((Time.get_ticks_usec() - t0) / 1000.0)
		wall.position.x -= 0.5
		tree_root.call(&"_update_shape")
		await _frames(1)
	return _stats(samples)

## Freezes every CSG tree of the level as one action (freeze_now: the CSG is already
## up to date here, so the frame freeze() waits for is left out).
func _freeze_time(scene_root: Node, layout: String) -> float:
	var level: Node = scene_root.get_node("Level")
	var roots: Array[CSGShape3D] = []
	if layout == "single":
		roots.append(level as CSGShape3D)
	else:
		for c: Node in level.get_children():
			roots.append(c as CSGShape3D)
	await _frames(2)
	var t0: int = Time.get_ticks_usec()
	CsgBlockoutFreeze.freeze_now(roots)
	var ms: float = (Time.get_ticks_usec() - t0) / 1000.0
	await _frames(2)
	return ms

## Runs the level in the game with the runtime probe and returns its report.
func _run_probe(scene_path: String) -> Dictionary:
	if FileAccess.file_exists(PROBE_REPORT):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(PROBE_REPORT))
	var request: FileAccess = FileAccess.open(PROBE_REQUEST, FileAccess.WRITE)
	request.store_string(JSON.stringify({"scene": scene_path, "seconds": RUNTIME_SECONDS}))
	request.close()
	var probe: String = (get_script() as Script).resource_path.get_base_dir().path_join("runtime_probe.tscn")
	EditorInterface.play_custom_scene(probe)
	var deadline: int = Time.get_ticks_msec() + 90000
	while not FileAccess.file_exists(PROBE_REPORT) and Time.get_ticks_msec() < deadline:
		await get_tree().create_timer(0.25).timeout
	await get_tree().create_timer(0.5).timeout
	if EditorInterface.is_playing_scene():
		EditorInterface.stop_playing_scene()
	await get_tree().create_timer(0.5).timeout
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(PROBE_REPORT)) if FileAccess.file_exists(PROBE_REPORT) else null
	return parsed if parsed is Dictionary else {"error": "no report"}

func _frames(n: int) -> void:
	for i: int in n:
		await get_tree().process_frame

static func _stats(samples: PackedFloat64Array) -> Dictionary:
	var sorted: Array = Array(samples)
	sorted.sort()
	var total: float = 0.0
	for s: float in sorted:
		total += s
	return {"median_ms": sorted[floori(sorted.size() / 2.0)], "max_ms": sorted[-1], "mean_ms": total / sorted.size(), "samples": sorted.size()}

func _cleanup() -> void:
	var dir: String = ProjectSettings.globalize_path(TMP_DIR)
	for f: String in DirAccess.get_files_at(dir):
		DirAccess.remove_absolute(dir.path_join(f))
	DirAccess.remove_absolute(dir)
	EditorInterface.get_resource_filesystem().scan()

# --- report -------------------------------------------------------------------------

static func machine_info() -> Dictionary:
	var memory: Dictionary = OS.get_memory_info()
	return {
		"cpu": OS.get_processor_name(),
		"threads": OS.get_processor_count(),
		"gpu": RenderingServer.get_video_adapter_name(),
		"graphics_api": "%s %s" % [RenderingServer.get_current_rendering_driver_name(), RenderingServer.get_video_adapter_api_version()],
		"ram_gb": snappedf(float(memory.get("physical", 0)) / 1073741824.0, 0.1),
		"os": "%s %s" % [OS.get_name(), OS.get_version()],
		"godot": String(Engine.get_version_info()["string"]),
		"renderer": String(ProjectSettings.get_setting("rendering/renderer/rendering_method", "")),
		"physics": String(ProjectSettings.get_setting("physics/3d/physics_engine", "")),
		"date": Time.get_date_string_from_system(),
	}

## Writes results.json and results.md to OUT_DIR and returns the Markdown.
func write_results(results: Dictionary) -> String:
	var json: FileAccess = FileAccess.open(OUT_DIR.path_join("results.json"), FileAccess.WRITE)
	json.store_string(JSON.stringify(results, "\t"))
	json.close()
	var md: String = to_markdown(results)
	var f: FileAccess = FileAccess.open(OUT_DIR.path_join("results.md"), FileAccess.WRITE)
	f.store_string(md)
	f.close()
	return md

static func to_markdown(results: Dictionary) -> String:
	var m: Dictionary = results["machine"]
	var lines: PackedStringArray = [
		"Machine: %s (%d threads), %s, %s GB RAM, %s" % [m["cpu"], m["threads"], m["gpu"], m["ram_gb"], m["os"]],
		"Godot %s, %s renderer, %s, %s physics, %s" % [m["godot"], m["renderer"], m["graphics_api"], m["physics"], m["date"]],
		"",
		"Edit latency: rebuild after moving one wall (ms, median / max of %d)" % EDITS,
		"",
		"| Primitives | One CSG tree | One tree per room |",
		"| ---: | ---: | ---: |",
	]
	for count: int in _counts(results["edit"]):
		var single: Dictionary = _find(results["edit"], count, "layout", "single")
		var split: Dictionary = _find(results["edit"], count, "layout", "split")
		lines.append("| %d | %.1f / %.1f | %.1f / %.1f |" % [count, single.get("median_ms", 0.0), single.get("max_ms", 0.0), split.get("median_ms", 0.0), split.get("max_ms", 0.0)])
	lines.append_array(["", "Freeze the whole level (ms)", "", "| Primitives | One CSG tree | One tree per room |", "| ---: | ---: | ---: |"])
	for count: int in _counts(results["freeze"]):
		lines.append("| %d | %.0f | %.0f |" % [count, _find(results["freeze"], count, "layout", "single").get("ms", 0.0), _find(results["freeze"], count, "layout", "split").get("ms", 0.0)])
	lines.append_array(["", "Running game: startup until the first frame is drawn (ms) / average frame (ms)", "", "| Primitives | CSG, one tree | CSG, tree per room | Frozen (exported) |", "| ---: | ---: | ---: | ---: |"])
	for count: int in _counts(results["runtime"]):
		var cells: PackedStringArray = []
		for variant: String in ["single", "split", "frozen"]:
			var r: Dictionary = _find(results["runtime"], count, "variant", variant)
			cells.append("%.0f / %.2f" % [r.get("startup_ms", 0.0), r.get("avg_frame_ms", 0.0)] if not r.has("error") else "n/a")
		lines.append("| %d | %s |" % [count, " | ".join(cells)])
	return "\n".join(lines) + "\n"

static func _counts(rows: Array) -> Array[int]:
	var out: Array[int] = []
	for r: Dictionary in rows:
		if not out.has(int(r["primitives"])):
			out.append(int(r["primitives"]))
	return out

static func _find(rows: Array, count: int, key: String, value: String) -> Dictionary:
	for r: Dictionary in rows:
		if int(r["primitives"]) == count and String(r.get(key, "")) == value:
			return r
	return {}
