extends Node3D
## Runtime half of the CSG Blockout benchmarks (started by csg_benchmark_runner.gd).
## Loads the requested level, records how long it takes until its first frame is
## drawn (live CSG computes its booleans then), measures frame times with vsync off,
## writes a report and quits. Runtime script: must not reference editor classes.

const REQUEST_PATH: String = "user://csg_blockout/benchmarks/runtime_request.json"
const REPORT_PATH: String = "user://csg_blockout/benchmarks/runtime_report.json"
const WARMUP_FRAMES: int = 30

func _ready() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var request: Variant = JSON.parse_string(FileAccess.get_file_as_string(REQUEST_PATH)) if FileAccess.file_exists(REQUEST_PATH) else null
	if not request is Dictionary:
		_finish({"error": "no request"})
		return
	var t0: int = Time.get_ticks_usec()
	var packed: PackedScene = ResourceLoader.load(String(request["scene"]), "", ResourceLoader.CACHE_MODE_IGNORE) as PackedScene
	if packed == null:
		_finish({"error": "can't load %s" % request["scene"]})
		return
	var t_load: int = Time.get_ticks_usec()
	var level: Node = packed.instantiate()
	add_child(level)
	var t_added: int = Time.get_ticks_usec()
	# Live CSG builds its meshes at the end of the first frame; the second one draws them.
	await get_tree().process_frame
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var t_drawn: int = Time.get_ticks_usec()
	_add_camera_and_light(level)
	for i: int in WARMUP_FRAMES:
		await get_tree().process_frame
	var frames: PackedFloat64Array = []
	var last: int = Time.get_ticks_usec()
	var end: int = last + int(float(request.get("seconds", 3.0)) * 1000000.0)
	while last < end:
		await get_tree().process_frame
		var now: int = Time.get_ticks_usec()
		frames.append((now - last) / 1000.0)
		last = now
	var sorted: Array = Array(frames)
	sorted.sort()
	var total: float = 0.0
	for f: float in sorted:
		total += f
	_finish({
		"load_ms": (t_load - t0) / 1000.0,
		"instantiate_ms": (t_added - t_load) / 1000.0,
		"startup_ms": (t_drawn - t0) / 1000.0,
		"avg_frame_ms": total / maxf(sorted.size(), 1.0),
		"p99_frame_ms": sorted[mini(floori(sorted.size() * 0.99), sorted.size() - 1)] if not sorted.is_empty() else 0.0,
		"frames": sorted.size(),
		"draw_calls": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		"primitives_drawn": RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME),
		"window": [get_viewport().get_visible_rect().size.x, get_viewport().get_visible_rect().size.y],
	})

## A camera that sees the whole level from above at an angle, plus a shadowed sun
## and a sky, so every variant renders the same amount of work.
func _add_camera_and_light(level: Node) -> void:
	var box: AABB = AABB()
	var first: bool = true
	for n: Node in level.find_children("*", "GeometryInstance3D", true, false):
		var gi: GeometryInstance3D = n as GeometryInstance3D
		var b: AABB = gi.global_transform * gi.get_aabb()
		box = b if first else box.merge(b)
		first = false
	var camera: Camera3D = Camera3D.new()
	add_child(camera)
	var center: Vector3 = box.get_center()
	var reach: float = maxf(box.size.length(), 10.0)
	camera.far = reach * 4.0
	camera.look_at_from_position(center + Vector3(0.0, 0.6, 0.8).normalized() * reach * 0.9, center)
	camera.make_current()
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	sun.rotation = Vector3(deg_to_rad(-55.0), deg_to_rad(140.0), 0.0)
	sun.shadow_enabled = true
	add_child(sun)
	var sky: Sky = Sky.new()
	sky.sky_material = ProceduralSkyMaterial.new()
	var env: Environment = Environment.new()
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	var world_env: WorldEnvironment = WorldEnvironment.new()
	world_env.environment = env
	add_child(world_env)

func _finish(report: Dictionary) -> void:
	var f: FileAccess = FileAccess.open(REPORT_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(report))
		f.close()
	get_tree().quit()
