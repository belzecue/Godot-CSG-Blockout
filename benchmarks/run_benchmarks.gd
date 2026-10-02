@tool
extends EditorScript
## Runs the CSG Blockout benchmarks: open this file in the script editor and use
## File > Run (Ctrl+Shift+X). Save your work first: the benchmark opens and closes
## temporary scenes and starts the game several times (which, like pressing Play,
## saves open scenes when "Save Before Running" is on). It takes a few minutes; the
## results are printed to the Output panel and written to user://csg_blockout/benchmarks/.

func _run() -> void:
	var runner_script: GDScript = load((get_script() as Script).resource_path.get_base_dir().path_join("csg_benchmark_runner.gd")) as GDScript
	var runner: Node = runner_script.new() as Node
	runner.name = "CsgBlockoutBenchmark"
	EditorInterface.get_base_control().add_child(runner)
	runner.call(&"run_and_report")
