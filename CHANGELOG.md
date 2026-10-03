# Changelog

All notable changes to CSG_Blockout are documented here.
The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the project uses [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Added
- **Draw in the viewport**: drag a base on any surface (or the ground), release, move the mouse to set the height, click to confirm. With the operation set to Subtraction the same tool cuts: the box extrudes into the surface and lands in the combiner that owns it (a lone wall is wrapped into a new combiner automatically). A **Room** variant creates a shell box plus a hollow; wall thickness, floor thickness and open top are in Project Settings under `addons/csg_blockout/room`.
- **Door and window presets**: click a wall to cut a doorway (dropped to the floor) or a window (at sill height). The cut is aligned to the wall and goes through its measured thickness. Mouse wheel changes width, Shift+wheel height, F adds a frame. Sizes live under `addons/csg_blockout/openings`.
- **Face push/pull**: Shift+drag a face of a selected box, cylinder or stairs to move it along its normal. The opposite face stays put and axis-aligned faces land on grid lines. A Shift+click without dragging still works like Godot's Shift+click.
- **Duplicate along an axis** (`Ctrl+Shift+D`): move the mouse along X, Y or Z to repeat the selection with its own size as the step; wheel adds a gap, X/Y/Z lock the axis, click to create.
- **Grid and snapping**: one grid size for all CSG Blockout tools (0.125–8 m), changed with `[` / `]` or the new top bar dropdown, with a snap toggle (hold Ctrl to invert while dragging). The current grid is shown in the viewport.
- **Keyboard editing**: arrow keys nudge the selection one grid step along the axis closest to the view, Page Up/Page Down move it up/down (Shift: quarter step); `,` / `.` rotate by 15° (Shift: 90°); End drops the selection onto the surface below. Repeated nudges undo as one step.
- **Snap Selection to Grid** (top bar "⋯" menu): axis-aligned boxes get every face on a grid line; other nodes align their bounds to the grid.
- All new viewport shortcuts can be rebound in Editor Settings > Shortcuts > csg_blockout.
- **Reversible bake (Freeze / Unfreeze)**: freeze a CSG tree into a plain `MeshInstance3D` (plus `StaticBody3D` collision when the CSG used collision) with the same name and transform. The original CSG is stored inside the frozen node, so Unfreeze brings it back exactly. Lights, markers and other non-CSG nodes inside the tree travel with it. Whatever you add to the frozen node (script, groups, layers, children) survives the next unfreeze/freeze. Exports strip the stored CSG, so frozen blockout costs nothing at runtime.
- **Blockout outliner** (dock tab "Blockout"): only CSG trees and frozen blockout, with operation icons, show/hide, solo (editor-only, never changes the scene), lock, filtering, group/ungroup, and semantic renaming (`Wall_Corridor_01`) that leaves names you typed alone.
- **Dimension labels**: selected shapes show width × height × depth in the viewport.
- **Player reference** (`CSGPlayerReference3D`): editor-only capsule with crouch and eye height, the height you can jump onto, the sprint-jump arc and the steepest walkable slope.
- **Jump check**: select two objects to place a ruler between their closest top edges and see whether the gap is jumpable.
- **Level checks**: one click flags slopes steeper than the walkable angle and ceilings lower than standing or crouch height, highlighted in the viewport and listed in the outliner's Checks tab (click to select the shape to fix).
- **Semantic tags** (wall, floor, hazard, interactive): color-coded grid materials plus a `csg_blockout_tag` metadata your game can read; export an SVG legend for design docs.
- **Play From Here**: run the current scene with a first-person test character at the viewport center (or the cursor, from the pie menu or a shortcut you assign). It jumps exactly `single_jump_height` and a sprint jump covers `sprint_jump_distance`, the same numbers the ruler and the level checks use. Scenes without lights get a default sun and sky.
- New player metrics in Project Settings: `capsule_radius`, `crouch_height`, `max_slope_angle`, `walk_speed`.
- **Bake options** for frozen blockout: collision type (automatic, none, trimesh, one native shape per primitive, or a single convex hull), lightmap UV2 with a texel size, an occluder, and automatic LODs. Defaults are in Project Settings under `addons/csg_blockout/bake`, and every frozen node keeps its own. The Inspector panel of a frozen node changes them and rebakes in place as one undo step, without unfreezing.
- **Export to MeshLibrary** ("⋯" menu): each selected CSG tree or frozen blockout (or each one directly under a selected group) becomes a GridMap item with its mesh, collision and a rendered preview. The node's origin is the tile's pivot. Exporting into an existing library updates the items with the same names and keeps the rest, so GridMaps painted with it update right away.
- **glTF round trip** for frozen blockout: export it as `.glb` (next to the scene, in `<scene>_blockout/`), refine it in Blender or any other DCC tool and save over the file. Once Godot has re-imported it, **Use Refined Mesh** swaps it in as one undo step. Surfaces whose material name survived the trip get their Godot material back, shader materials included; materials made in the DCC tool stay as imported. Collision stays the blockout's and the CSG stays inside the node. Exporting over refined work and unfreezing a node that uses a refined mesh both ask first.
- **Non-manifold warning** for `CSGMesh3D`: since Godot 4.4, CSG runs on the Manifold library and quietly gives empty or broken results for meshes that aren't closed. The Inspector now counts open edges, edges shared by more than two faces and flipped faces, can mark them in the viewport, and the outliner flags such meshes.

### Changed
- Supports Godot 4.6 and later (previously 4.7 and later).
- Shapes created from the pie menu are placed on the surface under the cursor (resting on it, or half-embedded for subtraction), aligned to the surface normal and snapped to the grid. Sidebar creation keeps the selection's height and snaps horizontally.
- The pie menu has six sectors: Union, Intersection and Subtraction stay where they were, and the gaps hold Draw (box, room), Openings (door, window) and More.
- Switching the operation from the pie menu now applies to every selected CSG shape, as one undo step.
- New shapes get readable names (`Box`, `Floor`, `Wall`, `Cut`, `Room`, ...) instead of `CSGBox3D2`.
- The top bar is icon-only (labels moved to tooltips) and keeps a fixed width, so it sits on the same row as Godot's 3D toolbar, next to the menus Godot adds for the selected node, and never makes the viewport jump when the selection changes. Repeater/Spreader Refresh and Bake, and the view toggles (dimension labels, ruler visibility), are in the "⋯" menu.
- Rulers and player references are placed next to the selected CSG tree instead of inside it.

### Fixed
- Repeater, Spreader and Ruler scripts no longer reference editor-only classes, which could make them fail to compile in exported games. Exports now also drop editor-only helper nodes (rulers, player references).
- Godot no longer shows import errors for the animated images in `DocsImages/` (the folder is now ignored by the importer).
- The material preset icons in the sidebar now scale with the editor's display scale like the other icons.
- The pie menu no longer opens when you press `Shift + A` while holding the right mouse button to fly the viewport camera. The key press is passed on to the editor and other plugins instead of being swallowed. ([#4](https://github.com/qwqzhanqwq/Godot-CSG-Blockout/pull/4), thanks [@SuzukaDev](https://github.com/SuzukaDev))

### Documentation
- README rewritten around the plugin's purpose and the new workflow (draw, cut, measure, play, freeze), with a shortcut table and a performance summary. Repeater/Spreader moved to a "procedural extras" section.
- The tutorial now walks from an empty scene to a playable, frozen level; its old "bake to mesh and delete the CSG" section is replaced by reversible bake, and MeshLibrary and glTF export are covered. The architecture document now describes the module layout, viewport input routing, undo, how freezing stores the CSG, raycasting and the level check, Play From Here, and every setting. The stairs axes are corrected there: the steps run along +X and the width extrudes along -Z.
- Added a contributing guide (`CONTRIBUTING.md`, `CONTRIBUTING_CN.md`), issue templates, a pull request template, and this changelog.
- Added `BENCHMARKS.md` / `BENCHMARKS_CN.md`: edit latency, freeze time and in-game startup and frame time for levels of 24–400 primitives, with a benchmark you can run yourself (`benchmarks/run_benchmarks.gd`; left out of Asset Library downloads).

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
