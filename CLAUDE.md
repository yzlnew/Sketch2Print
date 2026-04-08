# Sketch2Print

从参考图片生成 OpenSCAD 3D 模型并导出可打印文件（3MF/STL）。

## 完整工作流

```
1. /pic2scad     →  分析参考图片，生成首版 .scad，渲染预览并对比
2. /iterate      →  使用 subagent + custom prompt 对比渲染图与参考图，迭代改进
3. /export-print →  导出 3MF（默认）或 STL，几何验证
```

## 核心原则

- **始终对比**：每次渲染后都必须与原始参考图视觉对比
- **渐进改进**：从基本形状开始，逐步细化细节
- **版本追踪**：所有 .scad 文件使用 3 位版本号（001, 002, ...）
- **打印优先**：设计始终考虑可打印性（壁厚、悬挑、流形）

## 运行约束

- **OpenSCAD 渲染/导出默认提权执行**：运行 `OpenSCAD.app`、`render-scad.sh`、`export-print.sh` 以及其他实际调用 OpenSCAD 二进制的命令时，默认不要先在沙盒中执行，应直接提权运行。
- **不要把 OpenSCAD 启动失败误判为模型错误**：如果沙盒内出现 OpenSCAD 启动、图形/架构、Qt 或系统兼容性错误，先用提权环境复现，再判断是否为 `.scad` 模型本身的问题。

## 文件命名规范

```
references/<name>.<ext>              # 原始参考图片
iterations/<project_name>/<project_name>_<version>.scad   # OpenSCAD 源码
iterations/<project_name>/<project_name>_<version>.png    # 渲染预览
iterations/<project_name>/<project_name>_<version>.3mf / .stl   # 导出文件
```

示例：`iterations/phone_stand/phone_stand_001.scad` → `iterations/phone_stand/phone_stand_001.png` → `iterations/phone_stand/phone_stand_001.3mf`

## 图片分析要点

分析参考图时关注：
- 整体形状和轮廓（主要几何形状是什么？）
- 主要组件和它们的空间关系
- 比例和相对尺寸（如果没有标注，根据物体类型估算合理尺寸）
- 对称性（是否沿某轴对称？）
- 功能性特征（孔、槽、卡扣、螺纹等）
- 内部结构（空心/实心/壳体？）

## 迭代视觉对比策略

每次对比时，使用 subagent + custom prompt 读取并对比两张图片，关注：
1. **轮廓匹配** — 整体外形是否一致
2. **比例正确** — 宽高深比是否匹配
3. **关键特征** — 功能性特征是否存在且位置正确
4. **细节到位** — 圆角、倒角、纹理等细节
5. **视角匹配** — 尝试调整渲染视角匹配参考图角度

## BOSL2 使用

项目包含 BOSL2 库（`libs/BOSL2/`）。在 .scad 文件中使用：

```openscad
include <libs/BOSL2/std.scad>
```

**首版（001）使用原生 OpenSCAD 原语**，确认形状正确后再引入 BOSL2。详见 `.claude/skills/resources/openscad-pitfalls.md`。

后续迭代可使用 BOSL2 的增强功能：
- `cuboid()` 带 `rounding`/`chamfer` 代替 `cube()` + `minkowski()`
- `cyl()` 带 `rounding` 代替 `cylinder()`
- Attachments 系统 (`attach()`, `position()`, `diff()`) 简化装配
- `path_sweep()` / `offset_sweep()` 用于复杂形状

详见 `.claude/skills/resources/bosl2-quickref.md`。

## 打印设计准则

- **壁厚** ≥ 0.4mm（推荐 0.8-1.2mm）
- **悬挑** < 45°（否则需要支撑或改用倒角）
- **桥接** < 10mm
- **配合间隙** 0.2-0.5mm
- **流形几何**：所有形状必须是封闭实体
- **布尔运算**：重叠形状必须用 `union()` 合并
- **Epsilon**：`difference()` 中添加 0.01mm 重叠避免 z-fighting

详见 `.claude/skills/resources/printing-guidelines.md`。

## OpenSCAD 代码规范

- 所有尺寸参数化，放在文件顶部
- 使用 `module` 封装可复用组件
- 曲面精度：全局 `$fn = 64` 或按需局部设置
- 注释说明版本变更内容
- 参考 `.claude/skills/resources/openscad-cheatsheet.md`

## 推荐的 OpenSCAD 库

根据需要，可以推荐用户安装：
- **NopSCADlib** — 真实硬件零件（螺丝、螺母、轴承、电子元件）
- **dotSCAD** — 数学曲线/曲面/分形
- **Round-Anything** — polyRound 圆角
- **threadlib** — ISO/UNC/UNF 标准螺纹
