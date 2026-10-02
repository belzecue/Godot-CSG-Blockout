<div align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="res/icon_transparent.svg" />
    <img src="res/icon_transparent_light.svg" alt="CSG_Blockout Logo" width="180" />
  </picture>
  <h1>CSG_Blockout</h1>

  <p>
    <a href="README.md"><img src="https://img.shields.io/badge/Docs-English-blue?style=flat-square" alt="Docs English" /></a>
    <a href="README_CN.md"><img src="https://img.shields.io/badge/%E6%96%87%E6%A1%A3-%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87-blue?style=flat-square" alt="文档 简体中文" /></a>
    <a href="TUTORIAL_CN.md"><img src="https://img.shields.io/badge/%E6%95%99%E7%A8%8B-%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87-orange?style=flat-square" alt="教程 简体中文" /></a>
    <a href="ARCHITECTURE_CN.md"><img src="https://img.shields.io/badge/%E6%9E%B6%E6%9E%84-%E6%8A%80%E6%9C%AF%E5%86%85%E5%B9%95-purple?style=flat-square" alt="架构 技术内幕" /></a>
  </p>

  <p>
    <a href="https://godotengine.org"><img src="https://img.shields.io/badge/Godot-4.7%2B-478cbf?style=flat-square&logo=godotengine&logoColor=white" alt="Godot 引擎" /></a>
    <a href="https://store.godotengine.org/asset/qwqzhanqwq/csg-blockout/"><img src="https://img.shields.io/badge/AssetLib-CSG__Blockout-blueviolet?style=flat-square" alt="Godot AssetLib" /></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-success?style=flat-square" alt="开源协议: MIT" /></a>
  </p>

  <p>
    <strong>做关卡原型，不是做建模。</strong><br />
    在 Godot 4.7 里用原生 CSG 节点搭白盒：没有私有格式，随时可改，随时可退。
  </p>

  <!-- 首屏演示位：15 秒动图，从空场景到一个带门洞的房间。录好后放在这里，例如
  <img src="DocsImages/Hero.webp" alt="15 秒从空场景搭出带门洞的房间" width="800" /> -->
</div>

---

## 为什么是 CSG？

笔刷式关卡编辑器把几何体存在自己的数据格式里。CSG_Blockout 不这样做：你搭的每一块都是场景树里普通的 Godot CSG 节点，全程非破坏性编辑。墙随时能挪，门洞随时能改，挖掉的部分随时能删，不会有什么东西在背后被悄悄塌缩成网格。

这也意味着你随时可以不用这个插件：

- 饼菜单和侧边栏创建的**基础图元**就是原生的 `CSGBox3D`、`CSGCylinder3D` 等节点，禁用或删除插件都不受影响。
- **楼梯**（`CSGStairs3D`）会退化为形状不变的原生 `CSGPolygon3D`。
- **Repeater / Spreader** 的实例是实时预览，先点一下 **烘焙 (Bake)** 就会变成普通场景节点。
- **网格材质**放在插件目录里：仅禁用插件时保留，删除插件目录则会丢失。

---

## 安装指南

