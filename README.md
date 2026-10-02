<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="res/icon_transparent.svg" />
    <img src="res/icon_transparent_light.svg" alt="CSG_Blockout Logo" width="180" />
  </picture>
  <h1>CSG_Blockout</h1>

  <p>
    <a href="README.md"><img src="https://img.shields.io/badge/Docs-English-blue?style=flat-square" alt="Docs English" /></a>
    <a href="README_CN.md"><img src="https://img.shields.io/badge/%E6%96%87%E6%A1%A3-%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87-blue?style=flat-square" alt="文档 简体中文" /></a>
    <a href="TUTORIAL_EN.md"><img src="https://img.shields.io/badge/Tutorial-English-orange?style=flat-square" alt="Tutorial English" /></a>
    <a href="ARCHITECTURE.md"><img src="https://img.shields.io/badge/Architecture-Internals-purple?style=flat-square" alt="Architecture Internals" /></a>
  </p>

  <p>
    <a href="https://godotengine.org"><img src="https://img.shields.io/badge/Godot-4.7%2B-478cbf?style=flat-square&logo=godotengine&logoColor=white" alt="Godot Engine" /></a>
    <a href="https://store.godotengine.org/asset/qwqzhanqwq/csg-blockout/"><img src="https://img.shields.io/badge/AssetLib-CSG__Blockout-blueviolet?style=flat-square" alt="Godot AssetLib" /></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-success?style=flat-square" alt="License: MIT" /></a>
  </p>

  <p>
    <strong>Level prototyping, not modeling.</strong><br />
    Block out levels in Godot 4.7 with native CSG nodes: nothing proprietary, always editable, and nothing to migrate away from.
  </p>

  <!-- HERO DEMO: 15-second clip, empty scene → a room with a doorway. Put it here once recorded, e.g.
  <img src="DocsImages/Hero.webp" alt="From an empty scene to a room with a doorway in 15 seconds" width="800" /> -->
</div>

---

## Why CSG?

Brush-based level editors keep their geometry in their own data format. CSG_Blockout doesn't: everything you build is a regular Godot CSG node in your scene tree, edited non-destructively. Move a wall, resize a doorway, or delete a cut at any time; nothing gets collapsed into a mesh behind your back.

That also means you can walk away from the plugin at any time:

- **Primitives** created from the pie menu or sidebar are stock `CSGBox3D`, `CSGCylinder3D`, etc. Disabling or removing the plugin doesn't touch them.
- **Stairs** (`CSGStairs3D`) fall back to a plain `CSGPolygon3D` with the same shape.
- **Repeater / Spreader** instances are live previews. Click **Bake** first and they become ordinary scene nodes.
- **Grid materials** live in the plugin folder. Disabling the plugin keeps them; deleting the folder doesn't.

---

## Installation

