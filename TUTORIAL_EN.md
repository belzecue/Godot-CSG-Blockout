# CSG Blockout Tutorial: From an Empty Scene to a Playable, Frozen Level

*Read this in other languages: [简体中文](TUTORIAL_CN.md) | [Back to Main Docs](README.md) | [Architecture & Internals](ARCHITECTURE.md)*

## Table of Contents
- [1. Basics: Understanding CSG](#1-basics-understanding-csg)
- [2. Blocking Out a Room](#2-blocking-out-a-room)
- [3. Measuring and Testing](#3-measuring-and-testing)
- [4. Freezing: Reversible Bake](#4-freezing-reversible-bake)
- [5. Into the Production Pipeline](#5-into-the-production-pipeline)
- [6. Procedural Extras: Repeater and Spreader](#6-procedural-extras-repeater-and-spreader)

---

## 1. Basics: Understanding CSG

**CSG (Constructive Solid Geometry)** builds shapes out of simple primitives (boxes, cylinders, spheres) combined with three boolean operations:
- **Union**: merges shapes into one solid.
- **Intersection**: keeps only the volume where shapes overlap.
- **Subtraction**: carves one shape out of another, which is how doors, windows and tunnels are made.

![CSG Subtraction Demo](DocsImages/Subtraction.webp)

In Godot, every CSG node inside a `CSGCombiner3D` (or any CSG parent) contributes to one combined result. The topmost CSG node of such a group is its **root**: Godot computes one mesh and one collision shape per root. Everything stays editable: there's no point where your blockout is "converted" and can't be changed anymore.

---

## 2. Blocking Out a Room

### Draw a room or a box
1. Press `Shift + A` in the 3D viewport to open the pie menu at the cursor and pick **Draw ▸ Room** (or **Draw ▸ Box**). The two draw buttons in the top bar do the same.
2. Drag the base on the ground or on any surface. A ghost preview shows the result and its size.
3. Release, move the mouse to set the height, and click to confirm. `Esc` or a right-click cancels.

A **room** is a regular `CSGCombiner3D` holding a shell box and a hollow cut out of it. Wall and floor thickness, and whether the top is open, are in Project Settings under `addons/csg_blockout/room`.

Where new shapes go: inside the selected combiner if there is one, otherwise into the CSG tree of the surface you started on, otherwise at the scene root.

### Cut doors and windows
- Pick **Openings ▸ Door** or **Openings ▸ Window**, hover a wall and click. The cut is aligned to the wall and goes through its measured thickness. A door drops to the floor; a window sits at sill height.
- Scroll to change the width, `Shift` + scroll for the height, and press `F` to add a frame.
- For any other cut, switch the operation to **Subtraction** and use the draw tool: the box extrudes into the surface and lands in the combiner that owns it. A lone wall gets wrapped into a new combiner automatically.

### Shape and arrange
- **Push/pull a face**: `Shift`-drag a face of a selected box, cylinder or stairs. The opposite face stays put and the face snaps to the grid. A `Shift`-click without dragging still works like Godot's own.
- **Grid**: `[` / `]` changes the grid size (0.125–8 m) for every tool; the toggle next to the size in the top bar turns snapping off (holding `Ctrl` while dragging inverts it).
- **Keyboard**: arrow keys move the selection one grid step along the axis closest to the view, `Page Up` / `Page Down` move it vertically (`Shift`: a quarter step), `,` / `.` rotate by 15° (`Shift`: 90°), and `End` drops it onto the surface below.
- **Duplicate along an axis**: press `Ctrl + Shift + D` and move the mouse along X, Y or Z to repeat the selection, using its own size as the step. The wheel adds a gap, `X` / `Y` / `Z` lock the axis, and a click creates the copies.
- **Snap Selection to Grid** (top bar "⋯" menu) puts every face of axis-aligned boxes on a grid line.

### Pie menu and sidebar
The pie menu keeps Union, Intersection and Subtraction where they always were, with Draw, Openings and More in between. The sidebar on the left of the viewport creates any primitive with one click, using the boolean mode selected below it.

![Pie Menu Demo](DocsImages/PieMenu.webp)

![Sidebar Demo](DocsImages/Sidebar.webp)

### Grid materials
The sidebar has three world-aligned grid materials (**Light**, **Dark**, **Orange Accent**), an untextured mode and a slot for your own material. The grid never stretches, so 1 m squares stay 1 m whatever you resize. Select shapes and click **Apply Material to Selected** to assign the active preset.

![Material Presets & Quick Apply Demo](DocsImages/MaterialPresets.webp)

### Keep big levels fast
Godot rebuilds the whole CSG tree a changed shape belongs to. Give every room or area its own tree, for example a plain `Node3D` "Level" with one combiner per room, instead of one combiner for the whole level. Editing then stays at about 2 ms per change however big the level grows (see [BENCHMARKS.md](BENCHMARKS.md)). To split an existing level, select its level-wide combiner in the **Blockout** outliner and click **Ungroup**.

The **Blockout** dock tab lists only CSG trees and frozen blockout, with show/hide, solo (editor-only), lock, filtering, group/ungroup, and **semantic renaming** that turns auto-generated names into names like `Wall_Corridor_01`.

---

## 3. Measuring and Testing

### Know the size of everything
- Selected shapes show **width × height × depth** in meters (toggle in the "⋯" menu).
- **Player Reference** (top bar or **More ▸**) places a `CSGPlayerReference3D` next to your blockout: the character capsule, crouch and eye height, the height you can jump onto, the sprint-jump arc and the steepest walkable slope. It's editor-only and disappears when the game runs.
- The values come from Project Settings under `addons/csg_blockout/player_metrics` (character height, jump height, sprint-jump distance, capsule radius, crouch height, max slope, walk speed). A reference or a ruler can override them for itself.

### Check the level
- **Check** (the ⚠ button in the top bar) samples every walkable surface and flags slopes steeper than the walkable angle and ceilings below standing (orange) or crouch (red) height. Problems are highlighted in the viewport and listed in the **Checks** tab of the Blockout dock; click one to select the shape to fix.
- **Jump check**: select two objects and use "⋯ > Check Jump Between Two Selected". A ruler is placed between their closest top edges and tells you whether the gap is jumpable.
- **Ruler** (`CSGRuler3D`): drag its two handles to measure any distance, horizontal span or height difference.

### Tag what things are
"⋯ > Tag As" marks the selection as **wall**, **floor**, **hazard** or **interactive**. Tagged shapes get a color-coded grid material and a `csg_blockout_tag` metadata your game can read. "⋯ > Export Legend (SVG)…" writes a legend for design documents.

### Play it
**▶ Play From Here** in the top bar runs the current scene with a first-person test character at the point in the middle of the viewport, facing the way the camera faces. **More ▸ Play From Here** in the pie menu uses the point under the menu instead, and you can bind a shortcut for "at the cursor" in Editor Settings.

Controls: `WASD` move, `Space` jump, `Shift` sprint, `Ctrl` crouch, `R` back to the start, `Esc` frees the mouse, `F8` stops the game. The character jumps exactly `single_jump_height` and a sprint jump covers `sprint_jump_distance`: the same numbers the ruler and the level check use. Scenes without lights get a default sun and sky. Nothing is added to your input map or autoloads.

---

## 4. Freezing: Reversible Bake

Live CSG is great while you edit, but every CSG tree computes its booleans when the scene loads: a 400-primitive level starts about 4× slower than the same level as meshes. **Freezing** turns finished parts into plain meshes without losing the CSG.

### Freeze and unfreeze
1. Select a CSG tree (any shape inside it is enough) and click **Freeze** in the top bar (or **More ▸ Freeze**).
2. The tree is replaced in place by a `MeshInstance3D` with the same name and transform, plus a `StaticBody3D` collision when the CSG used collision. The original CSG is stored inside the frozen node. Lights, markers and other non-CSG nodes that lived inside the tree move onto the frozen node.
3. To change it, select the frozen node and click the same button, now **Unfreeze**. The exact CSG comes back, and the non-CSG nodes return to where they were.

Everything is one undo step. Whatever you add to a frozen node (a script, groups, layers, child nodes) is kept when you unfreeze, and reapplied when you freeze again, so the node keeps its name, its path and your changes.

> [!NOTE]
> - The scene root itself can't be frozen; put the CSG under a child combiner first.
> - If other nodes point at nodes *inside* the tree (a `NodePath` such as a `RemoteTransform3D` target), you get a warning: those nodes don't exist while the tree is frozen.

### Bake options and rebake
Select a frozen node to see the **Frozen blockout** panel at the top of the Inspector:
- **Collision**: *Auto* (trimesh when the CSG used collision, otherwise none), *None*, *Trimesh*, *Per-primitive shapes* (a `BoxShape3D` for each box, a `CylinderShape3D` for each cylinder, etc.; fastest, but only for union-only trees: with cuts it falls back to trimesh), or *Single convex hull*.
- **Lightmap UV2** with a texel size, an **occluder** (enable occlusion culling in Project Settings for it to have an effect) and automatic **LODs**.
- **Rebake With These Options** recomputes the frozen node from its stored CSG without unfreezing, as one undo step.

Defaults for new freezes are in Project Settings under `addons/csg_blockout/bake`.

### Shipping
When you export the game, the stored CSG and the editor-only helpers (rulers, player references) are stripped from every scene, so frozen blockout ships as plain meshes. To keep them, turn off `addons/csg_blockout/bake/strip_source_on_export`.

---

## 5. Into the Production Pipeline

### MeshLibrary for GridMap
Select CSG trees or frozen nodes (or a node that contains them) and use "⋯ > Export to MeshLibrary…". Each one becomes a GridMap item named after the node, with its mesh, collision and a rendered preview. The node's origin is the tile's pivot. Exporting into an existing library updates the items with the same names and keeps all the others, so GridMaps already painted with it update right away.

### glTF round trip with Blender
1. Freeze the part you want to refine, and save the scene.
2. Click **Export .glb** in the frozen node's Inspector panel (or "⋯ > Export Frozen Blockout as .glb (for Refinement)"). The file goes next to the scene, in `<scene>_blockout/<node>.glb`, and Godot imports it.
3. Open it in Blender (or any DCC tool), refine it, and export it back over the same file. Keep the material names you got: surfaces that come back with them get your Godot materials back, shader materials included. New materials you create stay as imported.
4. When Godot has re-imported the file, the panel says so. Click **Use Refined Mesh**. Collision stays the blockout's, and the CSG is still stored in the node.

Exporting again over a file that was changed outside Godot asks first, so refined work isn't overwritten by accident. Unfreezing a node that uses a refined mesh also asks first: it goes back to the CSG, and the `.glb` stays on disk.

### Your own meshes in CSG
`CSGMesh3D` lets you use any mesh in boolean operations, but Godot's CSG (Manifold) needs closed meshes: an open or inconsistent mesh quietly gives empty or broken results. Select a `CSGMesh3D` to see whether its mesh is closed; if it isn't, the Inspector counts the problem edges and can highlight them in the viewport.

---

## 6. Procedural Extras: Repeater and Spreader

### Repeater (`CSGRepeater3D`)
Repeats a template in a pattern: stairs, fences, pillars, rings.
1. Add a `CSGRepeater3D` and give it a template: a child CSG shape, or a node assigned to `Template Node`.
2. Create a `Pattern` resource in the Inspector:
   - `CSGGridPattern`: count and spacing along X/Y/Z.
   - `CSGCircularPattern`: a ring with a radius and count.
   - `CSGSpiralPattern`: a ring with a height offset, for spiral staircases.
   - `CSGNoisePattern`: organic placement driven by 3D noise.
3. Add random rotation, scale and position jitter as needed.

### Spreader (`CSGSpreader3D`)
Scatters up to 200 copies of a template inside any `Shape3D` (box, sphere, capsule, mesh…). With overlap avoidance on, a spatial hash grid keeps every copy at least `min_distance` from the others while the preview updates live.

Both show live previews. Use "⋯ > Bake (Repeater/Spreader)" to turn the copies into regular scene nodes (undoable), for example before freezing.
