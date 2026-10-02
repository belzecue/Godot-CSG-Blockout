# Changelog

All notable changes to CSG_Blockout are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Fixed
- The pie menu no longer opens when you press `Shift + A` while holding the right mouse button to fly the viewport camera. The key press is passed on to the editor and other plugins instead of being swallowed. ([#4](https://github.com/qwqzhanqwq/Godot-CSG-Blockout/pull/4), thanks [@SuzukaDev](https://github.com/SuzukaDev))

### Documentation
- README rewritten around the plugin's purpose: level prototyping with native, non-destructive CSG nodes. Stairs and the level ruler are now listed; Repeater/Spreader moved to a "procedural extras" section.
- Added a contributing guide (`CONTRIBUTING.md`, `CONTRIBUTING_CN.md`), issue templates, a pull request template, and this changelog.

## [2.1.0] - 2026-09-10

### Added
- **Parametric stairs and ramps (`CSGStairs3D`)**: set total height, depth, width, and step count (1–100). Toggle ramp mode for a smooth slope. The Inspector warns when step height or tread depth falls outside a comfortable range (rise 0.15–0.20 m, run 0.25–0.30 m).
- **Level ruler (`CSGRuler3D`)**: drag two endpoint handles in the viewport to read 3D distance, horizontal span, and height difference. Reports whether the target is reachable with a single jump or a sprint jump.
- **Player metrics in Project Settings**: `addons/csg_blockout/player_metrics/character_height`, `single_jump_height`, and `sprint_jump_distance`. Rulers use them by default and can override them individually.
- Stairs in the pie menu; stairs and ruler buttons in the sidebar; **Add Ruler** and **Toggle Rulers** in the top toolbar.
- Translations for all new UI in all 7 languages.

## [2.0.2] - 2026-09-08

### Added
- Japanese, Korean, Spanish, Portuguese, and Russian interface languages (7 in total).
- **Bake** button in the top toolbar for `CSGRepeater3D` and `CSGSpreader3D`. Baking turns preview instances into regular scene nodes and can be undone.
- The default boolean operation and the custom material slot are saved in Project Settings and survive editor restarts.

### Fixed
- Editor crash during locale detection.
- Godot's built-in translation catalog overriding plugin tooltips.
- Spreader: with overlap avoidance on, capsule volumes are now sampled inside the actual capsule, and `min_distance` is always respected.
- Repeater/Spreader: preview bounds were wrong for rotated templates.

## [2.0.1] - 2026-09-04

### Changed
- Plugin icons are now vector SVGs that stay sharp at any editor scale.

### Fixed
- The pie menu modifier key setting (Shift / Ctrl / Alt / Meta) now takes effect and can be picked from a dropdown in Project Settings.
- Repeater no longer accepts the abstract base pattern resource.
- Noise pattern: positions no longer blow up when "use template size" is enabled.

## [1.0.0] - 2026-08-27

First public release of the rewrite of [CSG Toolkit](https://godotengine.org/asset-library/asset/3057).

### Added
- Pie menu at the cursor (`Shift + A`) for creating CSG shapes and switching boolean operations.
- Viewport sidebar for one-click shape creation. New nodes go inside a selected combiner, or right after a selected shape.
- World-aligned grid materials (light, dark, orange accent, unshaded) with one-click apply to the selection.
- `CSGRepeater3D` with grid, circular, spiral, and noise patterns.
- `CSGSpreader3D` for scattering instances inside a `Shape3D`, with optional overlap avoidance.
- English and Simplified Chinese interface.
- Pie menu and sidebar scale with the editor's display scale.

### Fixed
- Repeater/Spreader regeneration is throttled and capped at 200 instances so large values no longer stall the editor.