### Option 1: Godot AssetLib (Recommended)
1. Open Godot 4.7 and navigate to the **AssetLib** tab at the top of the editor.
2. Search for `CSG Blockout`, download, and install it into your project.
3. Or view it directly on the web: [Godot AssetLib - CSG_Blockout](https://store.godotengine.org/asset/qwqzhanqwq/csg-blockout/).

### Option 2: GitHub Releases (.zip)
1. Download the latest release `.zip` from the [Releases page](https://github.com/qwqzhanqwq/Godot-CSG-Blockout/releases).
2. Extract the archive and copy the `addons/csg_blockout` directory into your Godot project's `addons/` folder.

### Option 3: Git Clone
Clone the repository directly into your project's `addons/` directory:
```bash
git clone https://github.com/qwqzhanqwq/Godot-CSG-Blockout.git addons/csg_blockout
```

### Enable the Plugin
In Godot, go to **Project -> Project Settings -> Plugins**, find **CSG_Blockout**, and check the **Enable** checkbox.

---

## Quick Start

1. **Create from the cursor**: Press `Shift + A` in the 3D viewport to open the pie menu at your cursor, then flick toward a shape or a boolean mode (Union / Intersection / Subtraction).
2. **Or click the sidebar**: The left viewport sidebar creates shapes, stairs, and rulers in one click. Select a `CSGCombiner3D` and new shapes go inside it; select a shape and they land right next to it.
3. **Cut a doorway**: Switch the mode to Subtraction and drop a box into a wall.
4. **Make scale readable**: Pick a grid material (1 m squares that never stretch), select your shapes, and click **"Apply Material to Selected"**.
5. **Check it against your character**: Add a ruler between two ledges to see whether the gap is jumpable with your character's settings.

> For a complete visual walkthrough and the performance workflow, see the [Quick Start & Advanced Workflow Tutorial (TUTORIAL_EN.md)](TUTORIAL_EN.md).

---

## Features

### Blockout
- **Pie menu at your cursor** (`Shift + A`): create shapes and switch boolean modes without leaving the viewport. Holding the right mouse button to fly the camera never triggers it.
- **Viewport sidebar**: one click per shape, stairs, or ruler. New nodes go where you'd put them by hand, inside the selected combiner or next to the selected shape. The sidebar hides itself when no CSG node is selected.
- **Stairs and ramps** (`CSGStairs3D`): set total height, depth, width, and step count; flip to a smooth ramp to test movement. Warns you when steps fall outside a comfortable rise/run.
- **Every action is undoable**: creating, switching modes, assigning materials, and baking Repeater/Spreader instances all go through `Ctrl + Z` / `Ctrl + Y`.

### Scale & metrics
- **Grid materials that never stretch**: world-aligned 1 m grid in light, dark, and orange accent variants, plus an untextured mode and your own material. Batch-apply to any selection.
- **Level ruler** (`CSGRuler3D`): drag two endpoints to read distance, horizontal span, and height difference. It tells you whether a gap is reachable using your character height, jump height, and sprint-jump distance, set once in Project Settings or overridden per ruler. Toggle all rulers from the top toolbar.

### Procedural extras
- **Repeater** (`CSGRepeater3D`): lay out copies in grid, circle, spiral, or noise patterns, with random rotation, scale, and jitter.
- **Spreader** (`CSGSpreader3D`): scatter up to 200 copies inside any `Shape3D` without overlaps; the preview refreshes live while you tweak settings.
- Click **Bake** in the top toolbar to turn the preview copies into regular scene nodes.

### Everything else
- Interface in 7 languages: English, Simplified Chinese, Japanese, Korean, Spanish, Portuguese, and Russian. Follows the editor language or can be overridden.

Algorithms, design patterns, and the full property reference are in [ARCHITECTURE.md](ARCHITECTURE.md).

---

## Roadmap

The direction is **draw → run → fix**, without leaving the node tree. Next up: drag-to-create in the viewport, a unified grid & snapping system, and cut/door/window tools. After that: reversible bake (freeze a CSG tree into a mesh and unfreeze it back into editable CSG), level-design metrics in the viewport, and "Play From Here" with a test character.

Release notes are in [CHANGELOG.md](CHANGELOG.md).

---

## Contributing

Bug reports, feature requests, and pull requests are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

---

## Relationship to CSG Toolkit

This plugin originated from the open-source [CSG Toolkit](https://godotengine.org/asset-library/asset/3057) by **LuckyTepot**, which proved the value of in-viewport CSG authoring. `CSG_Blockout` is a ground-up rewrite by [qwqzhanqwq](https://github.com/qwqzhanqwq) for Godot 4.7:

| | Original CSG Toolkit | CSG_Blockout |
| :--- | :--- | :--- |
| **Engine** | Early Godot 4.x | Godot 4.7+, fully statically typed GDScript |
| **Creating shapes** | Viewport sidebar | Pie menu at the cursor + sidebar |
| **Level design aids** | — | Parametric stairs/ramps, level ruler with jump reachability |
| **Materials** | Default materials | World-aligned grid materials, batch apply |
| **Procedural layout** | — | Repeater and overlap-free Spreader, bakeable to regular nodes |
| **Undo** | Basic | Every plugin action is undoable |
| **Languages** | English | 7 languages |

---

## Documentation

### English
- [Main Documentation (README.md)](README.md): Overview, installation, and features.
- [Quick Start & Advanced Workflow Tutorial (TUTORIAL_EN.md)](TUTORIAL_EN.md): Step-by-step guide, demos, and the CSG-to-mesh baking workflow.
- [Architecture & Technical Internals (ARCHITECTURE.md)](ARCHITECTURE.md): Spatial hash algorithm, design patterns, and API reference.
- [Changelog (CHANGELOG.md)](CHANGELOG.md): What changed in each release.
- [Contributing Guide (CONTRIBUTING.md)](CONTRIBUTING.md): How to report bugs and submit pull requests.

### 简体中文 (Simplified Chinese)
- [中文主说明文档 (README_CN.md)](README_CN.md)：定位、安装与功能。
- [快速上手与高级工作流教程 (TUTORIAL_CN.md)](TUTORIAL_CN.md)：图文教程与白盒烘焙方案。
- [架构设计与技术内幕 (ARCHITECTURE_CN.md)](ARCHITECTURE_CN.md)：空间哈希推导、架构解析与 API 字典。
- [贡献指南 (CONTRIBUTING_CN.md)](CONTRIBUTING_CN.md)：如何反馈问题与提交 PR。

---

## Credits & License

- **Original Concept & Layout Design**: [LuckyTepot](https://github.com/LuckyTepot) (CSG Toolkit, Copyright (c) 2023).
- **Architecture Overhaul, 3D Pie Menu, Spatial Hash Grid, Array/Scatter Systems, Stairs & Ruler, GDScript 2.0 Rewrite**: [qwqzhanqwq](https://github.com/qwqzhanqwq) (Copyright (c) 2026).
- **Contributors**: [SuzukaDev](https://github.com/SuzukaDev) (pie menu fly-navigation fix).

Licensed under the [MIT License](LICENSE).