### 途径 1：Godot AssetLib 官方资产库（推荐）
1. 在 Godot 4.7 编辑器顶部点击 **AssetLib (资产库)** 选项卡。
2. 搜索 `CSG Blockout`，点击下载并安装到项目中。
3. 也可通过网页版资产库直达：[Godot AssetLib - CSG_Blockout](https://store.godotengine.org/asset/qwqzhanqwq/csg-blockout/)。

### 途径 2：GitHub Releases 发布包
1. 前往项目的 [Releases 页面](https://github.com/qwqzhanqwq/Godot-CSG-Blockout/releases) 下载最新的 `.zip` 归档文件。
2. 解压后将 `addons/csg_blockout` 文件夹复制到你的 Godot 项目根目录下的 `addons/` 目录中。

### 途径 3：Git 源码克隆
在你的 Godot 项目根目录下执行以下命令：
```bash
git clone https://github.com/qwqzhanqwq/Godot-CSG-Blockout.git addons/csg_blockout
```

### 启用插件
打开 Godot 编辑器，依次点击 **项目 (Project) -> 项目设置 (Project Settings) -> 插件 (Plugins)**，找到 **CSG_Blockout** 并勾选 **启用 (Enable)**。

---

## 快速上手

1. **在光标处创建**：在 3D 视口按 `Shift + A`，在光标处呼出饼菜单，朝目标方向一甩即可创建形状或切换布尔模式（并集 / 交集 / 差集）。
2. **或者点侧边栏**：视口左侧边栏一键创建形状、楼梯和标尺。选中 `CSGCombiner3D` 时新节点放进它内部，选中某个形状时新节点紧挨着它放。
3. **挖一个门洞**：模式切到差集，往墙里放一个盒子。
4. **让尺度一眼可读**：选一种网格材质（1 米一格，怎么缩放都不拉伸），选中形状后点 **“应用材质到选中节点”**。
5. **拿角色参数验一下**：在两个平台之间拉一把标尺，按你设定的角色参数判断这段间隙跳不跳得过去。

> 完整图文教程与性能优化流程，请查阅 [快速上手与高级工作流教程 (TUTORIAL_CN.md)](TUTORIAL_CN.md)。

---

## 功能

### 白盒搭建
- **光标处饼菜单**（`Shift + A`）：不离开视口就能创建形状、切换布尔模式。按住右键飞行浏览时不会误触。
- **视口侧边栏**：形状、楼梯、标尺都是一键创建。新节点自动放在你本来就会手动放的位置：选中组合器就放进去，选中形状就放在它旁边。没有选中 CSG 节点时侧边栏自动隐藏。
- **楼梯与坡道**（`CSGStairs3D`）：设定总高、进深、宽度和阶数；一键切成平滑坡道来测移动手感。踏步高宽超出舒适范围时会提示。
- **所有操作都能撤销**：创建、切换模式、赋材质、烘焙 Repeater/Spreader 实例，统统 `Ctrl + Z` / `Ctrl + Y`。

### 尺度与度量
- **永不拉伸的网格材质**：世界对齐的 1 米网格，浅色、深色、橙色强调三种，外加无材质模式和自定义材质槽，可批量赋予选中节点。
- **关卡标尺**（`CSGRuler3D`）：拖动两个端点，直接读出直线距离、水平跨度和高差；并按角色身高、单跳高度、冲刺跳距离判断能否到达。这些参数在项目设置里统一配置，也可以单把标尺覆盖。顶部工具栏可一键显隐所有标尺。

### 程序化附加工具
- **Repeater**（`CSGRepeater3D`）：按网格、环形、螺旋或噪声分布排布副本，可随机旋转、缩放和抖动位置。
- **Spreader**（`CSGSpreader3D`）：在任意 `Shape3D` 范围内撒最多 200 个互不重叠的副本，调参数时预览实时刷新。
- 点顶部工具栏的 **烘焙 (Bake)**，把预览副本变成普通场景节点。

### 其他
- 界面支持 7 种语言：中文、英语、日语、韩语、西班牙语、葡萄牙语、俄语。默认跟随编辑器语言，也可单独指定。

算法推导、设计模式与完整属性参考见 [ARCHITECTURE_CN.md](ARCHITECTURE_CN.md)。

---

## 路线图

方向是 **画 → 跑 → 改**，全程不离开节点树。接下来做：视口拖拽创建、统一的栅格与吸附、切割与门窗工具。再往后：可逆烘焙（把 CSG 树冻结成网格，也能一键解冻回可编辑 CSG）、视口内的关卡设计度量层，以及带测试角色的"从这里试玩"。

版本更新记录见 [CHANGELOG.md](CHANGELOG.md)。

---

## 参与贡献

欢迎提交问题反馈、功能建议和 Pull Request，动手前请先阅读 [贡献指南 (CONTRIBUTING_CN.md)](CONTRIBUTING_CN.md)。

---

## 与 CSG Toolkit 的关系

本项目源自 **LuckyTepot** 的开源插件 [CSG Toolkit](https://godotengine.org/asset-library/asset/3057)，它证明了在 Godot 视口内直接搭 CSG 的价值。`CSG_Blockout` 由 [qwqzhanqwq](https://github.com/qwqzhanqwq) 面向 Godot 4.7 从头重写：

| | 原版 CSG Toolkit | CSG_Blockout |
| :--- | :--- | :--- |
| **引擎** | 早期 Godot 4.x | Godot 4.7+，GDScript 全静态类型 |
| **创建形状** | 视口侧边栏 | 光标处饼菜单 + 侧边栏 |
| **关卡设计辅助** | — | 参数化楼梯/坡道、带跳跃可达性判定的关卡标尺 |
| **材质** | 默认材质 | 世界对齐网格材质，批量赋予 |
| **程序化排布** | — | Repeater 与防重叠 Spreader，可烘焙为普通节点 |
| **撤销** | 基础支持 | 插件的每个操作都可撤销 |
| **语言** | 英语 | 7 种语言 |

---

## 文档导航

### 简体中文
- [主说明文档 (README_CN.md)](README_CN.md)：定位、安装与功能。
- [快速上手与高级工作流教程 (TUTORIAL_CN.md)](TUTORIAL_CN.md)：手把手教学、动图演示与白盒烘焙方案。
- [架构设计与技术内幕 (ARCHITECTURE_CN.md)](ARCHITECTURE_CN.md)：3D 空间哈希推导、架构解析与 API 字典。
- [更新日志 (CHANGELOG.md)](CHANGELOG.md)：每个版本改了什么（英文）。
- [贡献指南 (CONTRIBUTING_CN.md)](CONTRIBUTING_CN.md)：如何反馈问题与提交 PR。

### English
- [Main Documentation (README.md)](README.md): Overview, installation, and features.
- [Quick Start & Advanced Workflow Tutorial (TUTORIAL_EN.md)](TUTORIAL_EN.md): Step-by-step guide, demos, and the CSG-to-mesh baking workflow.
- [Architecture & Technical Internals (ARCHITECTURE.md)](ARCHITECTURE.md): Spatial hash algorithm, design patterns, and API reference.
- [Contributing Guide (CONTRIBUTING.md)](CONTRIBUTING.md): How to report bugs and submit pull requests.

---

## 致谢与开源协议

- **原始概念与界面原型灵感**：[LuckyTepot](https://github.com/LuckyTepot) (CSG Toolkit, Copyright (c) 2023).
- **架构重构、3D 轮盘、空间哈希优化、阵列/散布系统、楼梯与标尺、GDScript 2.0 重写**：[qwqzhanqwq](https://github.com/qwqzhanqwq) (Copyright (c) 2026).
- **贡献者**：[SuzukaDev](https://github.com/SuzukaDev)（修复饼菜单在飞行浏览时误触）。

本项目基于 [MIT License](LICENSE) 开源发布。
